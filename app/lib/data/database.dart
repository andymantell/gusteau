import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.steps.dart';
import 'pre_migration_snapshot.dart';
import 'tables/settings_table.dart';

part 'database.g.dart';

/// The filename of the on-device database — the only copy of the data
/// that exists. See docs/planning/decisions.md, "Local-first: the device
/// is the system of record".
const String kDatabaseFileName = 'gusteau.sqlite';

/// Single source of truth for the schema version, so the migration
/// snapshot check (which needs it before the database is constructed)
/// can never drift out of sync with [AppDatabase.schemaVersion].
const int kSchemaVersion = 2;

@DriftDatabase(tables: [Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? _defaultExecutor());

  /// For tests: an in-memory database with no snapshot/migration ceremony.
  AppDatabase.forTesting(super.executor);

  // Must be a literal for drift_dev's static analysis (`make-migrations`,
  // schema dumping) to read it. Kept in sync with [kSchemaVersion] by a
  // unit test in test/database_test.dart, rather than by reference, since
  // referencing it here breaks that tooling.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Settings is a single row by convention (id always 0) — see
      // settings_table.dart. `id` must be passed explicitly here: it's
      // the sole INTEGER PRIMARY KEY column, which SQLite treats as a
      // rowid alias, and a rowid alias silently ignores its column
      // DEFAULT on insert — SQLite auto-assigns the next rowid (1)
      // instead. Relying on withDefault(0) alone would have seeded row
      // id 1, not 0. Caught by database_test.dart.
      await into(settings).insert(SettingsCompanion.insert(id: const Value(0)));
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.settings, schema.settings.lastExportedAt);
      },
    ),
  );

  static QueryExecutor _defaultExecutor() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, kDatabaseFileName));

      // The database is the only copy of the data — a bad migration must
      // not be able to silently destroy it. See
      // docs/planning/architecture.md, "Backup and durability", and
      // docs/planning/ci-cd.md, "Testing strategy".
      await snapshotBeforeMigrationIfNeeded(
        dbFile: file,
        targetSchemaVersion: kSchemaVersion,
      );

      return NativeDatabase.createInBackground(file);
    });
  }
}
