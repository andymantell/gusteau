import 'package:drift/drift.dart';

import 'recipes_table.dart';

/// Fixed unit enum, closed set. "grams" one call and "g" the next would
/// make merging fail silently — see docs/planning/architecture.md,
/// "Units come from a fixed enum".
enum IngredientUnit { g, kg, ml, l, tsp, tbsp, item }

/// One ingredient line on a [Recipes] row.
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();

  /// Preserves the order the model returned — ingredient lists read
  /// oddly reordered (mise en place first, garnish last, etc).
  IntColumn get sortOrder => integer()();

  /// Precisely enough to buy, not just to cook — "beef mince, 12% fat",
  /// not "mince". See architecture.md, "Shared house style".
  TextColumn get name => text()();

  /// Nullable because cooking is fuzzy: "salt to taste", "a splash of
  /// oil". See architecture.md, "Quantities are nullable". Ingredients
  /// with a null quantity skip merging/rounding entirely.
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => textEnum<IngredientUnit>().nullable()();
  TextColumn get note => text().nullable()();
}
