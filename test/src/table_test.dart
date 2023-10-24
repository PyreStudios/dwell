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

  Mock();

  // normally this would set properties on the object from the map
  Mock.fromMap(Map<String, dynamic> map);
}

class MockBuilder extends SchemaObjectBuilder<Mock> {
  @override
  Mock fromMap(Map m) {
    return Mock();
  }
}

class FakeAdapter extends Adapter {
  List<Map<String, dynamic>> _data = [];

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
    _data.add(insert.item.toMap());
    return Future.value();
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
  final Adapter _adapter = FakeAdapter();
  MockTable() : super(name: 'Mock');
  @override
  Adapter get adapter => _adapter;

  static final UUID = Column('uuid', primaryKey: true);

  @override
  List<Column> get columns => [
        MockTable.UUID,
      ];

  @override
  SchemaObjectBuilder<Mock> get builder => MockBuilder();
}

void main() {
  group('Table', () {
    group('name', () {
      test('should return the table name', () {
        final table = MockTable();
        expect(table.dwellTableName, 'Mock');
      });
    });

    group('findByPk', () {
      test('should return a single item given a primary key', () async {
        final table = MockTable();
        expect((await table.findByPk(1)).id, equals(1));
      });
    });

    group('insert', () {
      test('should call the adapter with an insert query', () async {
        final table = MockTable();
        await table.insert(Mock());
        expect((table.adapter as FakeAdapter)._data, isNotEmpty);
      });
    });

    group('insert', () {
      test('should call the adapter with an insert query', () async {
        final table = MockTable();
        await table.insert(Mock());
        expect((table.adapter as FakeAdapter)._data, isNotEmpty);
      });
    });

    group('delete', () {
      test('should return a delete query', () async {
        final table = MockTable();
        final delete = table.delete();
        expect(delete, isA<Delete>());
        expect(delete.clauses, isEmpty);
      });

      test(
          'should return a delete query already configured for primary key lookup when an item is provided',
          () async {
        final table = MockTable();
        final delete = table.delete(Mock());
        expect(delete, isA<Delete>());
        expect(delete.clauses, isNotEmpty);
      });
    });

    group('where', () {
      test('should return a where query with a where clause', () async {
        final table = MockTable();
        final where = table.where(MockTable.UUID, '=', 1);
        expect(where, isA<Query>());
        expect(where.clauses, isNotEmpty);
        expect(where.clauses.first.col, equals(MockTable.UUID));
        expect(where.clauses.first.comparator, equals('='));
        expect(where.clauses.first.value, equals(1));
      });
    });
  });
}
