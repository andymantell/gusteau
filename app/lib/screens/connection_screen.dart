import 'dart:convert';

import 'package:flutter/material.dart';

import '../api/proxy_client.dart';
import '../api/proxy_credentials.dart';

/// Iteration 0's whole job: prove the app can reach the inference proxy.
///
/// The base URL and API key are entered here once, by hand, after
/// `cdk deploy` — see docs/planning/ci-cd.md, "The handoff between the
/// two pipelines". Real recipe generation replaces the "test connection"
/// button in iteration 1; this screen (or what it becomes) is likely to
/// end up folded into general settings rather than staying standalone.
class ConnectionScreen extends StatefulWidget {
  /// [credentials] and [client] are injectable so tests can control
  /// storage and HTTP without a real device or network — see
  /// test/screens/connection_screen_test.dart.
  const ConnectionScreen({
    super.key,
    ProxyCredentials? credentials,
    ProxyClient? client,
  }) : _injectedCredentials = credentials,
       _injectedClient = client;

  final ProxyCredentials? _injectedCredentials;
  final ProxyClient? _injectedClient;

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late final _credentials = widget._injectedCredentials ?? ProxyCredentials();
  late final _client =
      widget._injectedClient ?? ProxyClient(credentials: _credentials);

  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();

  bool _saving = false;
  bool _checking = false;
  ProxyHealthResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final baseUrl = await _credentials.readBaseUrl();
    final apiKey = await _credentials.readApiKey();
    if (!mounted) return;
    setState(() {
      _baseUrlController.text = baseUrl ?? '';
      _apiKeyController.text = apiKey ?? '';
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _credentials.save(
      baseUrl: _baseUrlController.text,
      apiKey: _apiKeyController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved.')));
  }

  Future<void> _testConnection() async {
    setState(() {
      _checking = true;
      _lastResult = null;
    });
    final result = await _client.checkHealth();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _lastResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gusteau — connection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Proxy base URL',
              hintText:
                  'https://xxxxxxxxxx.execute-api.eu-west-2.amazonaws.com/prod',
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(labelText: 'API key'),
            obscureText: true,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _checking ? null : _testConnection,
                child: Text(_checking ? 'Checking…' : 'Test connection'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_lastResult != null) _ResultCard(result: _lastResult!),
        ],
      ),
    );
  }
}

/// Shows the real outcome — status codes and exception text, on screen
/// and copyable — rather than a generic "something went wrong". See
/// docs/planning/architecture.md, "Error handling": "one user, who is
/// also the developer... errors say exactly what happened".
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ProxyHealthResult result;

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      ProxyHealthNotConfigured() => const _Outcome(
        icon: Icons.info_outline,
        color: Colors.blueGrey,
        title: 'Not configured',
        detail:
            'Enter the proxy base URL and API key above, then Save, '
            'before testing the connection.',
      ),
      ProxyHealthSuccess(:final statusCode, :final body) => _Outcome(
        icon: Icons.check_circle_outline,
        color: Colors.green,
        title: 'Connected (HTTP $statusCode)',
        detail: const JsonEncoder.withIndent('  ').convert(body),
      ),
      ProxyHealthHttpError(:final statusCode, :final body) => _Outcome(
        icon: Icons.error_outline,
        color: Colors.red,
        title: 'HTTP $statusCode',
        detail: body,
      ),
      ProxyHealthNetworkError(:final error) => _Outcome(
        icon: Icons.wifi_off,
        color: Colors.red,
        title: 'Network error',
        detail: error.toString(),
      ),
    };
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Selectable so the real error can actually be copied out —
            // not just read.
            SelectableText(
              detail,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
