import 'recipe_schema.dart';

/// A recipe worth mentioning in a generation prompt, without sending
/// the whole thing — title plus a few key attributes, cheap in tokens.
/// See docs/planning/architecture.md, "Repeat cooldown": "Titles plus
/// a few key attributes, not full recipes, so it stays cheap."
class RecentRecipeSummary {
  const RecentRecipeSummary({
    required this.title,
    this.primaryProtein,
    this.cookingMethod,
    this.cuisine,
  });

  final String title;
  final String? primaryProtein;
  final String? cookingMethod;
  final String? cuisine;

  String describe() {
    final tags = [
      cuisine,
      primaryProtein,
      cookingMethod,
    ].whereType<String>().toList();
    return tags.isEmpty ? title : '$title (${tags.join(', ')})';
  }
}

// Shared house style for every recipe, regardless of which capability
// produces it — see architecture.md, "Shared house style: how recipes
// get written".
const String _houseStyle =
    '''
You are helping plan home-cooked dinners. When asked to suggest a recipe, call the $kSubmitRecipeToolName tool with exactly one recipe.

House style for every recipe:
- method: written for a competent home cook, not a beginner. No narrating basic technique, no padding. Include whatever actually varies dish-to-dish and would trip someone up recreating it blind: specific temperatures and times, ordering that matters, and any step that's easy to get wrong for this particular dish.
- ingredients: specified precisely enough to buy, not just to cook. "500g beef mince, 12% fat" rather than "mince"; "chicken thighs, boneless and skinless" rather than "chicken". Be explicit even where a human recipe writer wouldn't bother.
- Include the structured attributes (cuisine, cooking_method, primary_protein, difficulty, time_minutes) and a rough per-portion nutrition estimate (kcal_per_portion, protein_g_per_portion, fat_g_per_portion, carbs_g_per_portion) — informational only, it's fine to be approximate.
- For fuzzy amounts ("salt to taste", "a splash of oil"), omit quantity and unit entirely and use the note field instead — don't invent a number just to fill the field.
''';

String _buildUserAsk({
  required int portions,
  required List<RecentRecipeSummary> recentlyCooked,
  required List<RecentRecipeSummary> alreadyPickedThisWeek,
}) {
  final buffer = StringBuffer()
    ..writeln('Suggest one dinner recipe, serving $portions portions.');

  if (alreadyPickedThisWeek.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        "Already planned for other meals this week — aim for variety "
        'against these, not another version of the same thing:',
      );
    for (final r in alreadyPickedThisWeek) {
      buffer.writeln('- ${r.describe()}');
    }
  }

  if (recentlyCooked.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        'Cooked recently — do not repeat these or anything close to '
        'them (the same dish described in different words still '
        'counts as a repeat):',
      );
    for (final r in recentlyCooked) {
      buffer.writeln('- ${r.describe()}');
    }
  }

  return buffer.toString();
}

/// Builds the Bedrock Converse request body for one recipe generation
/// call. One call per meal slot, not one call for the whole week — see
/// docs/planning/decisions.md, "Favourites, and how a week gets
/// filled": each slot is told what's already been picked elsewhere in
/// the week, and a per-suggestion refresh reuses this exact same call
/// shape. See architecture.md, "Recipe suggestion generation" and
/// "Repeat cooldown".
Map<String, dynamic> buildRecipeGenerationRequest({
  required int portions,
  List<RecentRecipeSummary> recentlyCooked = const [],
  List<RecentRecipeSummary> alreadyPickedThisWeek = const [],
}) {
  return {
    'system': [
      {'text': _houseStyle},
    ],
    'messages': [
      {
        'role': 'user',
        'content': [
          {
            'text': _buildUserAsk(
              portions: portions,
              recentlyCooked: recentlyCooked,
              alreadyPickedThisWeek: alreadyPickedThisWeek,
            ),
          },
        ],
      },
    ],
    'toolConfig': {
      'tools': [kSubmitRecipeToolSpec],
      'toolChoice': {
        'tool': {'name': kSubmitRecipeToolName},
      },
    },
  };
}

/// Builds the single automatic retry request after [ParsedRecipe]
/// validation fails, feeding the validation error back to the model —
/// see architecture.md, "Validate on-device anyway, and retry once".
/// Appends the assistant's (invalid) tool-use turn and a `toolResult`
/// reporting the failure, per Bedrock Converse's tool-error-correction
/// pattern, rather than starting a fresh conversation from scratch.
Map<String, dynamic> buildRecipeGenerationRetryRequest({
  required Map<String, dynamic> previousRequest,
  required Map<String, dynamic> assistantMessage,
  required String toolUseId,
  required String validationError,
}) {
  final messages = List<Map<String, dynamic>>.from(
    (previousRequest['messages'] as List).cast<Map<String, dynamic>>(),
  );
  messages.add(assistantMessage);
  messages.add({
    'role': 'user',
    'content': [
      {
        'toolResult': {
          'toolUseId': toolUseId,
          'status': 'error',
          'content': [
            {
              'text':
                  'Invalid $kSubmitRecipeToolName call: $validationError. '
                  'Call the tool again with a corrected recipe.',
            },
          ],
        },
      },
    ],
  });

  return {...previousRequest, 'messages': messages};
}
