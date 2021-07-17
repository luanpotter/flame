import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';

class OpacityEffectGame extends BaseGame with TapDetector {
  late final SpriteComponent sprite;

  @override
  Future<void> onLoad() async {
    final flameSprite = await loadSprite('flame.png');
    add(
      sprite = SpriteComponent(
        sprite: flameSprite,
        position: Vector2.all(100),
        size: Vector2(149, 211),
      ),
    );

    add(
      SpriteComponent(
        sprite: flameSprite,
        position: Vector2(300, 100),
        size: Vector2(149, 211),
      )..addEffect(
          OpacityEffect(
            opacity: 0,
            duration: 0.5,
            initialIsInfinite: true,
            initialIsAlternating: true,
          ),
        ),
    );
  }

  @override
  void onTap() {
    if (sprite.paint.color.opacity == 1) {
      sprite.addEffect(OpacityEffect.fadeOff());
    } else if (sprite.paint.color.opacity == 0) {
      sprite.addEffect(OpacityEffect.fadeIn());
    }
  }
}
