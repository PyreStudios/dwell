import 'dart:mirrors';

import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapter_utils.dart';

class Column<T> {
  final String columnName;
  final bool primaryKey;

  const Column(this.columnName, {this.primaryKey = false});
}

abstract class Table<T extends SchemaObject> {
  String name;
  Adapter get adapter;

  Table({required this.name});

  /// findByPk is a convenience method for finding a single object by its primary key.
  Future<T> findByPk(dynamic id) async {
    final pkColumn = getPrimaryKeyColumn(this);
    final result = await Query(this).where(pkColumn, '=', id).collect();
    return result.first as T;
  }

  /// insert inserts a new schemaobject into the table
  Future<void> insert(T item) async {
    return adapter.insert(Insert(this, item));
  }

  /// delete returns a delete query that must be executed to actually delete anything.
  Delete delete([T? item]) {
    if (item != null) {
      final pkCol = getPrimaryKeyColumn(this);
      return Delete(this).where(pkCol, '=', item.toMap()[pkCol.columnName]);
    } else {
      return Delete(this);
    }
  }

  /// where returns a query object with a where clause applied to it.
  Query where(Column col, String comparator, dynamic value) {
    return Query(this).where(col, comparator, value);
  }

  /// query gives you a fresh query object to build as you'd please.
  Query query() {
    return Query(this);
  }

  Update update(T item) {
    return Update(this, item);
  }
}

abstract class SchemaObject {
  Map<String, dynamic> toMap();
}
