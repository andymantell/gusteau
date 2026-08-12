import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// If [dbFile] already holds a real, non-empty database whose on-disk
/// schema version differs from [targetSchemaVersion] — i.e. drift is
/// about to run a migration on it — copies it to a timestamped snapshot
/// first, and returns that snapshot file. Returns null if there was
/// nothing to snapshot (no existing file, or nothing that needs
/// migrating).
///
/// The database is the only copy of the data on a local-first app — see
/// docs/planning/architecture.md, "Backup and durability" — so a bad
/// migration must not be able to destroy it silently. Android Auto
/// Backup runs roughly daily; this covers the gap between "migration
/// goes wrong" and "next backup cycle", which Auto Backup alone can't.
///
/// This deliberately reads the on-disk schema version with a plain
/// read-only [sqlite3] connection, never through drift — going through
/// drift is what would trigger the migration this function exists to
/// snapshot *before*.
Future<File?> snapshotBeforeMigrationIfNeeded({
  required File dbFile,
  required int targetSchemaVersion,
}) async {
  if (!dbFile.existsSync()) return null;

  final db = sqlite3.sqlite3.open(dbFile.path, mode: sqlite3.OpenMode.readOnly);
  final int onDiskVersion;
  final bool hasTables;
  try {
    onDiskVersion =
        db.select('PRAGMA user_version;').first['user_version'] as int;
    hasTables = db
        .select("SELECT name FROM sqlite_master WHERE type = 'table' LIMIT 1;")
        .isNotEmpty;
  } finally {
    db.close();
  }

  // A freshly created (or freshly deleted-and-recreated) SQLite file
  // reports user_version 0 with no tables — that's drift's onCreate
  // about to run, not a migration. Nothing to snapshot.
  if (!hasTables) return null;
  if (onDiskVersion == targetSchemaVersion) return null;

  final snapshotPath =
      '${dbFile.path}.pre-migration-v$onDiskVersion-to-v$targetSchemaVersion-'
      '${DateTime.now().toUtc().millisecondsSinceEpoch}.bak';
  return dbFile.copySync(snapshotPath);
}
