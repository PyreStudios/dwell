import 'package:dwell/src/adapter.dart';
import 'package:dwell/src/adapter_utils.dart';
import 'package:dwell/src/query.dart';
import 'package:postgres/postgres.dart';

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
    var query = "DELETE FROM ${delete.table.name}";
    if (delete.clauses.isNotEmpty) {
      query += " WHERE ";
      for (var i = 0; i < delete.clauses.length; i++) {
        var clause = delete.clauses[i];
        query +=
            "${clause.col.columnName} ${clause.comparator} ${strQuote(clause.value)}";
        if (i < delete.clauses.length - 1) {
          query += " AND ";
        }
      }
    }
    print(query);

    return connection.execute(query).then((value) {});
  }

  @override
  Future<void> insert(Insert insert) async {
    var columns = getTableColumns(insert.table);
    var columnNames = columns.map((c) => c.columnName).join(", ");
    var values = columns.map((e) {
      return strQuote(insert.item.toMap()[e.columnName]);
    }).join(", ");
    var query =
        "INSERT INTO ${insert.table.name} ($columnNames) VALUES ($values)";

    print(query);
    return connection.execute(query).then((value) {});
  }

  @override
  Future<void> update(Update update) async {
    final columns = getTableColumns(update.table);
    final pkCol = getPrimaryKeyColumn(update.table);
    final item = update.item.toMap();
    final values = columns
        .where((element) => element.columnName != pkCol.columnName)
        .map((e) {
      return '${e.columnName} = ${strQuote(item[e.columnName])}';
    }).join(", ");
    final query =
        "UPDATE ${update.table.name} SET $values WHERE ${pkCol.columnName} = ${strQuote(item[pkCol.columnName])}";

    print(query);

    return connection.execute(query).then((value) {});
  }

  @override
  Future<List<Map<String, dynamic>>> query(Query query,
      {String? where, String? orderBy}) async {
    var querySql = "SELECT * FROM ${query.table.name}";
    if (query.clauses.isNotEmpty) {
      querySql += " WHERE ";
      for (var i = 0; i < query.clauses.length; i++) {
        var clause = query.clauses[i];
        querySql +=
            "${clause.col.columnName} ${clause.comparator} ${strQuote(clause.value)}";
        if (i < query.clauses.length - 1) {
          querySql += " AND ";
        }
      }
    }
    return connection.mappedResultsQuery(querySql);
  }
}
