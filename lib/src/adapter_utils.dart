import 'dart:mirrors';

import 'package:dwell/dwell.dart';

class ColumnData {
  final Type type;
  final String columnName;
  final Symbol symbol;

  const ColumnData(this.type, this.columnName, this.symbol);
}

List<ColumnData> getTableColumns(Table table) {
  final tableClassMirror = reflectClass(table.runtimeType);
  final stuff = tableClassMirror.declarations.entries
      .where((element) =>
          element.value is VariableMirror &&
          (element.value as VariableMirror).isStatic)
      .map((e) => MapEntry(e.key, e.value as VariableMirror))
      .map((e) {
    final item = tableClassMirror.getField(e.key).reflectee as Column;
    final ritem = reflect(item);
    return ColumnData(
        ritem.type.typeArguments.first.reflectedType, item.columnName, e.key);
  });

  return stuff.toList();
}
