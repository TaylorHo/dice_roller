import 'package:dice_roller/dice_customization/dice_base.dart';
import 'package:dice_roller/dice_customization/models.dart';
import 'package:flame/events.dart';

class DiceStatic extends DiceBase with HoverCallbacks, TapCallbacks {
  final void Function()? callback;

  DiceStatic(
    super.dice, {
    super.color,
    super.diceValue,
    super.scale,
    super.anchor,
    super.priority,
    super.position,
    this.callback,
  }) : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _startRollingAnimation();

    add(diceMain);
    add(diceDetails);
    add(diceEffects);
  }

  void _startRollingAnimation() {
    diceMain.current = DiceRollingStates.endAnimation;
    diceDetails.current = DiceRollingStates.endAnimation;
    diceEffects.current = DiceRollingStates.endAnimation;
  }

  @override
  void onHoverEnter() {
    // Changed the animation really fast, so it just restart the final animation
    diceMain.current = DiceRollingStates.rolling;
    diceDetails.current = DiceRollingStates.rolling;
    diceEffects.current = DiceRollingStates.rolling;

    _startRollingAnimation();
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (callback != null) callback!();
  }
}
