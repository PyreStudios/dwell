import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:dwell/src/adapter_utils.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

class Post implements SchemaObject {
  String uuid;
  String content;

  Post(this.uuid, this.content);

  Post.fromMap(Map<String, dynamic> map) : this(map['uuid'], map['content']);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'content': content,
    };
  }
}

class PostsTable extends Table<Post> {
  PostsTable() : super(name: 'posts');
  @override
  Adapter get adapter => PostgresAdapter(
      connection: PostgreSQLConnection("localhost", 5432, "dart_test",
          username: "dart", password: "dart"));

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
