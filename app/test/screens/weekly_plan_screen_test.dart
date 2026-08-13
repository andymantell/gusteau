import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/api/proxy_client.dart';
import 'package:gusteau/api/proxy_credentials.dart';
import 'package:gusteau/data/database.dart';
import 'package:gusteau/llm/suggestion_service.dart';
import 'package:gusteau/screens/weekly_plan_screen.dart';
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
    final credentials = ProxyCredentials();
    await credentials.save(baseUrl: 'https://example.com/prod', apiKey: 'k');
  });

  tearDown(() async {
    await db.close();
  });

  SuggestionService serviceWith(List<http.Response> responses) {
    var callIndex = 0;
    final proxyClient = ProxyClient(
      credentials: ProxyCredentials(),
      httpClient: MockClient((_) async {
        final response = responses[callIndex];
        callIndex++;
        return response;
      }),
    );
    return SuggestionService(db: db, proxyClient: proxyClient);
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    required SuggestionService suggestionService,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WeeklyPlanScreen(
          database: db,
          suggestionService: suggestionService,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with no week planned yet, shows the empty state', (
    tester,
  ) async {
    await pumpScreen(tester, suggestionService: serviceWith([]));

    expect(find.text('No week planned yet.'), findsOneWidget);
    expect(find.text('Plan this week'), findsOneWidget);
  });

  testWidgets('planning a week generates and shows a slot', (tester) async {
    await pumpScreen(
      tester,
      suggestionService: serviceWith([
        http.Response(
          jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
          200,
        ),
      ]),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Plan a single-meal week so the test only needs one mocked call.
    await tester.enterText(
      find.widgetWithText(TextField, 'Meals this week'),
      '1',
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Buttered toast'), findsOneWidget);
  });

  testWidgets('a generation failure is shown on the slot', (tester) async {
    await pumpScreen(
      tester,
      suggestionService: serviceWith([
        http.Response(jsonEncode({'error': 'boom'}), 500),
      ]),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Meals this week'),
      '1',
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.textContaining('500'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets('refreshing a filled slot replaces its recipe', (tester) async {
    await pumpScreen(
      tester,
      suggestionService: serviceWith([
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
      ]),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Meals this week'),
      '1',
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Buttered toast'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(find.text('Chicken traybake'), findsOneWidget);
    expect(find.text('Buttered toast'), findsNothing);
  });

  testWidgets('accepting a slot marks it as cooked', (tester) async {
    await pumpScreen(
      tester,
      suggestionService: serviceWith([
        http.Response(
          jsonEncode(_bedrockToolUseResponse(_validRecipeArgs)),
          200,
        ),
      ]),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Meals this week'),
      '1',
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });
}
