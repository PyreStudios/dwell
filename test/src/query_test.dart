import 'package:dwell/dwell.dart';
import 'package:test/test.dart';

class Mock extends SchemaObject {
  final int id;
  final String name;
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Mock({
    required this.id,
    this.name = 'mock',
  });
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

  @override
  List<Column> get columns => [];

  @override
  Mock buildFromRow(Map m) {
    return Mock(id: m['id']);
  }
}

void main() {
  test(
      'query should use the lowercased table name when finding results from the adapter',
      () async {
    var results = await MockTable().query().collect<Mock>();
    Mock mock = results.first;
    expect(mock.id, equals(1));
  });

  test('query should return one item when finding via single', () async {
    var result = await MockTable().query().single<Mock>();
    expect(result.id, equals(1));
  });

  test('query should return one item when finding via single', () async {
    var result = await MockTable().query().single<Mock>();
    expect(result.id, equals(1));
  });
}
