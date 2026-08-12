// drift's own `isNull` (a column-expression helper) and matcher's
// `isNull` (a test matcher) collide — this file wants the latter.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schemaVersion getter matches kSchemaVersion', () {
    // schemaVersion must be a literal for drift_dev's tooling (see the
    // comment in database.dart), so nothing enforces these stay in sync
    // except this test.
    expect(db.schemaVersion, kSchemaVersion);
  });

  test('a single default settings row is seeded on creation', () async {
    final rows = await db.select(db.settings).get();
    expect(rows, hasLength(1));

    final row = rows.single;
    expect(row.id, 0);
    expect(row.defaultPortions, 4);
    expect(row.defaultMealsPerWeek, 5);
    expect(row.repeatCooldownWeeks, 6);
    expect(row.planningNudgeWeekday, isNull, reason: 'nudge is off by default');
    expect(row.planningNudgeMinuteOfDay, isNull);
    expect(row.lastExportedAt, isNull);
  });

  test('settings can be updated in place', () async {
    await (db.update(db.settings)..where((s) => s.id.equals(0))).write(
      const SettingsCompanion(
        defaultPortions: Value(6),
        defaultMealsPerWeek: Value(3),
      ),
    );

    final row = await (db.select(
      db.settings,
    )..where((s) => s.id.equals(0))).getSingle();
    expect(row.defaultPortions, 6);
    expect(row.defaultMealsPerWeek, 3);
    // Untouched columns keep their values.
    expect(row.repeatCooldownWeeks, 6);
  });
}
