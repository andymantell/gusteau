// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:gusteau/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The point of this test isn't "does drift's addColumn helper work" —
  // it's proving that an owner's actual customised settings survive the
  // upgrade untouched. The database is the only copy of this data (see
  // docs/planning/architecture.md, "Backup and durability"), so this is
  // exactly the kind of test that earns its keep: it asserts the
  // *values* made it across, not just that the migration ran without
  // throwing. See docs/planning/ci-cd.md, "Testing strategy".
  test('migration from v1 to v2 preserves customised settings', () async {
    // Deliberately not the defaults, so this can't pass by accident —
    // a migration that silently reset everything to defaults would
    // still pass a test that only checked defaults survived.
    final oldSettingsData = <v1.SettingsData>[
      const v1.SettingsData(
        id: 0,
        defaultPortions: 6,
        defaultMealsPerWeek: 3,
        repeatCooldownWeeks: 9,
        planningNudgeWeekday: 3,
        planningNudgeMinuteOfDay: 1080,
      ),
    ];
    final expectedNewSettingsData = <v2.SettingsData>[
      const v2.SettingsData(
        id: 0,
        defaultPortions: 6,
        defaultMealsPerWeek: 3,
        repeatCooldownWeeks: 9,
        planningNudgeWeekday: 3,
        planningNudgeMinuteOfDay: 1080,
        // Didn't exist at v1 — addColumn must land it as null, not some
        // other default that would misrepresent "never exported".
        lastExportedAt: null,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.settings, oldSettingsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewSettingsData,
          await newDb.select(newDb.settings).get(),
        );
      },
    );
  });
}
