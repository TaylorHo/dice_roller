import 'dart:math';

import 'package:dice_roller/dice_customization/dice_base.dart';
import 'package:dice_roller/dice_customization/models.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// ignore: always_specify_types
class DiceRolling extends DiceBase with HasGameRef<FlameGame> {
  final Duration removeAfter;

  // Physics properties
  Vector2 velocity; // Current velocity of the dice
  final double deceleration = 1000; // Faster deceleration

  // Scaling properties
  double initialScale = 4.0; // Start size multiplier
  double targetScale = 2.0; // Normal size
  double scaleDuration = 0.2; // Time in seconds to shrink
  double scaleTimer = 0.0; // Timer for scaling

  late OvalComponent shadow;

  DiceRolling(
    super.dice, {
    super.color,
    super.diceValue,
    super.scale,
    super.anchor,
    super.priority,
    super.position,
    this.removeAfter = const Duration(milliseconds: 3000), // Faster removal
  })  : velocity = _generateRandomVelocity(),
        super();

  static Vector2 _generateRandomVelocity() {
    final double angle = Random().nextDouble() * 2 * pi; // Random direction
    final double speed =
        (Random().nextDouble() * 900) + 600; // Higher initial speed
    return Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set initial scale
    scale = Vector2.all(initialScale);

    shadow = OvalComponent(
      size: Vector2(20, 8), // Initial oval size (width, height)
      paint: Paint()..color = const Color(0x55000000), // Semi-transparent black
      anchor: Anchor.center,
      position: Vector2(
          (position.x - position.x + 26), (position.y - position.y + 40)),
    );
    add(shadow);

    // Set up animation transition logic
    diceMain.animationTickers?[DiceRollingStates.rolling]?.onComplete = () {
      diceMain.current = DiceRollingStates.endAnimation;
      diceDetails.current = DiceRollingStates.endAnimation;
      diceEffects.current = DiceRollingStates.endAnimation;
    };

    diceMain.animationTickers?[DiceRollingStates.endAnimation]?.onComplete =
        () async {
      removeDiceAfterCompletition(removeAfter, diceMain);
      removeDiceAfterCompletition(removeAfter, diceDetails);
      removeDiceAfterCompletition(removeAfter, diceEffects);
      // ignore: always_specify_types
      Future.delayed(removeAfter, () {
        shadow.removeFromParent();
      });
    };

    add(diceMain);
    add(diceDetails);
    add(diceEffects);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position based on velocity
    position += velocity * dt;

    // Apply deceleration to slow down the dice quickly (ease-in)
    final Vector2 decelerationVector =
        velocity.normalized() * deceleration * dt;
    if (velocity.length > decelerationVector.length) {
      velocity -= decelerationVector;
    } else {
      velocity = Vector2.zero();

      // Trigger stop animation once the dice stops moving
      if (diceMain.current == DiceRollingStates.rolling) {
        diceMain.current = DiceRollingStates.endAnimation;
        diceDetails.current = DiceRollingStates.endAnimation;
        diceEffects.current = DiceRollingStates.endAnimation;
      }
    }

    // Keep the dice within the screen, leaving some padding
    const double padding = 50; // Space between dice and screen edges
    final Vector2 screenSize = gameRef.size;
    if (position.x < padding) {
      velocity.x = velocity.x.abs(); // Reflect velocity to move right
      position.x = padding;
    }
    if (position.x > screenSize.x - padding) {
      velocity.x = -velocity.x.abs(); // Reflect velocity to move left
      position.x = screenSize.x - padding;
    }
    if (position.y < padding) {
      velocity.y = velocity.y.abs(); // Reflect velocity to move down
      position.y = padding;
    }
    if (position.y > screenSize.y - padding) {
      velocity.y = -velocity.y.abs(); // Reflect velocity to move up
      position.y = screenSize.y - padding;
    }

    // Handle scaling
    if (scaleTimer < scaleDuration) {
      scaleTimer += dt;
      double t = scaleTimer / scaleDuration; // Normalized time (0 to 1)
      double currentScale = initialScale + (targetScale - initialScale) * t;
      scale = Vector2.all(currentScale);
    } else {
      scale = Vector2.all(targetScale); // Ensure final scale is set
    }

    shadow.scale = Vector2.all(scale.x);
  }
}

class OvalComponent extends PositionComponent {
  final Paint paint;

  OvalComponent({
    required this.paint,
    super.size,
    super.position,
    super.anchor,
    super.scale,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw an oval inside the component's size
    final Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawOval(rect, paint);
  }
}
