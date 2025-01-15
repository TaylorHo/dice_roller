# Dice Roller Package

**NOTE:** To use this package, you need to add the dice sprites into your `assets/` folder inside your project. To do this, just copy our `assets/` folder content to yours `assets/` folder, keeping the folder structure (`assets/images/dices/ ...`).

## What is this package?

This package uses [Flame](https://flame-engine.org/) to roll dices, with animations (including physics effects, shadows and collisions).

## How to use this package?
Just import it into your project from the GitHub:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Add this line
  dice_roller:
    git:
      url: https://github.com/hotaydev/arcanapixel_dice_roller.git
      ref: main # branch name
```

Then, you can use it to do many things in your code:

1. Roll a dice (math/logic):
```dart
final result = DiceRoller().rollDice('5d20 +5 max'); // Roll 5d20 and keep only the max value, then sum 5

// or

final result = DiceRoller().rollDice('2d20 min'); // Roll 2d20 and keep only the min value

// Then you can get the results from the `result` variable

print(result.rolls); // Array of the rolled dices, used for animations or history
print(result.diceType); // Eg. d4, d6, d8, d10, etc., from an enum called "dices"
print(result.results); // Total (sum with advantage, disadvantage, modifier, etc.)

```

2. Show a static image of a dice (with custom colors)
```dart
final Stack diceImage = await DiceStaticImage(Dice.d20).img;

// Where Dice.d20 can be changed by any dice from the Dice enum (eg. d4, d6, d12, etc.)

// Sicne it's a Stack, it can be used as any Widget in a Material app
```

3. Show a dice animation of a fixed sice (not rolling) as a PositionComponent from [Flame](https://flame-engine.org/)
```dart
final dice = DiceStatic(
  Dice.d20, // From the `Dice` enum
  diceValue: 20, // from 1 to 20, varying between dice types
  position: Vector2(100, 100), // Position on the game
  callback: () {}, // Executed whe Clicked
  // You can also pass angle, anchor, scale, priority, color, etc.
);

game.add(dice); // Add to the game

// When hovered this dice have an animation
```

4. Show a dice rolling animation resulting in a final value, with shadow and physics animation
```dart
final dice = DiceRolling(
  Dice.d20, // From the `Dice` enum
  diceValue: 20, // from 1 to 20, varying between dice types
  position: Vector2(100, 100), // Position on the game
  // You can also pass angle, anchor, scale, priority, color, etc.
);

game.add(dice); // Add to the game

// This dice is auto-removed after 3 seconds. This can be changed with a parameter called `removeAfter` which receives a `Duration()`.
```

### Edge detection and space between dices
It's better to not put a dice below each other, so before positioning our dice into the `game`, it's useful to track dices position (for multiple dices) and reserved areas (for Flame overlays, for example).

An example of this usage is in the [`example/lib/main.dart`](./example/lib/main.dart) file, in the `_rollDice()` function.

