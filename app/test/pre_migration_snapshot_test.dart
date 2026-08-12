import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/data/pre_migration_snapshot.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('gusteau_snapshot_test');
    dbFile = File(p.join(tempDir.path, 'test.sqlite'));
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// Creates a real SQLite file with one table and a given user_version —
  /// standing in for "a real database at an old schema version", which is
  /// exactly what this function has to detect correctly on a real device.
  void createDatabaseAtVersion(int version) {
    final db = sqlite3.sqlite3.open(dbFile.path);
    db.execute('CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY);');
    db.execute('PRAGMA user_version = $version;');
    db.close();
  }

  test('no file yet: nothing to snapshot', () async {
    final result = await snapshotBeforeMigrationIfNeeded(
      dbFile: dbFile,
      targetSchemaVersion: 2,
    );
    expect(result, isNull);
  });

  test(
    'file exists but is already at the target version: no snapshot',
    () async {
      createDatabaseAtVersion(2);

      final result = await snapshotBeforeMigrationIfNeeded(
        dbFile: dbFile,
        targetSchemaVersion: 2,
      );

      expect(result, isNull);
      expect(
        tempDir.listSync().length,
        1,
        reason: 'only the original db file should exist',
      );
    },
  );

  test(
    'a genuinely empty file (drift about to run onCreate): no snapshot',
    () async {
      // A brand new SQLite file has user_version 0 and no tables — the
      // same shape as "about to run onCreate", not "needs a migration".
      // If this were treated as a migration, every fresh install would
      // create a pointless snapshot of an empty database.
      final db = sqlite3.sqlite3.open(dbFile.path);
      db.close();

      final result = await snapshotBeforeMigrationIfNeeded(
        dbFile: dbFile,
        targetSchemaVersion: 2,
      );

      expect(result, isNull);
    },
  );

  test(
    'file exists at an older version with real data: snapshot is taken',
    () async {
      createDatabaseAtVersion(1);
      final originalBytes = dbFile.readAsBytesSync();

      final result = await snapshotBeforeMigrationIfNeeded(
        dbFile: dbFile,
        targetSchemaVersion: 2,
      );

      expect(result, isNotNull);
      expect(result!.existsSync(), isTrue);
      expect(result.path, contains('pre-migration-v1-to-v2'));
      expect(
        result.readAsBytesSync(),
        originalBytes,
        reason: 'the snapshot must be byte-identical to the original',
      );

      // The original file is left alone — this function only ever adds
      // a copy, never touches the source. Drift does the actual
      // migration afterwards.
      expect(dbFile.existsSync(), isTrue);
    },
  );

  test('snapshot filenames do not collide within the same run', () async {
    createDatabaseAtVersion(1);

    final first = await snapshotBeforeMigrationIfNeeded(
      dbFile: dbFile,
      targetSchemaVersion: 2,
    );
    // Simulate the migration actually happening, then a second migration
    // being needed later (e.g. v2 -> v3 in some future release).
    createDatabaseAtVersion(2);
    final second = await snapshotBeforeMigrationIfNeeded(
      dbFile: dbFile,
      targetSchemaVersion: 3,
    );

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(first!.path, isNot(equals(second!.path)));
  });
}
