import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/api/proxy_client.dart';
import 'package:gusteau/api/proxy_credentials.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('not configured: no request is made at all', () async {
    var called = false;
    final client = ProxyClient(
      httpClient: MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    final result = await client.checkHealth();

    expect(result, isA<ProxyHealthNotConfigured>());
    expect(called, isFalse);
  });

  test('200 with a valid JSON body: success, decoded', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: 'https://example.com/prod', apiKey: 'my-key');

    Uri? requestedUri;
    String? apiKeyHeader;
    final client = ProxyClient(
      credentials: creds,
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        apiKeyHeader = request.headers['x-api-key'];
        return http.Response('{"status":"ok","service":"gusteau"}', 200);
      }),
    );

    final result = await client.checkHealth();

    expect(result, isA<ProxyHealthSuccess>());
    result as ProxyHealthSuccess;
    expect(result.statusCode, 200);
    expect(result.body, {'status': 'ok', 'service': 'gusteau'});

    // The API key is what gates access to the whole endpoint — see
    // architecture.md, "Backend — AWS, CDK (Python)" — so it must
    // actually be sent, not just stored.
    expect(apiKeyHeader, 'my-key');
    expect(requestedUri, Uri.parse('https://example.com/prod/health'));
  });

  test('non-200 response: the real status and body are surfaced', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: 'https://example.com/prod', apiKey: 'wrong-key');

    final client = ProxyClient(
      credentials: creds,
      httpClient: MockClient(
        (request) async => http.Response('{"message":"Forbidden"}', 403),
      ),
    );

    final result = await client.checkHealth();

    expect(result, isA<ProxyHealthHttpError>());
    result as ProxyHealthHttpError;
    expect(result.statusCode, 403);
    expect(result.body, contains('Forbidden'));
  });

  test(
    'network failure: the real exception is surfaced, not swallowed',
    () async {
      final creds = ProxyCredentials();
      await creds.save(baseUrl: 'https://example.com/prod', apiKey: 'k');

      final thrown = Exception('Failed host lookup');
      final client = ProxyClient(
        credentials: creds,
        httpClient: MockClient((request) async => throw thrown),
      );

      final result = await client.checkHealth();

      expect(result, isA<ProxyHealthNetworkError>());
      expect((result as ProxyHealthNetworkError).error, thrown);
    },
  );

  test('200 with an unparseable body: surfaced, not a crash', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: 'https://example.com/prod', apiKey: 'k');

    final client = ProxyClient(
      credentials: creds,
      httpClient: MockClient((request) async => http.Response('not json', 200)),
    );

    final result = await client.checkHealth();

    expect(result, isA<ProxyHealthHttpError>());
    expect((result as ProxyHealthHttpError).body, 'not json');
  });
}
