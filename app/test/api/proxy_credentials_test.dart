import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/api/proxy_credentials.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('nothing configured yet: both reads are null', () async {
    final creds = ProxyCredentials();
    expect(await creds.readBaseUrl(), isNull);
    expect(await creds.readApiKey(), isNull);
  });

  test('save then read round-trips both values', () async {
    final creds = ProxyCredentials();
    await creds.save(
      baseUrl: 'https://abc123.execute-api.eu-west-2.amazonaws.com/prod',
      apiKey: 'super-secret-key',
    );

    expect(
      await creds.readBaseUrl(),
      'https://abc123.execute-api.eu-west-2.amazonaws.com/prod',
    );
    expect(await creds.readApiKey(), 'super-secret-key');
  });

  test('trailing slashes on the base URL are stripped', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: 'https://example.com/prod///', apiKey: 'k');

    expect(await creds.readBaseUrl(), 'https://example.com/prod');
  });

  test('surrounding whitespace is trimmed from both values', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: '  https://example.com/prod  ', apiKey: '  k  ');

    expect(await creds.readBaseUrl(), 'https://example.com/prod');
    expect(await creds.readApiKey(), 'k');
  });

  test('clear removes both values', () async {
    final creds = ProxyCredentials();
    await creds.save(baseUrl: 'https://example.com', apiKey: 'k');
    await creds.clear();

    expect(await creds.readBaseUrl(), isNull);
    expect(await creds.readApiKey(), isNull);
  });
}
