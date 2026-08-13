import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/llm/converse_response.dart';

void main() {
  test('extracts a tool-use call from a well-formed response', () {
    final call = extractToolUseCall({
      'stopReason': 'tool_use',
      'output': {
        'message': {
          'role': 'assistant',
          'content': [
            {'text': 'Sure, here you go:'},
            {
              'toolUse': {
                'toolUseId': 'tool-1',
                'name': 'submit_recipe',
                'input': {'title': 'Toast'},
              },
            },
          ],
        },
      },
    });

    expect(call.toolUseId, 'tool-1');
    expect(call.toolName, 'submit_recipe');
    expect(call.input, {'title': 'Toast'});
  });

  test('throws when the model never calls a tool', () {
    expect(
      () => extractToolUseCall({
        'stopReason': 'end_turn',
        'output': {
          'message': {
            'role': 'assistant',
            'content': [
              {'text': "I'd rather not."},
            ],
          },
        },
      }),
      throwsA(
        isA<ConverseResponseException>().having(
          (e) => e.message,
          'message',
          contains('did not call a tool'),
        ),
      ),
    );
  });

  test('throws when the response has no message content at all', () {
    expect(
      () => extractToolUseCall({'stopReason': 'max_tokens', 'output': {}}),
      throwsA(isA<ConverseResponseException>()),
    );
  });

  test('throws on a malformed toolUse block', () {
    expect(
      () => extractToolUseCall({
        'stopReason': 'tool_use',
        'output': {
          'message': {
            'content': [
              {
                'toolUse': {'name': 'submit_recipe'}, // missing toolUseId/input
              },
            ],
          },
        },
      }),
      throwsA(isA<ConverseResponseException>()),
    );
  });
}
