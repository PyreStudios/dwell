import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:dwell/src/adapter_utils.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

class Post implements SchemaObject {
  String uuid;
  String content;

  Post(this.uuid, this.content);

  @override
  void fromMap(Map<String, dynamic> map) {
    // TODO: implement fromMap
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}

class PostsTable extends Table<Post> {
  @override
  Adapter get adapter => PostgresAdapter(
      connection: PostgreSQLConnection("localhost", 5432, "dart_test",
          username: "dart", password: "dart"));

  @override
  String get tableName => 'posts';

  static final uuid = Column<String>('uuid');
  static final content = Column<String>('content');
}

void main() {
  group('Adapter Utils Test', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      var cols = getTableColumns(PostsTable());
      var col1 = cols[0];
      var col2 = cols[1];
      expect(col1.columnName, 'uuid');
      expect(col1.type, String);
      expect(col1.symbol, Symbol('uuid'));
      expect(col2.columnName, 'content');
      expect(col2.type, String);
      expect(col2.symbol, Symbol('content'));
    });
  });
}
