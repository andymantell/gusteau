import 'dart:convert';

// drift's own `isNull` (a column-expression helper) and matcher's
// `isNull` (a test matcher) collide — this file wants the latter.
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/api/proxy_client.dart';
import 'package:gusteau/api/proxy_credentials.dart';
import 'package:gusteau/data/database.dart';
import 'package:gusteau/data/tables/recipe_ingredients_table.dart';
import 'package:gusteau/data/tables/recipes_table.dart';
import 'package:gusteau/data/tables/suggestions_table.dart';
import 'package:gusteau/llm/suggestion_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _validRecipeArgs = {
  'title': 'Buttered toast',
  'serves': 4,
  'method': 'Toast the bread. Butter it.',
  'ingredients': [
    {'name': 'bread', 'quantity': 2, 'unit': 'item'},
  ],
};

const _invalidRecipeArgsMissingTitle = {
  'serves': 4,
  'method': 'Toast the bread.',
  'ingredients': [
    {'name': 'bread'},
  ],
};

Map<String, dynamic> _bedrockToolUseResponse(
  Map<String, dynamic> recipeArgs, {
  String toolUseId = 'tool-1',
}) {
  return {
    'stopReason': 'tool_use',
    'output': {
      'message': {
        'role': 'assistant',
        'content': [
          {
            'toolUse': {
              'toolUseId': toolUseId,
              'name': 'submit_recipe',
              'input': recipeArgs,
            },
          },
        ],
      },
    },
  };
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() async {
    await db.close();
  });

  /// Builds a SuggestionService whose proxy calls are served, in order,
  /// by [responses] (each a raw HTTP status/body pair). Also captures
  /// every request body sent, for asserting on prompt content.
  ({SuggestionService service, List<String> requestBodies}) serviceWith(
    List<http.Response> responses,
  ) {
    final requestBodies = <String>[];
    var callIndex = 0;
    final credentials = ProxyCredentials();
    final proxyClient = ProxyClient(
      credentials: credentials,
      httpClient: MockClient((request) async {
        requestBodies.add(request.body);
        final response = responses[callIndex];
        callIndex++;
        return response;
      }),
    );
    return (
      service: SuggestionService(db: db, proxyClient: proxyClient),
      requestBodies: requestBodies,
    );
  }

  Future<void> configureProxy() async {
    final credentials = ProxyCredentials();
    await credentials.save(baseUrl: 'https://example.com/prod', apiKey: 'k');
  }

  group('generateForSlot', () {
    test('a valid response is persisted and linked to the slot', () async {
      await configureProxy();
      final weeklyPlanId = await db
          .into(db.weeklyPlans)
          .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
      final suggestionId = await db
          .into(db.suggestions)
          .insert(
            SuggestionsCompanion.insert(
              weeklyPlanId: weeklyPlanId,
              slotIndex: 0,
            ),
          );

      final harness = serviceWith([
        http.Response(
          jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
          200,
        ),
      ]);

      final result = await harness.service.generateForSlot(
        suggestionId: suggestionId,
        weeklyPlanId: weeklyPlanId,
        portions: 4,
      );

      expect(result, isA<GenerationSuccess>());
      final recipeId = (result as GenerationSuccess).recipeId;

      final recipe = await (db.select(
        db.recipes,
      )..where((r) => r.id.equals(recipeId))).getSingle();
      expect(recipe.title, 'Buttered toast');
      expect(recipe.source, RecipeSource.llmSuggested);

      final ingredients = await (db.select(
        db.recipeIngredients,
      )..where((i) => i.recipeId.equals(recipeId))).get();
      expect(ingredients, hasLength(1));
      expect(ingredients.single.name, 'bread');
      expect(ingredients.single.unit, IngredientUnit.item);

      final suggestion = await (db.select(
        db.suggestions,
      )..where((s) => s.id.equals(suggestionId))).getSingle();
      expect(suggestion.recipeId, recipeId);
      expect(suggestion.filledVia, FilledVia.llmSuggestion);
    });

    test(
      'an invalid response is retried once, feeding back the error',
      () async {
        await configureProxy();
        final weeklyPlanId = await db
            .into(db.weeklyPlans)
            .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
        final suggestionId = await db
            .into(db.suggestions)
            .insert(
              SuggestionsCompanion.insert(
                weeklyPlanId: weeklyPlanId,
                slotIndex: 0,
              ),
            );

        final harness = serviceWith([
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_invalidRecipeArgsMissingTitle)),
            200,
          ),
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
            200,
          ),
        ]);

        final result = await harness.service.generateForSlot(
          suggestionId: suggestionId,
          weeklyPlanId: weeklyPlanId,
          portions: 4,
        );

        expect(result, isA<GenerationSuccess>());
        expect(harness.requestBodies, hasLength(2));

        // The retry must actually carry the validation error back, not
        // just repeat the original ask.
        final retryRequest =
            jsonDecode(harness.requestBodies[1]) as Map<String, dynamic>;
        final retryMessages = retryRequest['messages'] as List;
        expect(retryMessages, hasLength(3));
        final toolResultText =
            ((((retryMessages[2] as Map)['content'] as List).first
                    as Map)['toolResult']
                as Map)['content'];
        expect((toolResultText as List).first, {
          'text': contains('title: required, but missing'),
        });
      },
    );

    test(
      'two invalid responses in a row surface the real validation error',
      () async {
        await configureProxy();
        final weeklyPlanId = await db
            .into(db.weeklyPlans)
            .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
        final suggestionId = await db
            .into(db.suggestions)
            .insert(
              SuggestionsCompanion.insert(
                weeklyPlanId: weeklyPlanId,
                slotIndex: 0,
              ),
            );

        final harness = serviceWith([
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_invalidRecipeArgsMissingTitle)),
            200,
          ),
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_invalidRecipeArgsMissingTitle)),
            200,
          ),
        ]);

        final result = await harness.service.generateForSlot(
          suggestionId: suggestionId,
          weeklyPlanId: weeklyPlanId,
          portions: 4,
        );

        expect(result, isA<GenerationFailure>());
        expect(
          (result as GenerationFailure).message,
          allOf(contains('twice'), contains('title: required')),
        );
        // Exactly one retry, not an unbounded loop.
        expect(harness.requestBodies, hasLength(2));

        final suggestion = await (db.select(
          db.suggestions,
        )..where((s) => s.id.equals(suggestionId))).getSingle();
        expect(suggestion.recipeId, isNull);
      },
    );

    test('proxy not configured surfaces a specific message', () async {
      // Deliberately no configureProxy() call.
      final weeklyPlanId = await db
          .into(db.weeklyPlans)
          .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
      final suggestionId = await db
          .into(db.suggestions)
          .insert(
            SuggestionsCompanion.insert(
              weeklyPlanId: weeklyPlanId,
              slotIndex: 0,
            ),
          );

      final harness = serviceWith([]);

      final result = await harness.service.generateForSlot(
        suggestionId: suggestionId,
        weeklyPlanId: weeklyPlanId,
        portions: 4,
      );

      expect(result, isA<GenerationFailure>());
      expect((result as GenerationFailure).message, contains('not configured'));
    });

    test('a relayed Bedrock error is surfaced verbatim', () async {
      await configureProxy();
      final weeklyPlanId = await db
          .into(db.weeklyPlans)
          .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
      final suggestionId = await db
          .into(db.suggestions)
          .insert(
            SuggestionsCompanion.insert(
              weeklyPlanId: weeklyPlanId,
              slotIndex: 0,
            ),
          );

      final harness = serviceWith([
        http.Response(
          jsonEncode({
            'error':
                'Bedrock AccessDeniedException: model not enabled in eu-west-2',
          }),
          403,
        ),
      ]);

      final result = await harness.service.generateForSlot(
        suggestionId: suggestionId,
        weeklyPlanId: weeklyPlanId,
        portions: 4,
      );

      expect(result, isA<GenerationFailure>());
      expect(
        (result as GenerationFailure).message,
        allOf(contains('403'), contains('model not enabled')),
      );
    });
  });

  group('startWeek', () {
    test(
      'fills every slot and tells later slots what earlier ones picked',
      () async {
        await configureProxy();

        final harness = serviceWith([
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
            200,
          ),
          http.Response(
            jsonEncode(
              _bedrockToolUseResponse({
                'title': 'Chicken traybake',
                'serves': 4,
                'method': 'Roast it.',
                'ingredients': [
                  {'name': 'chicken thighs', 'quantity': 4, 'unit': 'item'},
                ],
              }),
            ),
            200,
          ),
        ]);

        final (weeklyPlanId, results) = await harness.service.startWeek(
          portions: 4,
          mealCount: 2,
        );

        expect(results, hasLength(2));
        expect(results, everyElement(isA<GenerationSuccess>()));

        final suggestions =
            await (db.select(db.suggestions)
                  ..where((s) => s.weeklyPlanId.equals(weeklyPlanId))
                  ..orderBy([(s) => OrderingTerm.asc(s.slotIndex)]))
                .get();
        expect(suggestions, hasLength(2));
        expect(suggestions.every((s) => s.recipeId != null), isTrue);

        // The second call's prompt should mention the first slot's
        // recipe for within-week variety.
        final secondRequest =
            jsonDecode(harness.requestBodies[1]) as Map<String, dynamic>;
        final secondUserText =
            ((secondRequest['messages'] as List).first['content'] as List)
                    .first['text']
                as String;
        expect(secondUserText, contains('Buttered toast'));
      },
    );

    test('stops at the first failure rather than continuing blind', () async {
      await configureProxy();

      final harness = serviceWith([
        http.Response(
          jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
          200,
        ),
        http.Response(jsonEncode({'error': 'boom'}), 500),
      ]);

      final (weeklyPlanId, results) = await harness.service.startWeek(
        portions: 4,
        mealCount: 3,
      );

      expect(results, hasLength(2)); // stopped after the second (failed) slot
      expect(results[0], isA<GenerationSuccess>());
      expect(results[1], isA<GenerationFailure>());

      final suggestions = await (db.select(
        db.suggestions,
      )..where((s) => s.weeklyPlanId.equals(weeklyPlanId))).get();
      expect(suggestions, hasLength(3)); // all 3 slots exist...
      expect(
        suggestions.where((s) => s.recipeId != null),
        hasLength(1), // ...but only the first was actually filled
      );
    });
  });

  group('repeat cooldown', () {
    test(
      'accepted recipes within the cooldown window reach the prompt',
      () async {
        await configureProxy();

        // A recipe "cooked" (accepted) recently.
        final oldPlanId = await db
            .into(db.weeklyPlans)
            .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
        final oldRecipeId = await db
            .into(db.recipes)
            .insert(
              RecipesCompanion.insert(
                title: 'Sausage and mash',
                serves: 4,
                method: 'Cook it.',
                source: RecipeSource.llmSuggested,
              ),
            );
        await db
            .into(db.suggestions)
            .insert(
              SuggestionsCompanion.insert(
                weeklyPlanId: oldPlanId,
                slotIndex: 0,
                recipeId: Value(oldRecipeId),
                status: const Value(SuggestionStatus.accepted),
                updatedAt: Value(
                  DateTime.now().subtract(const Duration(days: 3)),
                ),
              ),
            );

        final newWeeklyPlanId = await db
            .into(db.weeklyPlans)
            .insert(WeeklyPlansCompanion.insert(portions: 4, mealCount: 1));
        final newSuggestionId = await db
            .into(db.suggestions)
            .insert(
              SuggestionsCompanion.insert(
                weeklyPlanId: newWeeklyPlanId,
                slotIndex: 0,
              ),
            );

        final harness = serviceWith([
          http.Response(
            jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
            200,
          ),
        ]);

        await harness.service.generateForSlot(
          suggestionId: newSuggestionId,
          weeklyPlanId: newWeeklyPlanId,
          portions: 4,
        );

        final requestBody =
            jsonDecode(harness.requestBodies.single) as Map<String, dynamic>;
        final userText =
            ((requestBody['messages'] as List).first['content'] as List)
                    .first['text']
                as String;
        expect(userText, contains('Cooked recently'));
        expect(userText, contains('Sausage and mash'));
      },
    );
  });
}
