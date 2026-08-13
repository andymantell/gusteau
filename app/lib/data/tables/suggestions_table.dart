import 'package:drift/drift.dart';

import 'recipes_table.dart';
import 'weekly_plans_table.dart';

/// How a [Suggestions] slot got its recipe. See
/// docs/planning/architecture.md, "Data model (sketch)".
enum FilledVia { llmSuggestion, favouritePick, photoCapture, manualPick }

enum SuggestionStatus {
  pending,
  accepted,
  dismissedTemporary,
  dismissedPermanent,
}

/// One meal slot within a [WeeklyPlans] week. Full refresh history isn't
/// modelled yet — nothing reads it until the repeat-cooldown escalation
/// path (architecture.md) needs more than the accepted-recipe timestamp
/// it already gets from [Recipes.createdAt] via `recipeId`.
class Suggestions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get weeklyPlanId =>
      integer().references(WeeklyPlans, #id, onDelete: KeyAction.cascade)();

  /// 0-based position within the week — display order, not a meaning.
  IntColumn get slotIndex => integer()();

  /// Null until filled — a slot can exist before generation completes.
  IntColumn get recipeId => integer().nullable().references(
    Recipes,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get filledVia => textEnum<FilledVia>().nullable()();

  // clientDefault on a textEnum column takes the underlying String, not
  // the enum — the converter is applied on read, not on this default.
  TextColumn get status => textEnum<SuggestionStatus>().clientDefault(
    () => SuggestionStatus.pending.name,
  )();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
