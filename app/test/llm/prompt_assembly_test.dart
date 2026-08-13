import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/llm/prompt_assembly.dart';
import 'package:gusteau/llm/recipe_schema.dart';

void main() {
  group('buildRecipeGenerationRequest', () {
    test('always forces the submit_recipe tool', () {
      final request = buildRecipeGenerationRequest(portions: 4);

      final toolConfig = request['toolConfig'] as Map;
      expect(toolConfig['toolChoice'], {
        'tool': {'name': kSubmitRecipeToolName},
      });
      final tools = toolConfig['tools'] as List;
      expect(tools, [kSubmitRecipeToolSpec]);
    });

    test('the portion count reaches the user message', () {
      final request = buildRecipeGenerationRequest(portions: 6);

      final userText =
          ((request['messages'] as List).first['content'] as List).first['text']
              as String;
      expect(userText, contains('6 portions'));
    });

    test('with nothing recent or planned, the prompt stays minimal', () {
      final request = buildRecipeGenerationRequest(portions: 4);

      final userText =
          ((request['messages'] as List).first['content'] as List).first['text']
              as String;
      expect(userText, isNot(contains('Cooked recently')));
      expect(userText, isNot(contains('Already planned')));
    });

    test('recently-cooked recipes are named for the cooldown', () {
      final request = buildRecipeGenerationRequest(
        portions: 4,
        recentlyCooked: [
          const RecentRecipeSummary(
            title: 'Chicken thigh traybake with fennel and lemon',
            primaryProtein: 'chicken',
            cookingMethod: 'roasting',
            cuisine: 'British',
          ),
        ],
      );

      final userText =
          ((request['messages'] as List).first['content'] as List).first['text']
              as String;
      expect(userText, contains('Cooked recently'));
      expect(
        userText,
        contains(
          'Chicken thigh traybake with fennel and lemon (British, '
          'chicken, roasting)',
        ),
      );
    });

    test('already-picked slots are named for within-week variety', () {
      final request = buildRecipeGenerationRequest(
        portions: 4,
        alreadyPickedThisWeek: [
          const RecentRecipeSummary(title: 'Buttered toast'),
        ],
      );

      final userText =
          ((request['messages'] as List).first['content'] as List).first['text']
              as String;
      expect(userText, contains('Already planned'));
      expect(userText, contains('Buttered toast'));
    });
  });

  group('buildRecipeGenerationRetryRequest', () {
    test('appends the assistant turn and an error toolResult', () {
      final original = buildRecipeGenerationRequest(portions: 4);
      final assistantMessage = {
        'role': 'assistant',
        'content': [
          {
            'toolUse': {
              'toolUseId': 'abc123',
              'name': kSubmitRecipeToolName,
              'input': {'title': 'Broken recipe'},
            },
          },
        ],
      };

      final retry = buildRecipeGenerationRetryRequest(
        previousRequest: original,
        assistantMessage: assistantMessage,
        toolUseId: 'abc123',
        validationError: 'serves: required, but missing',
      );

      final messages = retry['messages'] as List;
      // Original user message, the assistant's invalid call, and the
      // error toolResult — nothing dropped, nothing extra.
      expect(messages, hasLength(3));
      expect(messages[1], assistantMessage);

      final toolResultContent = (messages[2] as Map)['content'] as List;
      final toolResult = (toolResultContent.first as Map)['toolResult'] as Map;
      expect(toolResult['toolUseId'], 'abc123');
      expect(toolResult['status'], 'error');
      final resultText =
          ((toolResult['content'] as List).first as Map)['text'] as String;
      expect(resultText, contains('serves: required, but missing'));

      // toolConfig carries over unchanged — same tool, still forced.
      expect(retry['toolConfig'], original['toolConfig']);
    });
  });
}
