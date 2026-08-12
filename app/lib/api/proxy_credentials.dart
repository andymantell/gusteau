import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where the app's inference proxy URL and API key live.
///
/// Both are entered once, by hand, after `cdk deploy` — see
/// docs/planning/ci-cd.md, "The handoff between the two pipelines".
/// Deliberately not baked into the APK at build time: that would put a
/// credential in a public build artifact and couple the app and infra
/// pipelines together (a redeploy would force an app rebuild just to
/// pick up a new URL).
///
/// Backed by [FlutterSecureStorage], which on Android uses
/// EncryptedSharedPreferences keyed by the Android Keystore — see
/// architecture.md, "Backend — AWS, CDK (Python)": "an API key... stored
/// in the Android Keystore". The base URL isn't sensitive on its own,
/// but there's no reason to treat it differently from the key.
class ProxyCredentials {
  ProxyCredentials({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _baseUrlKey = 'proxy_base_url';
  static const _apiKeyKey = 'proxy_api_key';

  Future<String?> readBaseUrl() => _storage.read(key: _baseUrlKey);
  Future<String?> readApiKey() => _storage.read(key: _apiKeyKey);

  Future<void> save({required String baseUrl, required String apiKey}) async {
    // Trim trailing slashes so callers can join paths with a plain
    // '$baseUrl/health' without worrying about a double slash.
    final normalised = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    await _storage.write(key: _baseUrlKey, value: normalised);
    await _storage.write(key: _apiKeyKey, value: apiKey.trim());
  }

  Future<void> clear() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
  }
}
