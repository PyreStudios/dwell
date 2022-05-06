import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:dwell/src/query.dart';

class Column<T> {
  final String columnName;

  const Column(this.columnName);
}

abstract class Table<T extends SchemaObject> {
  String get tableName;
  Adapter get adapter;

  Future<T> findById(dynamic id, {String idColumn = 'id'}) async {
    final result = await Query(this).where(Column(idColumn), '=', id).collect();
    return result.first as T;
  }

  Future<void> insert(T item) async {
    return adapter.insert(Insert(this, item));
  }

  Delete delete() {
    return Delete(this);
  }

  Query where(Column col, String comparator, dynamic value) {
    return Query(this).where(col, comparator, value);
  }
}

abstract class SchemaObject {
  Map<String, dynamic> toMap();
}
