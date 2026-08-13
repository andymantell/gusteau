import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/data/database.dart';
import 'package:gusteau/screens/settings_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(database: db)));
    await tester.pumpAndSettle();
  }

  testWidgets('loads the seeded defaults into the fields', (tester) async {
    await pumpScreen(tester);

    expect(find.widgetWithText(TextField, '4'), findsOneWidget);
    expect(find.widgetWithText(TextField, '5'), findsOneWidget);
  });

  testWidgets('saving persists valid values to the database', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Default portions'),
      '6',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Default meals per week'),
      '3',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
    final settings = await (db.select(
      db.settings,
    )..where((s) => s.id.equals(0))).getSingle();
    expect(settings.defaultPortions, 6);
    expect(settings.defaultMealsPerWeek, 3);
  });

  testWidgets('a non-numeric value is rejected without saving', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Default portions'),
      'six',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('must both be whole numbers'), findsOneWidget);
    final settings = await (db.select(
      db.settings,
    )..where((s) => s.id.equals(0))).getSingle();
    expect(settings.defaultPortions, 4, reason: 'unchanged');
  });

  testWidgets('zero is rejected as not a positive integer', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Default meals per week'),
      '0',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('must both be whole numbers'), findsOneWidget);
  });
}
