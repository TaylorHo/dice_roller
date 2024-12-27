import 'dart:async';
import 'dart:math';

import 'package:dice_roller/dice_customization/dice_base.dart';
import 'package:dice_roller/dice_customization/dice_images.dart';
import 'package:dice_roller/dice_customization/dice_rolling.dart';
import 'package:dice_roller/dice_customization/models.dart';
import 'package:dice_roller/dice_roll/dice_roll.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

final ValueNotifier<List<Map<String, String>>> historyNotifier =
    ValueNotifier([]);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(
        game: FlameGame(world: MyWorld()),
        backgroundBuilder: (context) => Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background/0.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        overlayBuilderMap: {
          'diceRollerButton': (BuildContext context, FlameGame<World> game) =>
              DiceRollerButton(game: game),
          'diceRollerInput': (BuildContext context, FlameGame<World> game) =>
              DiceRollerInput(game: game),
          'diceRollHistory': (BuildContext context, FlameGame<World> game) =>
              const DiceRollHistory(),
        },
        initialActiveOverlays: const ['diceRollerButton', 'diceRollHistory'],
      ),
    ),
  );
}

class MyWorld extends World with HasGameRef<FlameGame> {
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Preload all sprites before using them
    DiceBase(Dice.d20).preloadImages();
  }
}

class DiceRollerButton extends StatelessWidget {
  final FlameGame game;
  const DiceRollerButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (!game.overlays.activeOverlays.contains('diceRollerInput')) {
              game.overlays.add('diceRollerInput');
            } else {
              game.overlays.remove('diceRollerInput');
            }
          },
          child: const Text('Roll a Dice'),
        ),
      ),
    );
  }
}

class DiceRollerInput extends StatefulWidget {
  final FlameGame game;
  const DiceRollerInput({super.key, required this.game});

  @override
  State<DiceRollerInput> createState() => _DiceRollerInputState();
}

class _DiceRollerInputState extends State<DiceRollerInput> {
  final TextEditingController _controller = TextEditingController();
  String activeButton = '';

  @override
  void initState() {
    super.initState();

    // Add a listener to track manual changes in the text field
    _controller.addListener(() {
      final text = _controller.text;
      if (!text.contains(' max') && activeButton == 'max') {
        setState(() {
          activeButton = '';
        });
      } else if (!text.contains(' min') && activeButton == 'min') {
        setState(() {
          activeButton = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rollDice() {
    final random = Random();

    // Define safe area margins
    const double safeMarginX = 100;
    const double safeMarginY = 100;

    // Define minimum distance between dice
    const double minDistance = 60; // Adjust based on dice size

    // List to store positions of placed dice
    final placedPositions = <Vector2>[];

    try {
      final result = DiceRoller().rollDice(_controller.text);

      for (var rolled in result.rolls) {
        Vector2 newPosition;

        // Generate random positions and check distance
        do {
          final randomX = safeMarginX +
              random.nextDouble() * (widget.game.size.x - 2 * safeMarginX);
          final randomY = safeMarginY +
              random.nextDouble() * (widget.game.size.y - 2 * safeMarginY);

          newPosition = Vector2(randomX, randomY);
        } while (_isTooClose(newPosition, placedPositions, minDistance));

        // Add the new position to the list
        placedPositions.add(newPosition);

        // Create the dice component at the chosen position
        final dice = DiceRolling(
          result.diceType,
          diceValue: rolled,
          position: newPosition, // Apply safe and non-overlapping position
        );

        widget.game.add(dice);
      }

      // Add to roll history
      historyNotifier.value = [
        ...historyNotifier.value,
        {
          'roll': _controller.text,
          'result': result.result.toString(),
        }
      ];
    } catch (e) {
      debugPrint('Invalid dice expression: $e');
    }
  }

  // Helper function to check distance between positions
  bool _isTooClose(
      Vector2 newPosition, List<Vector2> placedPositions, double minDistance) {
    for (final position in placedPositions) {
      if (position.distanceTo(newPosition) < minDistance) {
        return true; // Too close to an existing position
      }
    }
    return false; // No conflicts, position is valid
  }

  void _toggleButton(String button) {
    setState(() {
      if (activeButton == button) {
        // If the button is active, deactivate it and remove the text
        activeButton = '';
        _controller.text = _controller.text.replaceAll(button, '').trim();
      } else {
        // If the button is not active, activate it and add the text
        if (activeButton.isNotEmpty) {
          // Replace the current active button text with the new button text
          _controller.text =
              _controller.text.replaceAll(activeButton, '').trim();
        }
        activeButton = button;
        _controller.text = '${_controller.text.trim()} $button'.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 50),
        child: Container(
          width: 400,
          height: 190,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d4).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d6).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d8).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d10).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d12).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                  FutureBuilder<Stack>(
                    future: DiceStaticImage(Dice.d20).img,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                          width: 48,
                          height: 48,
                          child: snapshot.data,
                        );
                      } else {
                        return const CirclePlaceholder();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'eg. 2d20 + 5',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.purple.shade300),
                          ),
                        ),
                        onChanged: (String value) {
                          if (value.contains('max') && activeButton != 'max') {
                            setState(() {
                              activeButton = 'max';
                            });
                          } else if (value.contains('min') &&
                              activeButton != 'min') {
                            setState(() {
                              activeButton = 'min';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ToggleButtons(
                    isSelected: [activeButton == 'max', activeButton == 'min'],
                    onPressed: (index) {
                      _toggleButton(index == 0 ? 'max' : 'min');
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    fillColor: Colors.purple.shade200,
                    borderColor: Colors.grey.shade400,
                    selectedBorderColor: Colors.purple.shade300,
                    selectedColor: Colors.white,
                    children: const [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Max')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Min')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('diceRollerInput');
                  // roll dice
                  _rollDice();
                },
                child: const Text('Roll the Dice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CirclePlaceholder extends StatelessWidget {
  const CirclePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

class DiceRollHistory extends StatelessWidget {
  const DiceRollHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 200,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ValueListenableBuilder<List<Map<String, String>>>(
                    valueListenable: historyNotifier,
                    builder: (context, history, _) {
                      return ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8), // Padding inside the block
                              decoration: BoxDecoration(
                                color: Colors.blue[
                                    100], // Background color for the block
                                borderRadius: BorderRadius.circular(
                                    12.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Shadow color
                                    blurRadius: 4.0, // Shadow blur radius
                                    offset:
                                        const Offset(0, 2), // Shadow position
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Align text to the left
                                children: [
                                  Text(
                                    'Roll: ${history[index]['roll']}',
                                    style: TextStyle(
                                      fontSize: 16.0, // Larger text for roll
                                      fontWeight:
                                          FontWeight.bold, // Bold roll text
                                      color: Colors
                                          .blue[800], // Color for roll text
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          2), // Space between roll and result
                                  Text(
                                    'Result: ${history[index]['result']}',
                                    style: const TextStyle(
                                      fontSize: 14.0, // Smaller text for result
                                      color: Colors
                                          .black, // Standard color for result text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
