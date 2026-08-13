import 'package:drift/drift.dart';

/// How a [Recipes] row came to exist. See
/// docs/planning/architecture.md, "Data model (sketch)".
enum RecipeSource {
  llmSuggested,
  photoRecipeCard,
  photoFoodReconstruction,
  manual,
}

enum RecipeDifficulty { easy, medium, hard }

/// A recipe: LLM-generated, reconstructed from a photo, or hand-entered.
/// Ingredients live in [RecipeIngredients], a separate table rather than
/// a JSON blob, so ingredient merging (iteration 4) can query them
/// directly — see architecture.md, "The structured-output contract".
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  /// The portion count these quantities are written for. See
  /// architecture.md, "Portions and recipe scaling" — recipes are
  /// generated at the target count, not scaled afterwards.
  IntColumn get serves => integer()();

  TextColumn get method => text()();

  BoolColumn get editedByUser => boolean().withDefault(const Constant(false))();

  /// Rough, LLM-estimated, informational only — never feeds back into
  /// suggestions. See architecture.md, "Shared house style".
  IntColumn get kcalPerPortion => integer().nullable()();
  RealColumn get proteinGPerPortion => real().nullable()();
  RealColumn get fatGPerPortion => real().nullable()();
  RealColumn get carbsGPerPortion => real().nullable()();

  TextColumn get source => textEnum<RecipeSource>()();

  // Tags emitted by the model alongside the recipe — used for display
  // and filtering now, and by the repeat-cooldown escalation path
  // later if the prompt-only approach ever needs a structural backstop.
  TextColumn get cuisine => text().nullable()();
  IntColumn get timeMinutes => integer().nullable()();
  TextColumn get difficulty => textEnum<RecipeDifficulty>().nullable()();
  TextColumn get primaryProtein => text().nullable()();
  TextColumn get cookingMethod => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
