enum Dice { d4, d6, d8, d10, d12, d20 }

enum DiceRollingStates { rolling, endAnimation }

String getDiceString(Dice dice) {
  switch (dice) {
    case Dice.d4:
      return 'd4';
    case Dice.d6:
      return 'd6';
    case Dice.d8:
      return 'd8';
    case Dice.d10:
      return 'd10';
    case Dice.d12:
      return 'd12';
    case Dice.d20:
      return 'd20';
  }
}

Dice getDiceEnumValue(String dice) {
  switch (dice) {
    case 'd4':
      return Dice.d4;
    case 'd6':
      return Dice.d6;
    case 'd8':
      return Dice.d8;
    case 'd10':
      return Dice.d10;
    case 'd12':
      return Dice.d12;
    case 'd20':
      return Dice.d20;
    default:
      return Dice.d20; // Since it can have more values
  }
}
