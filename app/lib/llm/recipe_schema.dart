/// The Bedrock tool-use schema for `Recipe`, per
/// docs/planning/architecture.md, "The structured-output contract".
///
/// Recipes are requested via tool-use rather than "please reply in
/// JSON" — this is what the model is constrained to emit arguments
/// against. Shared by both the on-device prompt assembly (which
/// includes it in the `toolConfig` sent to the proxy) and
/// [ParsedRecipe]'s validation, so the two can never drift apart.
library;

const List<String> kIngredientUnits = [
  'g',
  'kg',
  'ml',
  'l',
  'tsp',
  'tbsp',
  'item',
];

const List<String> kRecipeDifficulties = ['easy', 'medium', 'hard'];

const String kSubmitRecipeToolName = 'submit_recipe';

/// A Bedrock Converse `toolSpec`, ready to drop into a `toolConfig`.
/// See docs/planning/architecture.md, "Use constrained generation, not
/// 'please reply in JSON'".
const Map<String, dynamic> kSubmitRecipeToolSpec = {
  'toolSpec': {
    'name': kSubmitRecipeToolName,
    'description':
        'Submit exactly one recipe matching the requested brief. '
        'Ingredients must be specified precisely enough to buy, not '
        'just to cook (e.g. "beef mince, 12% fat", not "mince").',
    'inputSchema': {
      'json': {
        'type': 'object',
        'properties': {
          'title': {'type': 'string'},
          'serves': {'type': 'integer'},
          'method': {
            'type': 'string',
            'description':
                'Written for a competent home cook — no narrating basic '
                'technique. Include whatever actually varies dish-to-dish: '
                'specific temperatures/times, ordering that matters, steps '
                'easy to get wrong for this dish.',
          },
          'cuisine': {'type': 'string'},
          'time_minutes': {'type': 'integer'},
          'difficulty': {'type': 'string', 'enum': kRecipeDifficulties},
          'primary_protein': {'type': 'string'},
          'cooking_method': {'type': 'string'},
          'kcal_per_portion': {
            'type': 'integer',
            'description': 'Rough estimate, informational only.',
          },
          'protein_g_per_portion': {'type': 'number'},
          'fat_g_per_portion': {'type': 'number'},
          'carbs_g_per_portion': {'type': 'number'},
          'ingredients': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
                'quantity': {
                  'type': 'number',
                  'description':
                      'Omit entirely for fuzzy amounts ("salt to taste") '
                      'rather than guessing a number.',
                },
                'unit': {'type': 'string', 'enum': kIngredientUnits},
                'note': {'type': 'string'},
              },
              'required': ['name'],
            },
          },
        },
        'required': ['title', 'serves', 'method', 'ingredients'],
      },
    },
  },
};
