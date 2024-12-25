import 'dart:math';

import 'package:dice_roller/dice_customization/models.dart';

class DiceRollResult {
  final List<int> rolls;
  final int result;
  final Dice diceType;

  DiceRollResult(
      {required this.rolls, required this.result, required this.diceType});
}

class DiceRoller {
  final Random _random = Random();

  DiceRollResult rollDice(String input) {
    final RegExp regex = RegExp(r'(\d*)d(\d+)\s*([+-]\s*\d+)?\s*(min|max)?');
    final RegExpMatch? match = regex.firstMatch(input);

    if (match == null) {
      throw ArgumentError('Invalid input format.');
    }

    // Parse the input
    final String? filter = match.group(4); // min/max filter
    final int diceCount = int.tryParse(match.group(1) ?? '1') ??
        1; // Default to 1 if no number is found
    final int diceSides = int.parse(match.group(2)!);
    final int modifier =
        int.tryParse(match.group(3)?.replaceAll(' ', '') ?? '0') ?? 0;

    // Map dice sides to the Dice enum
    final Dice diceType = Dice.values.firstWhere(
      (Dice d) => d.toString().split('.').last == 'd$diceSides',
      orElse: () => throw ArgumentError('Unsupported dice type: d$diceSides'),
    );

    // Roll the dice
    final List<int> rolls =
        List<int>.generate(diceCount, (_) => _random.nextInt(diceSides) + 1);

    // Determine the result based on the filter
    int result;
    if (filter == 'max') {
      result = rolls.reduce(max) + modifier;
    } else if (filter == 'min') {
      result = rolls.reduce(min) + modifier;
    } else {
      result = rolls.reduce((int sum, int roll) => sum + roll) + modifier;
    }

    return DiceRollResult(rolls: rolls, result: result, diceType: diceType);
  }
}
