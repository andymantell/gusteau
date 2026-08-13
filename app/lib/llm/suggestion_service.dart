import 'package:drift/drift.dart';

import '../api/proxy_client.dart';
import '../data/database.dart';
import '../data/tables/recipe_ingredients_table.dart';
import '../data/tables/recipes_table.dart';
import '../data/tables/suggestions_table.dart';
import 'converse_response.dart';
import 'parsed_recipe.dart';
import 'prompt_assembly.dart';

/// Result of generating (or refreshing) one suggestion slot.
sealed class GenerationResult {}

class GenerationSuccess extends GenerationResult {
  GenerationSuccess(this.recipeId);

  final int recipeId;
}

/// Carries the real failure — proxy not configured, a network error,
/// an HTTP/Bedrock error relayed by the proxy, or a validation failure
/// that survived the retry — as a ready-to-display message. See
/// docs/planning/architecture.md, "Error handling": the real failure,
/// not a generic apology.
class GenerationFailure extends GenerationResult {
  GenerationFailure(this.message);

  final String message;
}

/// Generates and persists recipe suggestions. One Bedrock call per meal
/// slot, not one call for a whole week — see prompt_assembly.dart's
/// module doc and docs/planning/decisions.md, "Favourites, and how a
/// week gets filled" — so building a week's initial suggestions and
/// refreshing one slot later both go through [generateForSlot].
class SuggestionService {
  SuggestionService({required AppDatabase db, ProxyClient? proxyClient})
    : _db = db,
      _proxyClient = proxyClient ?? ProxyClient();

  final AppDatabase _db;
  final ProxyClient _proxyClient;

  /// Creates a new week with [mealCount] slots and fills them one at a
  /// time. Stops at the first failure rather than leaving the rest
  /// silently pending — the caller can retry individual slots via
  /// [refreshSlot] (the same underlying call).
  Future<(int weeklyPlanId, List<GenerationResult> results)> startWeek({
    required int portions,
    required int mealCount,
  }) async {
    final weeklyPlanId = await _db
        .into(_db.weeklyPlans)
        .insert(
          WeeklyPlansCompanion.insert(portions: portions, mealCount: mealCount),
        );

    final slotIds = <int>[];
    for (var i = 0; i < mealCount; i++) {
      final id = await _db
          .into(_db.suggestions)
          .insert(
            SuggestionsCompanion.insert(
              weeklyPlanId: weeklyPlanId,
              slotIndex: i,
            ),
          );
      slotIds.add(id);
    }

    final results = <GenerationResult>[];
    for (final suggestionId in slotIds) {
      final result = await generateForSlot(
        suggestionId: suggestionId,
        weeklyPlanId: weeklyPlanId,
        portions: portions,
      );
      results.add(result);
      if (result is GenerationFailure) break;
    }

    return (weeklyPlanId, results);
  }

  /// Re-generates a single existing slot — same call as initial
  /// generation, just looked up from the slot rather than freshly
  /// created.
  Future<GenerationResult> refreshSlot(int suggestionId) async {
    final suggestion = await (_db.select(
      _db.suggestions,
    )..where((s) => s.id.equals(suggestionId))).getSingle();
    final plan = await (_db.select(
      _db.weeklyPlans,
    )..where((p) => p.id.equals(suggestion.weeklyPlanId))).getSingle();

    return generateForSlot(
      suggestionId: suggestionId,
      weeklyPlanId: plan.id,
      portions: plan.portions,
    );
  }

  Future<GenerationResult> generateForSlot({
    required int suggestionId,
    required int weeklyPlanId,
    required int portions,
  }) async {
    final settings = await (_db.select(
      _db.settings,
    )..where((s) => s.id.equals(0))).getSingle();

    final recentlyCooked = await _recentlyCooked(settings.repeatCooldownWeeks);
    final alreadyPicked = await _alreadyPickedThisWeek(
      weeklyPlanId: weeklyPlanId,
      excludingSuggestionId: suggestionId,
    );

    final request = buildRecipeGenerationRequest(
      portions: portions,
      recentlyCooked: recentlyCooked,
      alreadyPickedThisWeek: alreadyPicked,
    );

    final outcome = await _requestAndValidate(request);
    return switch (outcome) {
      _RequestFailure(:final message) => GenerationFailure(message),
      _RequestSuccess(:final recipe) => await _persistAndLinkRecipe(
        suggestionId: suggestionId,
        recipe: recipe,
      ),
      // _requestAndValidate() always converts a validation failure into
      // _RequestFailure before returning (see its second-attempt
      // handling) — this branch is unreachable, but the switch must
      // still be exhaustive over the full sealed type.
      _ValidationFailed() => GenerationFailure(
        'unreachable: unconverted validation failure',
      ),
    };
  }

  Future<GenerationResult> _persistAndLinkRecipe({
    required int suggestionId,
    required ParsedRecipe recipe,
  }) async {
    final recipeId = await _persistRecipe(recipe);
    await (_db.update(
      _db.suggestions,
    )..where((s) => s.id.equals(suggestionId))).write(
      SuggestionsCompanion(
        recipeId: Value(recipeId),
        filledVia: const Value(FilledVia.llmSuggestion),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return GenerationSuccess(recipeId);
  }

  /// One call, and — on a validation failure only — exactly one
  /// automatic retry feeding the error back. See architecture.md,
  /// "Validate on-device anyway, and retry once": a second failure
  /// surfaces the real error rather than retrying again.
  Future<_RequestOutcome> _requestAndValidate(
    Map<String, dynamic> request,
  ) async {
    final first = await _callAndParse(request);
    if (first is! _ValidationFailed) return first;

    final retryRequest = buildRecipeGenerationRetryRequest(
      previousRequest: request,
      assistantMessage: first.assistantMessage,
      toolUseId: first.toolUseId,
      validationError: first.validationError,
    );
    final second = await _callAndParse(retryRequest);
    if (second is _ValidationFailed) {
      return _RequestFailure(
        'Bedrock returned an invalid recipe twice. Last error: '
        '${second.validationError}',
      );
    }
    return second;
  }

  Future<_RequestOutcome> _callAndParse(Map<String, dynamic> request) async {
    final proxyResult = await _proxyClient.generate(request);
    switch (proxyResult) {
      case ProxyGenerateNotConfigured():
        return _RequestFailure(
          'Proxy connection is not configured — set it up in Settings.',
        );
      case ProxyGenerateNetworkError(:final error):
        return _RequestFailure('Network error calling the proxy: $error');
      case ProxyGenerateHttpError(:final statusCode, :final body):
        return _RequestFailure('Proxy returned $statusCode: $body');
      case ProxyGenerateSuccess(:final body):
        return _parseGenerateResponse(body);
    }
  }

  _RequestOutcome _parseGenerateResponse(Map<String, dynamic> body) {
    final ToolUseCall toolUse;
    try {
      toolUse = extractToolUseCall(body);
    } on ConverseResponseException catch (e) {
      return _RequestFailure(e.message);
    }

    try {
      return _RequestSuccess(ParsedRecipe.fromToolUseArguments(toolUse.input));
    } on RecipeValidationException catch (e) {
      final output = body['output'] as Map;
      final assistantMessage = (output['message'] as Map)
          .cast<String, dynamic>();
      return _ValidationFailed(
        assistantMessage: assistantMessage,
        toolUseId: toolUse.toolUseId,
        validationError: e.message,
      );
    }
  }

  Future<int> _persistRecipe(ParsedRecipe recipe) async {
    final recipeId = await _db
        .into(_db.recipes)
        .insert(
          RecipesCompanion.insert(
            title: recipe.title,
            serves: recipe.serves,
            method: recipe.method,
            source: RecipeSource.llmSuggested,
            cuisine: Value(recipe.cuisine),
            timeMinutes: Value(recipe.timeMinutes),
            difficulty: Value(
              recipe.difficulty == null
                  ? null
                  : RecipeDifficulty.values.byName(recipe.difficulty!),
            ),
            primaryProtein: Value(recipe.primaryProtein),
            cookingMethod: Value(recipe.cookingMethod),
            kcalPerPortion: Value(recipe.kcalPerPortion),
            proteinGPerPortion: Value(recipe.proteinGPerPortion),
            fatGPerPortion: Value(recipe.fatGPerPortion),
            carbsGPerPortion: Value(recipe.carbsGPerPortion),
          ),
        );

    for (var i = 0; i < recipe.ingredients.length; i++) {
      final ingredient = recipe.ingredients[i];
      await _db
          .into(_db.recipeIngredients)
          .insert(
            RecipeIngredientsCompanion.insert(
              recipeId: recipeId,
              sortOrder: i,
              name: ingredient.name,
              quantity: Value(ingredient.quantity),
              unit: Value(
                ingredient.unit == null
                    ? null
                    : IngredientUnit.values.byName(ingredient.unit!),
              ),
              note: Value(ingredient.note),
            ),
          );
    }

    return recipeId;
  }

  /// See architecture.md, "Repeat cooldown": accepted suggestions from
  /// the last [cooldownWeeks] weeks, titles plus a few tags — not full
  /// recipes.
  Future<List<RecentRecipeSummary>> _recentlyCooked(int cooldownWeeks) async {
    final cutoff = DateTime.now().subtract(Duration(days: 7 * cooldownWeeks));
    final query =
        _db.select(_db.suggestions).join([
          innerJoin(
            _db.recipes,
            _db.recipes.id.equalsExp(_db.suggestions.recipeId),
          ),
        ])..where(
          // .equals() on a textEnum column compares against the raw
          // stored string, not the enum — same quirk as
          // suggestions_table.dart's clientDefault.
          _db.suggestions.status.equals(SuggestionStatus.accepted.name) &
              _db.suggestions.updatedAt.isBiggerThanValue(cutoff),
        );

    return _summariesFrom(await query.get());
  }

  /// The recipes already picked for other slots in the same week, for
  /// within-week variety — see decisions.md, "Favourites, and how a
  /// week gets filled".
  Future<List<RecentRecipeSummary>> _alreadyPickedThisWeek({
    required int weeklyPlanId,
    required int excludingSuggestionId,
  }) async {
    final query =
        _db.select(_db.suggestions).join([
          innerJoin(
            _db.recipes,
            _db.recipes.id.equalsExp(_db.suggestions.recipeId),
          ),
        ])..where(
          _db.suggestions.weeklyPlanId.equals(weeklyPlanId) &
              _db.suggestions.id.equals(excludingSuggestionId).not(),
        );

    return _summariesFrom(await query.get());
  }

  List<RecentRecipeSummary> _summariesFrom(List<TypedResult> rows) {
    return rows.map((row) {
      final recipe = row.readTable(_db.recipes);
      return RecentRecipeSummary(
        title: recipe.title,
        primaryProtein: recipe.primaryProtein,
        cookingMethod: recipe.cookingMethod,
        cuisine: recipe.cuisine,
      );
    }).toList();
  }
}

sealed class _RequestOutcome {}

class _RequestSuccess extends _RequestOutcome {
  _RequestSuccess(this.recipe);

  final ParsedRecipe recipe;
}

class _RequestFailure extends _RequestOutcome {
  _RequestFailure(this.message);

  final String message;
}

class _ValidationFailed extends _RequestOutcome {
  _ValidationFailed({
    required this.assistantMessage,
    required this.toolUseId,
    required this.validationError,
  });

  final Map<String, dynamic> assistantMessage;
  final String toolUseId;
  final String validationError;
}
