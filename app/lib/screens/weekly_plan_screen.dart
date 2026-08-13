import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/tables/suggestions_table.dart';
import '../llm/suggestion_service.dart';

/// The current week's meals: a fixed number of slots, each either
/// pending, filled with a suggested recipe, or showing why generating
/// it failed. See docs/planning/iterations.md, iteration 1.
class WeeklyPlanScreen extends StatefulWidget {
  /// [database]/[suggestionService] are injectable so tests can control
  /// storage and the (mocked) proxy without a real device or network —
  /// see test/screens/weekly_plan_screen_test.dart.
  const WeeklyPlanScreen({
    super.key,
    AppDatabase? database,
    SuggestionService? suggestionService,
  }) : _injectedDatabase = database,
       _injectedSuggestionService = suggestionService;

  final AppDatabase? _injectedDatabase;
  final SuggestionService? _injectedSuggestionService;

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  late final _db = widget._injectedDatabase ?? AppDatabase();
  late final _suggestionService =
      widget._injectedSuggestionService ?? SuggestionService(db: _db);

  bool _loading = true;
  bool _startingWeek = false;
  final Set<int> _refreshingSlotIds = {};
  final Map<int, String> _slotErrors = {};

  WeeklyPlan? _currentPlan;
  List<Suggestion> _slots = [];
  Map<int, Recipe> _recipesById = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    setState(() => _loading = true);
    final plans =
        await (_db.select(_db.weeklyPlans)
              ..orderBy([(p) => OrderingTerm.desc(p.id)])
              ..limit(1))
            .get();
    if (plans.isEmpty) {
      if (!mounted) return;
      setState(() {
        _currentPlan = null;
        _slots = [];
        _loading = false;
      });
      return;
    }
    await _loadSlotsFor(plans.first);
  }

  Future<void> _loadSlotsFor(WeeklyPlan plan) async {
    final slots =
        await (_db.select(_db.suggestions)
              ..where((s) => s.weeklyPlanId.equals(plan.id))
              ..orderBy([(s) => OrderingTerm.asc(s.slotIndex)]))
            .get();
    final recipeIds = slots.map((s) => s.recipeId).whereType<int>().toList();
    final recipes = recipeIds.isEmpty
        ? <Recipe>[]
        : await (_db.select(
            _db.recipes,
          )..where((r) => r.id.isIn(recipeIds))).get();

    if (!mounted) return;
    setState(() {
      _currentPlan = plan;
      _slots = slots;
      _recipesById = {for (final r in recipes) r.id: r};
      _loading = false;
    });
  }

  Future<void> _startNewWeek() async {
    final settings = await (_db.select(
      _db.settings,
    )..where((s) => s.id.equals(0))).getSingle();

    if (!mounted) return;
    final planned = await showDialog<({int portions, int mealCount})>(
      context: context,
      builder: (context) => _PlanWeekDialog(
        initialPortions: settings.defaultPortions,
        initialMealCount: settings.defaultMealsPerWeek,
      ),
    );
    if (planned == null) return;

    setState(() {
      _startingWeek = true;
      _slotErrors.clear();
    });

    final (weeklyPlanId, results) = await _suggestionService.startWeek(
      portions: planned.portions,
      mealCount: planned.mealCount,
    );

    if (!mounted) return;
    final plan = await (_db.select(
      _db.weeklyPlans,
    )..where((p) => p.id.equals(weeklyPlanId))).getSingle();
    await _loadSlotsFor(plan);
    if (!mounted) return;

    final failure = results.whereType<GenerationFailure>().firstOrNull;
    setState(() {
      _startingWeek = false;
      if (failure != null) {
        // The failed slot is the one still without a recipeId after
        // reload — surfaced there rather than as a generic banner, so
        // it's obvious which meal needs a manual refresh.
        final failedSlot = _slots.where((s) => s.recipeId == null).firstOrNull;
        if (failedSlot != null) {
          _slotErrors[failedSlot.id] = failure.message;
        }
      }
    });
  }

  Future<void> _refreshSlot(int suggestionId) async {
    setState(() {
      _refreshingSlotIds.add(suggestionId);
      _slotErrors.remove(suggestionId);
    });

    final result = await _suggestionService.refreshSlot(suggestionId);

    if (!mounted) return;
    if (result is GenerationFailure) {
      setState(() {
        _refreshingSlotIds.remove(suggestionId);
        _slotErrors[suggestionId] = result.message;
      });
      return;
    }

    if (_currentPlan != null) {
      await _loadSlotsFor(_currentPlan!);
    }
    if (!mounted) return;
    setState(() => _refreshingSlotIds.remove(suggestionId));
  }

  Future<void> _acceptSlot(int suggestionId) async {
    await (_db.update(
      _db.suggestions,
    )..where((s) => s.id.equals(suggestionId))).write(
      SuggestionsCompanion(
        status: const Value(SuggestionStatus.accepted),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (_currentPlan != null) {
      await _loadSlotsFor(_currentPlan!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('This week'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Plan a new week',
            onPressed: _startingWeek ? null : _startNewWeek,
          ),
        ],
      ),
      body: _currentPlan == null
          ? _EmptyState(starting: _startingWeek, onStart: _startNewWeek)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final slot in _slots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SlotCard(
                      slot: slot,
                      recipe: slot.recipeId != null
                          ? _recipesById[slot.recipeId]
                          : null,
                      refreshing: _refreshingSlotIds.contains(slot.id),
                      error: _slotErrors[slot.id],
                      onRefresh: () => _refreshSlot(slot.id),
                      onAccept: () => _acceptSlot(slot.id),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.starting, required this.onStart});

  final bool starting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No week planned yet.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: starting ? null : onStart,
            child: Text(starting ? 'Planning…' : 'Plan this week'),
          ),
        ],
      ),
    );
  }
}

class _PlanWeekDialog extends StatefulWidget {
  const _PlanWeekDialog({
    required this.initialPortions,
    required this.initialMealCount,
  });

  final int initialPortions;
  final int initialMealCount;

  @override
  State<_PlanWeekDialog> createState() => _PlanWeekDialogState();
}

class _PlanWeekDialogState extends State<_PlanWeekDialog> {
  late final _portionsController = TextEditingController(
    text: widget.initialPortions.toString(),
  );
  late final _mealCountController = TextEditingController(
    text: widget.initialMealCount.toString(),
  );

  @override
  void dispose() {
    _portionsController.dispose();
    _mealCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Plan this week'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _portionsController,
            decoration: const InputDecoration(labelText: 'Portions'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mealCountController,
            decoration: const InputDecoration(labelText: 'Meals this week'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final portions = int.tryParse(_portionsController.text.trim());
            final mealCount = int.tryParse(_mealCountController.text.trim());
            if (portions == null ||
                portions <= 0 ||
                mealCount == null ||
                mealCount <= 0) {
              return;
            }
            Navigator.of(context)
                .pop((portions: portions, mealCount: mealCount));
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.recipe,
    required this.refreshing,
    required this.error,
    required this.onRefresh,
    required this.onAccept,
  });

  final Suggestion slot;
  final Recipe? recipe;
  final bool refreshing;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onAccept;

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
                Expanded(
                  child: refreshing
                      ? const Text('Generating…')
                      : Text(
                          recipe?.title ?? 'Not generated yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
                if (slot.status == SuggestionStatus.accepted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (recipe != null && !refreshing)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Mark as cooked',
                    onPressed: onAccept,
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Suggest something else',
                  onPressed: refreshing ? null : onRefresh,
                ),
              ],
            ),
            if (recipe != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  recipe!.cuisine,
                  recipe!.cookingMethod,
                  if (recipe!.timeMinutes != null) '${recipe!.timeMinutes} min',
                ].whereType<String>().join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              // Selectable so the real error can actually be copied out
              // — see architecture.md, "Error handling".
              SelectableText(
                error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
