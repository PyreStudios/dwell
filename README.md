<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

<p align="center">
  <h1 align="center">Dwell</h1>
  
  <h2 align="center">A reflection based data abstraction layer for Dart</h2>
</p>

<!-- [![pub version](https://img.shields.io/pub/v/dwell)](https://img.shields.io/pub/v/dwell) -->
[![codecov](https://codecov.io/gh/PyreStudios/dwell/branch/main/graph/badge.svg?token=CAK5MR60ZI)](https://codecov.io/gh/PyreStudios/dwell)
<!-- [![points](https://img.shields.io/pub/points/dwell)](https://img.shields.io/pub/points/dwell)
[![likes](https://img.shields.io/pub/points/dwell)](https://img.shields.io/pub/points/dwell) -->

This package is intended for non-clientside development (servers, clis, etc). It uses reflection and will not work with Flutter (sorry). If you find this package useful, please voice your opinion on [keeping reflection around in dart here](https://github.com/dart-lang/sdk/issues/44489).

## Features

Dwell helps create a data abstraction layer (like an ORM sort of, but not quite) by providing a DSL for creating and executing queries against common databases. Dwell tries to keep you in control of your queries, but helps abstract some of the pain points away.

Currently, we only support Postgres, but adding adapter support for other databases should be relatively painless.
## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

```dart
import 'package:dwell/dwell.dart';
import 'package:dwell/src/adapters/postgres_adapter.dart';
import 'package:postgres/postgres.dart';

class Post implements SchemaObject {
  String uuid;
  String content;

  Post(this.uuid, this.content);

  // We dont have a great way to capture this by the compiler, but this constructor IS REQUIRED.
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
  PostsTable() : super(name: 'posts');
  @override
  Adapter get adapter => _adapter;

  static final uuid = Column<String>('uuid', primaryKey: true);
  static final content = Column<String>('content');
}

void main() async {
  var p = Post(
    'abc-123',
    'This is a test post',
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
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
