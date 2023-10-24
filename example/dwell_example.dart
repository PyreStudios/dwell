import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:postgres/postgres.dart';

class Post implements SchemaObject {
  String uuid;
  String content;

  // dwell currently only supports named parameters
  Post({required this.uuid, required this.content});

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'content': content,
    };
  }
}

class PostObjectBuilder extends SchemaObjectBuilder<Post> {
  @override
  Post fromMap(Map m) {
    return Post(uuid: m['uuid'], content: m['content']);
  }
}

final _adapter = PostgresAdapter(
    connection: PostgreSQLConnection("localhost", 5432, "dart_test",
        username: "dart", password: "dart"));

class PostsTable extends Table<Post> {
  PostsTable() : super(name: 'posts');
  @override
  Adapter get adapter => _adapter;

  static final uuid = Column<String>('uuid', primaryKey: true);
  static final content = Column<String>('content');

  @override
  List<Column> get columns => [
        PostsTable.uuid,
        PostsTable.content,
      ];

  @override
  SchemaObjectBuilder<Post> get builder => PostObjectBuilder();
}

void main() async {
  var p = Post(
    uuid: 'abc-123',
    content: 'This is a test post',
  );

  var table = PostsTable();
  // For now, adapter opening and closing needs to be controlled by the user
  await _adapter.open();

  // You should probably use migrations instead of something like this, but
  // we're not your parents, so we won't stop you.
  await _adapter.connection.execute('''
    CREATE TABLE IF NOT EXISTS posts (
      uuid varchar(255) NOT NULL,
      content text NOT NULL,
      PRIMARY KEY (uuid)
    );
''');

  await table.delete().where(PostsTable.uuid, '=', p.uuid).execute();
  await table.insert(p);
  // update content
  p.content = "fresh content only";
  // persist updated content
  await table.update(p).execute();
  final post = await table.findByPk('abc-123');
  print(post.toMap());

  await _adapter.close();
}
