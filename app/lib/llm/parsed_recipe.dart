import 'recipe_schema.dart';

/// The response failed validation against [kSubmitRecipeToolSpec].
///
/// [message] is specific enough to be useful two ways: fed back into
/// the single automatic retry (see architecture.md, "Validate
/// on-device anyway, and retry once"), and shown verbatim if a second
/// attempt also fails — a prompt bug worth seeing, not a generic
/// apology. See architecture.md, "Error handling".
class RecipeValidationException implements Exception {
  RecipeValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ParsedIngredient {
  const ParsedIngredient({
    required this.name,
    this.quantity,
    this.unit,
    this.note,
  });

  final String name;

  /// Null for fuzzy amounts ("salt to taste") — see architecture.md,
  /// "Quantities are nullable, because cooking is fuzzy". Ingredients
  /// with a null quantity skip merging/rounding entirely downstream.
  final double? quantity;

  /// One of [kIngredientUnits], or null alongside a null quantity.
  final String? unit;
  final String? note;
}

/// The typed, validated result of a `submit_recipe` tool call — the
/// interface between the model and everything downstream that does
/// arithmetic on recipe data (merging, rounding, rescaling, product
/// matching). See architecture.md, "The structured-output contract".
class ParsedRecipe {
  const ParsedRecipe({
    required this.title,
    required this.serves,
    required this.method,
    required this.ingredients,
    this.cuisine,
    this.timeMinutes,
    this.difficulty,
    this.primaryProtein,
    this.cookingMethod,
    this.kcalPerPortion,
    this.proteinGPerPortion,
    this.fatGPerPortion,
    this.carbsGPerPortion,
  });

  final String title;
  final int serves;
  final String method;
  final List<ParsedIngredient> ingredients;
  final String? cuisine;
  final int? timeMinutes;
  final String? difficulty; // one of kRecipeDifficulties
  final String? primaryProtein;
  final String? cookingMethod;
  final int? kcalPerPortion;
  final double? proteinGPerPortion;
  final double? fatGPerPortion;
  final double? carbsGPerPortion;

  /// Parses and validates the decoded JSON arguments from a
  /// `submit_recipe` tool-use content block. Throws
  /// [RecipeValidationException] on any schema violation — never a
  /// bare [TypeError]/[NoSuchMethodError], since the caller needs a
  /// real message to retry with.
  factory ParsedRecipe.fromToolUseArguments(Map<String, dynamic> json) {
    return ParsedRecipe(
      title: _requireString(json, 'title'),
      serves: _requireInt(json, 'serves'),
      method: _requireString(json, 'method'),
      ingredients: _requireIngredients(json, 'ingredients'),
      cuisine: _optionalString(json, 'cuisine'),
      timeMinutes: _optionalInt(json, 'time_minutes'),
      difficulty: _optionalEnum(json, 'difficulty', kRecipeDifficulties),
      primaryProtein: _optionalString(json, 'primary_protein'),
      cookingMethod: _optionalString(json, 'cooking_method'),
      kcalPerPortion: _optionalInt(json, 'kcal_per_portion'),
      proteinGPerPortion: _optionalNum(json, 'protein_g_per_portion'),
      fatGPerPortion: _optionalNum(json, 'fat_g_per_portion'),
      carbsGPerPortion: _optionalNum(json, 'carbs_g_per_portion'),
    );
  }
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    throw RecipeValidationException('$key: required, but missing');
  }
  if (value is! String || value.trim().isEmpty) {
    throw RecipeValidationException(
      '$key: expected a non-empty string, got ${_describe(value)}',
    );
  }
  return value;
}

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) {
    throw RecipeValidationException('$key: required, but missing');
  }
  if (value is! int) {
    throw RecipeValidationException(
      '$key: expected an integer, got ${_describe(value)}',
    );
  }
  return value;
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw RecipeValidationException(
      '$key: expected a non-empty string, got ${_describe(value)}',
    );
  }
  return value;
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! int) {
    throw RecipeValidationException(
      '$key: expected an integer, got ${_describe(value)}',
    );
  }
  return value;
}

double? _optionalNum(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! num) {
    throw RecipeValidationException(
      '$key: expected a number, got ${_describe(value)}',
    );
  }
  return value.toDouble();
}

String? _optionalEnum(
  Map<String, dynamic> json,
  String key,
  List<String> allowed,
) {
  final value = _optionalString(json, key);
  if (value == null) return null;
  if (!allowed.contains(value)) {
    throw RecipeValidationException(
      '$key: "$value" is not one of ${allowed.join(', ')}',
    );
  }
  return value;
}

List<ParsedIngredient> _requireIngredients(
  Map<String, dynamic> json,
  String key,
) {
  final value = json[key];
  if (value == null) {
    throw RecipeValidationException('$key: required, but missing');
  }
  if (value is! List) {
    throw RecipeValidationException(
      '$key: expected a list, got ${_describe(value)}',
    );
  }
  if (value.isEmpty) {
    throw RecipeValidationException('$key: must not be empty');
  }

  final ingredients = <ParsedIngredient>[];
  for (var i = 0; i < value.length; i++) {
    final entry = value[i];
    if (entry is! Map) {
      throw RecipeValidationException(
        '$key[$i]: expected an object, got ${_describe(entry)}',
      );
    }
    final entryJson = entry.cast<String, dynamic>();
    final quantity = _optionalNum(entryJson, 'quantity');
    final unit = _optionalEnum(entryJson, 'unit', kIngredientUnits);
    // A quantity without a unit (or vice versa) can't be merged or
    // rounded downstream — surfaced now rather than silently dropped
    // later. See architecture.md, "Units come from a fixed enum".
    if ((quantity == null) != (unit == null)) {
      throw RecipeValidationException(
        '$key[$i]: quantity and unit must both be present or both null '
        '(got quantity=$quantity, unit=$unit)',
      );
    }
    ingredients.add(
      ParsedIngredient(
        name: _requireString(entryJson, 'name'),
        quantity: quantity,
        unit: unit,
        note: _optionalString(entryJson, 'note'),
      ),
    );
  }
  return ingredients;
}

String _describe(Object? value) {
  if (value == null) return 'null';
  return '${value.runtimeType} ($value)';
}
