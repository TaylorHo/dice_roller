import 'package:dice_roller/dice_customization/models.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/image_composition.dart' as flame_image;

// Add `with HasWorldReference<MyWorld>` to use `world.add()` method
class DiceBase extends PositionComponent {
  final Dice dice;
  final Color color;
  final int diceValue;

  late int _spriteQuantity;
  late int _rollingPosition;
  late String _diceName;

  late SpriteAnimationGroupComponent<DiceRollingStates> diceMain;
  late SpriteAnimationGroupComponent<DiceRollingStates> diceDetails;
  late SpriteAnimationGroupComponent<DiceRollingStates> diceEffects;

  DiceBase(
    this.dice, {
    this.color = Colors.purple,
    this.diceValue = 1,
    Vector2? scale,
    Anchor? anchor,
    int? priority,
    Vector2? position,
  }) : super(
          size: Vector2.all(48),
          scale: scale ?? Vector2.all(1),
          anchor: anchor ?? Anchor.center,
          priority: priority ?? 10,
          position: position ?? Vector2.zero(),
        ) {
    _spriteQuantity = _getSpriteQuantity();
    _rollingPosition = _getPositionOnRollingAnimation();
    _diceName = getDiceString(dice);

    switch (dice) {
      case Dice.d20:
        assert(diceValue <= 20, "Dice d20 can't be more than 20");
        break;
      case Dice.d12:
        assert(diceValue <= 12, "Dice d12 can't be more than 12");
        break;
      case Dice.d10:
        assert(diceValue <= 10, "Dice d10 can't be more than 10.");
        break;
      case Dice.d8:
        assert(diceValue <= 8, "Dice d8 can't be more than 8");
        break;
      case Dice.d6:
        assert(diceValue <= 6, "Dice d6 can't be more than 6");
        break;
      case Dice.d4:
        assert(diceValue <= 4, "Dice d4 can't be more than 4");
        break;
    }
  }

  Future<void> preloadImages() async {
    await _preloadImages(getDiceString(Dice.d4));
    await _preloadImages(getDiceString(Dice.d6));
    await _preloadImages(getDiceString(Dice.d8));
    await _preloadImages(getDiceString(Dice.d10));
    await _preloadImages(getDiceString(Dice.d12));
    await _preloadImages(getDiceString(Dice.d20));
    await _preloadImages('rolling');
  }

  Future<void> _preloadImages(String dice) async {
    await Flame.images.load('dices/$dice/main.png');
    await Flame.images.load('dices/$dice/details.png');
    await Flame.images.load('dices/$dice/effects.png');
  }

  @override
  Future<void> onLoad() async {
    final [
      SpriteAnimation animationMain,
      SpriteAnimation animationDetails,
      SpriteAnimation animationEffects
    ] = await finalAnimation();
    final [
      SpriteAnimation rollingMain,
      SpriteAnimation rollingDetails,
      SpriteAnimation rollingEffects
    ] = await rollingAnimation();

    final SpriteAnimationGroupComponent<DiceRollingStates> localDiceMain =
        _getSpriteAnimationGroupComponent(rollingMain, animationMain);
    final SpriteAnimationGroupComponent<DiceRollingStates> localDiceDetails =
        _getSpriteAnimationGroupComponent(rollingDetails, animationDetails);
    final SpriteAnimationGroupComponent<DiceRollingStates> localDiceEffects =
        _getSpriteAnimationGroupComponent(rollingEffects, animationEffects);

    _addColorsToAnimation(localDiceMain, localDiceDetails, localDiceEffects);

    diceMain = localDiceMain;
    diceDetails = localDiceDetails;
    diceEffects = localDiceEffects;
  }

  void removeDiceAfterCompletition(Duration duration,
      SpriteAnimationGroupComponent<DiceRollingStates> animation) {
    // ignore: always_specify_types
    Future.delayed(duration, () {
      remove(animation);
    });
  }

  void _addColorsToAnimation(
    SpriteAnimationGroupComponent<DiceRollingStates> main,
    SpriteAnimationGroupComponent<DiceRollingStates> details,
    SpriteAnimationGroupComponent<DiceRollingStates> effects,
  ) {
    main.add(ColorEffect(
      color,
      EffectController(
        duration: 0.1,
      ),
      opacityFrom: 0.8,
      opacityTo: 0.8,
    ));

    effects.add(ColorEffect(
      Colors.white,
      EffectController(
        duration: 0.1,
      ),
      opacityFrom: 0.7,
      opacityTo: 0.7,
    ));

    effects.opacity = 0.5;
    details.opacity = 0.8;
  }

  Future<List<SpriteAnimation>> finalAnimation() async {
    final flame_image.Image spriteSheetMain =
        await Flame.images.load('dices/$_diceName/main.png');
    final flame_image.Image spriteSheetEffects =
        await Flame.images.load('dices/$_diceName/effects.png');
    final flame_image.Image spriteSheetDetails =
        await Flame.images.load('dices/$_diceName/details.png');

    final SpriteAnimationData sequenced = _getSequencedSpriteAnimation(
        amount: _spriteQuantity, position: diceValue);

    final SpriteAnimation animationMain =
        _getSpriteAnimationFromImage(spriteSheetMain, sequenced);
    final SpriteAnimation animationDetails =
        _getSpriteAnimationFromImage(spriteSheetDetails, sequenced);
    final SpriteAnimation animationEffects =
        _getSpriteAnimationFromImage(spriteSheetEffects, sequenced);

    return <SpriteAnimation>[animationMain, animationDetails, animationEffects]
        .toList();
  }

  Future<List<SpriteAnimation>> rollingAnimation() async {
    final flame_image.Image spriteSheetMain =
        await Flame.images.load('dices/rolling/main.png');
    final flame_image.Image spriteSheetDetails =
        await Flame.images.load('dices/rolling/details.png');
    final flame_image.Image spriteSheetEffects =
        await Flame.images.load('dices/rolling/effects.png');

    final SpriteAnimationData sequenced =
        _getSequencedSpriteAnimation(amount: 7, position: _rollingPosition);

    final SpriteAnimation rollingMain =
        _getSpriteAnimationFromImage(spriteSheetMain, sequenced);
    final SpriteAnimation rollingDetails =
        _getSpriteAnimationFromImage(spriteSheetDetails, sequenced);
    final SpriteAnimation rollingEffects =
        _getSpriteAnimationFromImage(spriteSheetEffects, sequenced);

    return <SpriteAnimation>[rollingMain, rollingDetails, rollingEffects]
        .toList();
  }

  SpriteAnimationGroupComponent<DiceRollingStates>
      _getSpriteAnimationGroupComponent(
          SpriteAnimation rollingAnimation, SpriteAnimation mainAnimation) {
    return SpriteAnimationGroupComponent<DiceRollingStates>(
      animations: <DiceRollingStates, SpriteAnimation>{
        DiceRollingStates.rolling: rollingAnimation,
        DiceRollingStates.endAnimation: mainAnimation,
      },
      current: DiceRollingStates.rolling,
      size: size,
    );
  }

  SpriteAnimationData _getSequencedSpriteAnimation(
      {int amount = 7, required int position}) {
    return SpriteAnimationData.sequenced(
      amount: amount,
      textureSize: Vector2(48, 48),
      texturePosition: Vector2(0, ((48 * position) - 48)),
      stepTime: 0.1,
      loop: false,
    );
  }

  int _getSpriteQuantity() {
    switch (dice) {
      case Dice.d4:
      case Dice.d6:
      case Dice.d20:
        return 7;
      case Dice.d8:
      case Dice.d10:
      case Dice.d12:
        return 6;
    }
  }

  int _getPositionOnRollingAnimation() {
    switch (dice) {
      case Dice.d4:
        return 1;
      case Dice.d6:
        return 2;
      case Dice.d8:
        return 3;
      case Dice.d10:
        return 4;
      case Dice.d12:
        return 5;
      case Dice.d20:
        return 6;
    }
  }

  SpriteAnimation _getSpriteAnimationFromImage(
      flame_image.Image image, SpriteAnimationData data) {
    return SpriteAnimation.fromFrameData(
      image,
      data,
    );
  }
}
