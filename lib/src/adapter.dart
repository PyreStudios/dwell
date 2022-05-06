import 'package:dwell/dwell.dart';

abstract class Adapter {
  Future<void> open();
  Future<void> close();
  Future<void> delete(Delete delete);
  Future<void> insert(Insert insert);
  Future<void> update(Update update);
  Future<List<Map<String, dynamic>>> query(Query query,
      {String? where, String? orderBy});
}
