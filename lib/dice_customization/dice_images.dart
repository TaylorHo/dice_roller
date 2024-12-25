import 'package:dice_roller/dice_customization/models.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/image_composition.dart' as flame_image;

class DiceStaticImage {
  final Dice dice;
  final Color color;
  static const double spriteSize = 48;

  DiceStaticImage(this.dice, {this.color = Colors.purple});

  Future<Stack> get img => _getDiceImage();

  Future<Stack> _getDiceImage() async {
    final String imageFolder = _getDiceImageLocation();
    final Vector2 imagePosition = _getDiceImagePosition();

    final flame_image.Image flameImgMain =
        await Flame.images.load('$imageFolder/main.png');
    final flame_image.Image flameImgDetails =
        await Flame.images.load('$imageFolder/details.png');
    final flame_image.Image flameImgEffects =
        await Flame.images.load('$imageFolder/effects.png');

    final Stack stacked = Stack(
      children: <Widget>[
        SpriteWidget(
          sprite: Sprite(
            flameImgMain,
            srcPosition: imagePosition,
            srcSize: Vector2.all(spriteSize),
          ),
          anchor: Anchor.center,
          paint: Paint()
            ..colorFilter = ColorFilter.mode(
              color,
              BlendMode.srcATop,
            ),
        ),
        Opacity(
          opacity: 0.5,
          child: SpriteWidget(
            sprite: Sprite(
              flameImgEffects,
              srcPosition: imagePosition,
              srcSize: Vector2.all(spriteSize),
            ),
            anchor: Anchor.center,
            paint: Paint()
              ..colorFilter = const ColorFilter.mode(
                Colors.white,
                BlendMode.srcATop,
              ),
          ),
        ),
        SpriteWidget(
          sprite: Sprite(
            flameImgDetails,
            srcPosition: imagePosition,
            srcSize: Vector2.all(spriteSize),
          ),
          anchor: Anchor.center,
        ),
      ],
    );

    return stacked;
  }

  String _getDiceImageLocation() {
    switch (dice) {
      case Dice.d4:
        return 'dices/d4/';
      case Dice.d6:
        return 'dices/d6/';
      case Dice.d8:
        return 'dices/d8/';
      case Dice.d10:
        return 'dices/d10/';
      case Dice.d12:
        return 'dices/d12/';
      case Dice.d20:
        return 'dices/d20/';
    }
  }

  Vector2 _getDiceImagePosition() {
    switch (dice) {
      case Dice.d4:
        return Vector2((6 * spriteSize), (3 * spriteSize));
      case Dice.d6:
        return Vector2((6 * spriteSize), (5 * spriteSize));
      case Dice.d8:
        return Vector2((5 * spriteSize), (7 * spriteSize));
      case Dice.d10:
        return Vector2((5 * spriteSize), (9 * spriteSize));
      case Dice.d12:
        return Vector2((5 * spriteSize), (11 * spriteSize));
      case Dice.d20:
        return Vector2((6 * spriteSize), (19 * spriteSize));
    }
  }
}
