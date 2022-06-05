import 'package:dwell/dwell.dart';
import 'package:test/test.dart';

class Mock extends SchemaObject {
  final id = 1;
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': 'mock',
    };
  }

  // normally this would set properties on the object from the map
  Mock.fromMap(Map<String, dynamic> map);
}

class FakeAdapter extends Adapter {
  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(Delete delete) {
    throw UnimplementedError();
  }

  @override
  Future<void> insert(Insert<SchemaObject> insert) {
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> query(Query query,
      {String? where, String? orderBy}) async {
    return [
      {
        'mock': {
          'id': 1,
          'name': 'mock',
        }
      }
    ];
  }

  @override
  Future<void> update(Update<SchemaObject> update) {
    throw UnimplementedError();
  }
}

class MockTable extends Table<Mock> {
  MockTable() : super(name: 'Mock');
  @override
  Adapter get adapter => FakeAdapter();
}

void main() {
  test(
      'query should use the lowercased table name when finding results from the adapter',
      () async {
    var results = await MockTable().query().collect<Mock>();
    Mock mock = results.first;
    expect(mock.id, equals(1));
  });
}
