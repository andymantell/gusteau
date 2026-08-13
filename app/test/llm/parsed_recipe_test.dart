import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gusteau/llm/parsed_recipe.dart';

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/recipes/$name.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('valid tool-use arguments parse correctly', () {
    test('a full recipe with every optional field present', () {
      final recipe = ParsedRecipe.fromToolUseArguments(
        _loadFixture('valid_full'),
      );

      expect(recipe.title, 'Chicken thigh traybake with fennel and lemon');
      expect(recipe.serves, 4);
      expect(recipe.cuisine, 'British');
      expect(recipe.timeMinutes, 45);
      expect(recipe.difficulty, 'easy');
      expect(recipe.kcalPerPortion, 520);
      expect(recipe.proteinGPerPortion, 38.5);
      expect(recipe.ingredients, hasLength(5));

      final mince = recipe.ingredients[0];
      expect(mince.name, 'chicken thighs, bone-in, skin-on');
      expect(mince.quantity, 8);
      expect(mince.unit, 'item');

      // Fuzzy amount: no quantity/unit, just a note — must not be
      // rejected or coerced into a fake number.
      final oliveOil = recipe.ingredients[3];
      expect(oliveOil.quantity, isNull);
      expect(oliveOil.unit, isNull);
      expect(oliveOil.note, 'a generous glug');
    });

    test('a minimal recipe with only the required fields', () {
      final recipe = ParsedRecipe.fromToolUseArguments(
        _loadFixture('valid_minimal'),
      );

      expect(recipe.title, 'Buttered toast');
      expect(recipe.cuisine, isNull);
      expect(recipe.difficulty, isNull);
      expect(recipe.ingredients, hasLength(2));
    });
  });

  group('malformed tool-use arguments are rejected with a specific reason', () {
    test('missing required field', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_missing_title'),
        ),
        throwsA(
          isA<RecipeValidationException>().having(
            (e) => e.message,
            'message',
            contains('title'),
          ),
        ),
      );
    });

    test('wrong type for a required field', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_serves_as_string'),
        ),
        throwsA(
          isA<RecipeValidationException>().having(
            (e) => e.message,
            'message',
            allOf(contains('serves'), contains('String')),
          ),
        ),
      );
    });

    test('unit outside the fixed enum', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_bad_unit'),
        ),
        throwsA(
          isA<RecipeValidationException>().having(
            (e) => e.message,
            'message',
            allOf(contains('grams'), contains('unit')),
          ),
        ),
      );
    });

    test('quantity present without a unit', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_quantity_without_unit'),
        ),
        throwsA(isA<RecipeValidationException>()),
      );
    });

    test('empty ingredients list', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_empty_ingredients'),
        ),
        throwsA(
          isA<RecipeValidationException>().having(
            (e) => e.message,
            'message',
            contains('ingredients'),
          ),
        ),
      );
    });

    test('ingredient entry is not an object', () {
      expect(
        () => ParsedRecipe.fromToolUseArguments(
          _loadFixture('malformed_ingredient_not_object'),
        ),
        throwsA(
          isA<RecipeValidationException>().having(
            (e) => e.message,
            'message',
            contains('ingredients[0]'),
          ),
        ),
      );
    });
  });
}
