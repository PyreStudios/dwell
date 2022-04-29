import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:postgres/postgres.dart';

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

final _adapter = PostgresAdapter(
    connection: PostgreSQLConnection("localhost", 5432, "dart_test",
        username: "dart", password: "dart"));

class PostsTable extends Table<Post> {
  @override
  Adapter get adapter => _adapter;

  @override
  String get tableName => 'posts';

  static final uuid = Column<String>('uuid');
  static final content = Column<String>('content');
}

void main() async {
  var p = Post(
    'abc-12345',
    'This is a test post',
  );

  var table = PostsTable();
  // Can dwell take care of this for you?
  // This at least needs to be cleaner.
  await _adapter.open();

  await _adapter.connection.execute('''
    CREATE TABLE IF NOT EXISTS posts (
      uuid varchar(255) NOT NULL,
      content text NOT NULL,
      PRIMARY KEY (uuid)
    );
''');

  await table.delete().where(Column('uuid'), '=', p.uuid).execute();

  // violates a key constraint since the ID is not unique.
  await table.insert(p);

  var post = await table.findById('abc-123', idColumn: 'uuid');
  print(post.toMap());
  await _adapter.close();
}
