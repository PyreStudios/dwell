import 'dart:mirrors';

import 'package:dwell/src/table.dart';

dynamic instantiateClassFromTable(Table table, Map<String, dynamic> arguments) {
  final tableClassMirror = reflectClass(table.runtimeType);
  final generic = tableClassMirror.superclass!.typeArguments.first;
  final type = generic as ClassMirror;
  return type.newInstance(Symbol('fromMap'), [arguments]).reflectee;
}

class WhereClause {
  final Column col;
  final String comparator;
  final dynamic value;

  const WhereClause(this.col, this.comparator, this.value);
}

class SetClause {
  final Column col;
  final dynamic value;

  const SetClause(this.col, this.value);
}

mixin WhereClauses {
  final List<WhereClause> _clauses = [];
  List<WhereClause> get clauses => _clauses;

  where(Column col, String comparator, dynamic value) {
    _clauses.add(WhereClause(col, comparator, value));
    return this;
  }
}

class _BaseQuery {
  final Table _table;
  Table get table => _table;

  _BaseQuery(this._table);
}

class Query extends _BaseQuery with WhereClauses {
  var _limit = 0;
  var _offset = 0;

  Query(Table table) : super(table);

  Query limit(int limit) {
    _limit = limit;
    return this;
  }

  Query offset(int offset) {
    _offset = offset;
    return this;
  }

  @override
  Query where(Column col, String comparator, dynamic value) {
    return super.where(col, comparator, value) as Query;
  }

  Future<List<T>> collect<T extends SchemaObject>() async {
    final results = await table.adapter.query(this);
    return results
        .map((e) =>
            (instantiateClassFromTable(table, e[table.name]) as SchemaObject))
        .toList()
        .cast<T>();
  }

  Future<T> single<T extends SchemaObject>() async {
    final results = await collect<T>();
    if (results.length > 1) {
      throw Exception('More than one result found');
    }

    return results.first;
  }
}

class Update<T extends SchemaObject> extends _BaseQuery {
  T item;

  Update(Table table, this.item) : super(table);

  Future<void> execute() async {
    await table.adapter.update(this);
  }
}

class Insert<T extends SchemaObject> extends _BaseQuery {
  T item;
  Insert(Table table, this.item) : super(table);
}

class Delete extends _BaseQuery with WhereClauses {
  Delete(Table table) : super(table);

  @override
  where(Column col, String comparator, dynamic value) {
    return super.where(col, comparator, value) as Delete;
  }

  Future<void> execute() async {
    await table.adapter.delete(this);
  }
}
