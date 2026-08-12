import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/api/proxy_client.dart';
import 'package:gusteau/api/proxy_credentials.dart';
import 'package:gusteau/screens/connection_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required ProxyCredentials credentials,
    required http.Client httpClient,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectionScreen(
          credentials: credentials,
          client: ProxyClient(credentials: credentials, httpClient: httpClient),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'starts empty, and testing the connection reports not configured',
    (tester) async {
      final credentials = ProxyCredentials();
      await pumpScreen(
        tester,
        credentials: credentials,
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(find.widgetWithText(TextField, 'Proxy base URL'), findsOneWidget);

      await tester.tap(find.text('Test connection'));
      await tester.pumpAndSettle();

      expect(find.text('Not configured'), findsOneWidget);
    },
  );

  testWidgets('save persists both fields via ProxyCredentials', (tester) async {
    final credentials = ProxyCredentials();
    await pumpScreen(
      tester,
      credentials: credentials,
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Proxy base URL'),
      'https://example.com/prod',
    );
    await tester.enterText(find.widgetWithText(TextField, 'API key'), 'my-key');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved.'), findsOneWidget);
    expect(await credentials.readBaseUrl(), 'https://example.com/prod');
    expect(await credentials.readApiKey(), 'my-key');
  });

  testWidgets('previously saved credentials are loaded into the fields', (
    tester,
  ) async {
    final credentials = ProxyCredentials();
    await credentials.save(baseUrl: 'https://saved.example.com', apiKey: 'k');

    await pumpScreen(
      tester,
      credentials: credentials,
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(find.text('https://saved.example.com'), findsOneWidget);
  });

  testWidgets('a successful health check shows the response, decoded', (
    tester,
  ) async {
    final credentials = ProxyCredentials();
    await credentials.save(baseUrl: 'https://example.com/prod', apiKey: 'k');

    await pumpScreen(
      tester,
      credentials: credentials,
      httpClient: MockClient(
        (_) async => http.Response('{"status":"ok"}', 200),
      ),
    );

    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Connected'), findsOneWidget);
    expect(find.textContaining('"status": "ok"'), findsOneWidget);
  });

  testWidgets('a real HTTP error is shown plainly, not paraphrased', (
    tester,
  ) async {
    final credentials = ProxyCredentials();
    await credentials.save(baseUrl: 'https://example.com/prod', apiKey: 'k');

    await pumpScreen(
      tester,
      credentials: credentials,
      httpClient: MockClient(
        (_) async => http.Response('{"message":"Forbidden"}', 403),
      ),
    );

    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.text('HTTP 403'), findsOneWidget);
    expect(find.textContaining('Forbidden'), findsOneWidget);
  });
}
