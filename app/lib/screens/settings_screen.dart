import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';

/// Household defaults for portion count and meals per week — seeds
/// every new [WeeklyPlan], both overridable per week on the weekly
/// plan screen. See docs/planning/iterations.md, iteration 1.
class SettingsScreen extends StatefulWidget {
  /// [database] is injectable so tests can use an in-memory instance —
  /// see test/screens/settings_screen_test.dart.
  const SettingsScreen({super.key, AppDatabase? database})
    : _injectedDatabase = database;

  final AppDatabase? _injectedDatabase;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _db = widget._injectedDatabase ?? AppDatabase();

  final _portionsController = TextEditingController();
  final _mealsPerWeekController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _portionsController.dispose();
    _mealsPerWeekController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await (_db.select(
      _db.settings,
    )..where((s) => s.id.equals(0))).getSingle();
    if (!mounted) return;
    setState(() {
      _portionsController.text = settings.defaultPortions.toString();
      _mealsPerWeekController.text = settings.defaultMealsPerWeek.toString();
      _loading = false;
    });
  }

  /// Null if the field isn't a positive integer — callers show a
  /// specific error instead of silently ignoring it or saving garbage.
  int? _parsePositiveInt(String text) {
    final value = int.tryParse(text.trim());
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _save() async {
    final portions = _parsePositiveInt(_portionsController.text);
    final mealsPerWeek = _parsePositiveInt(_mealsPerWeekController.text);
    if (portions == null || mealsPerWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Portions and meals per week must both be whole numbers greater than zero.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await (_db.update(_db.settings)..where((s) => s.id.equals(0))).write(
      SettingsCompanion(
        defaultPortions: Value(portions),
        defaultMealsPerWeek: Value(mealsPerWeek),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _portionsController,
            decoration: const InputDecoration(
              labelText: 'Default portions',
              helperText:
                  'Applies to every meal in a week — no per-meal override.',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mealsPerWeekController,
            decoration: const InputDecoration(
              labelText: 'Default meals per week',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }
}
