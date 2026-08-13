import 'package:drift/drift.dart';

/// A single week's meal plan. See
/// docs/planning/architecture.md, "Portions and recipe scaling" —
/// `portions` applies uniformly to every meal in the week, no per-meal
/// override, by design.
class WeeklyPlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Seeded from Settings.defaultPortions, overridable per week.
  IntColumn get portions => integer()();

  /// Seeded from Settings.defaultMealsPerWeek, overridable per week.
  IntColumn get mealCount => integer()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
