import 'dart:mirrors';

import 'package:dwell/src/table.dart';

dynamic instantiateClassFromTable(Table table, Map<String, dynamic> arguments) {
  final tableClassMirror = reflectClass(table.runtimeType);
  final generic = tableClassMirror.superclass!.typeArguments.first;
  final type = generic as ClassMirror;
  return type.newInstance(Symbol('fromMap'), [arguments]).reflectee;
}

class WhereClause {
  Column col;
  String comparator;
  dynamic value;

  WhereClause(this.col, this.comparator, this.value);
}

class _BaseQuery {
  final List<WhereClause> _clauses = [];
  final Table _table;
  Table get table => _table;
  List<WhereClause> get clauses => _clauses;

  where(Column col, String comparator, dynamic value) {
    _clauses.add(
        WhereClause(col, comparator, value is String ? "'$value'" : value));
    return this;
  }

  _BaseQuery(this._table);
}

class Query extends _BaseQuery {
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
        .map((e) => (instantiateClassFromTable(table, e[table.tableName])
            as SchemaObject))
        .toList()
        .cast<T>();
  }
}

class Update<T extends SchemaObject> extends _BaseQuery {
  T item;
  Update(Table table, this.item) : super(table);

  @override
  where(Column col, String comparator, dynamic value) {
    return super.where(col, comparator, value) as Update<T>;
  }
}

class Insert<T extends SchemaObject> extends _BaseQuery {
  T item;
  Insert(Table table, this.item) : super(table);

  @override
  where(Column col, String comparator, dynamic value) {
    return super.where(col, comparator, value) as Insert<T>;
  }
}

class Delete extends _BaseQuery {
  Delete(Table table) : super(table);

  @override
  where(Column col, String comparator, dynamic value) {
    return super.where(col, comparator, value) as Delete;
  }

  Future<void> execute() async {
    await table.adapter.delete(this);
  }
}
