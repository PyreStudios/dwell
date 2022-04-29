import 'package:dwell/src/adapter_utils.dart';
import 'package:dwell/src/query.dart';
import 'package:postgres/postgres.dart';

abstract class Adapter {
  Future<void> open();
  Future<void> close();
  Future<void> delete(Delete delete);
  Future<void> insert(Insert insert);
  Future<void> update(Update update);
  Future<List<Map<String, dynamic>>> query(Query query,
      {String? where, String? orderBy});
}

class PostgresAdapter implements Adapter {
  PostgreSQLConnection connection;
  PostgresAdapter({required this.connection});

  @override
  Future<void> open() async {
    return connection.open();
  }

  @override
  Future<void> close() async {
    return connection.close();
  }

  @override
  Future<void> delete(Delete delete) async {
    var query = "DELETE FROM ${delete.table.tableName}";
    if (delete.clauses.isNotEmpty) {
      query += " WHERE ";
      for (var i = 0; i < delete.clauses.length; i++) {
        var clause = delete.clauses[i];
        query +=
            "${clause.col.columnName} ${clause.comparator} ${clause.value}";
        if (i < delete.clauses.length - 1) {
          query += " AND ";
        }
      }
    }
    return connection.execute(query).then((value) {});
  }

  @override
  Future<void> insert(Insert insert) async {
    var columns = getTableColumns(insert.table);
    var columnNames = columns.map((c) => c.columnName).join(", ");
    var values = columns.map((e) {
      final value = insert.item.toMap()[e.columnName];
      if (value is String) {
        return "'$value'";
      } else {
        return value;
      }
    }).join(", ");
    var query =
        "INSERT INTO ${insert.table.tableName} ($columnNames) VALUES ($values)";

    return connection.execute(query).then((value) {});
  }

  @override
  Future<void> update(Update update) async {
    var columns = getTableColumns(update.table);
    var values = columns
        .map((e) => '${e.columnName} = ${update.item.toMap()[e.columnName]}')
        .join(", ");
    var query = "UPDATE ${update.table.tableName} SET $values";

    return connection.execute(query).then((value) {});
  }

  @override
  Future<List<Map<String, dynamic>>> query(Query query,
      {String? where, String? orderBy}) async {
    var querySql = "SELECT * FROM ${query.table.tableName}";
    if (query.clauses.isNotEmpty) {
      querySql += " WHERE ";
      for (var i = 0; i < query.clauses.length; i++) {
        var clause = query.clauses[i];
        querySql +=
            "${clause.col.columnName} ${clause.comparator} ${clause.value}";
        if (i < query.clauses.length - 1) {
          querySql += " AND ";
        }
      }
    }
    return connection.mappedResultsQuery(querySql);
  }
}
