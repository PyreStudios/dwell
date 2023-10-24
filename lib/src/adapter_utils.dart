import 'package:dwell/dwell.dart';

class ColumnData {
  final String columnName;

  const ColumnData(this.columnName);
}

List<ColumnData> getTableColumns(Table table) {
  return table.columns.map((e) => ColumnData(e.columnName)).toList();
}

Column getPrimaryKeyColumn(Table table) {
  return table.columns.firstWhere((e) => e.primaryKey);
}

dynamic strQuote(value) {
  if (value is String) {
    return "'$value'";
  } else {
    return value;
  }
}
