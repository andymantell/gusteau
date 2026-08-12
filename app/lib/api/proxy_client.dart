import 'dart:convert';

import 'package:http/http.dart' as http;

import 'proxy_credentials.dart';

/// Result of a round trip to the inference proxy.
///
/// Deliberately not collapsed into a single "did it work" boolean with a
/// generic error string: the app is meant to show the real failure, not
/// a vague one — see docs/planning/architecture.md, "Error handling",
/// and the owner's explicit ask that errors "say it how it is".
sealed class ProxyHealthResult {}

class ProxyHealthSuccess extends ProxyHealthResult {
  ProxyHealthSuccess({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}

/// The base URL / API key haven't been entered yet (see
/// [ProxyCredentials]) — distinct from a network failure, since the fix
/// is "go to settings", not "retry".
class ProxyHealthNotConfigured extends ProxyHealthResult {}

/// The proxy answered, but not with 200 — a throttle, an auth failure
/// from a wrong/rotated key, or a server error. Carries the real status
/// and body rather than translating it into prose.
class ProxyHealthHttpError extends ProxyHealthResult {
  ProxyHealthHttpError({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

/// Never reached the proxy at all — DNS, TLS, timeout, no connectivity.
/// Carries the real exception, shown as-is rather than paraphrased.
class ProxyHealthNetworkError extends ProxyHealthResult {
  ProxyHealthNetworkError(this.error);

  final Object error;
}

/// Talks to Gusteau's one AWS endpoint — the inference proxy in front of
/// Bedrock. Iteration 0 only proves the round trip via `/health`; real
/// generation calls land here in iteration 1 once the model-tier spike
/// has picked a model. See docs/planning/architecture.md, "Backend —
/// AWS, CDK (Python)".
class ProxyClient {
  ProxyClient({ProxyCredentials? credentials, http.Client? httpClient})
    : _credentials = credentials ?? ProxyCredentials(),
      _httpClient = httpClient ?? http.Client();

  final ProxyCredentials _credentials;
  final http.Client _httpClient;

  Future<ProxyHealthResult> checkHealth() async {
    final baseUrl = await _credentials.readBaseUrl();
    final apiKey = await _credentials.readApiKey();
    if (baseUrl == null ||
        baseUrl.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty) {
      return ProxyHealthNotConfigured();
    }

    final http.Response response;
    try {
      response = await _httpClient
          .get(Uri.parse('$baseUrl/health'), headers: {'x-api-key': apiKey})
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      return ProxyHealthNetworkError(e);
    }

    if (response.statusCode != 200) {
      return ProxyHealthHttpError(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // A 200 with an unparseable body is still worth showing plainly
      // rather than crashing on the cast — surfaced as an HTTP-shaped
      // error so the raw body is visible.
      return ProxyHealthHttpError(statusCode: 200, body: response.body);
    }

    return ProxyHealthSuccess(statusCode: response.statusCode, body: decoded);
  }
}
