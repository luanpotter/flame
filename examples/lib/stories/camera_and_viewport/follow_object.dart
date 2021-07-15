import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/square_component.dart';

final R = Random();

class MovableSquare extends SquareComponent
    with Hitbox, Collidable, HasGameRef<CameraAndViewportGame> {
  static const double speed = 300;
  static final TextPaint textRenderer = TextPaint(
    config: const TextPaintConfig(
      fontSize: 12,
    ),
  );

  final Vector2 velocity = Vector2.zero();
  late Timer timer;

  MovableSquare() : super(priority: 1) {
    addHitbox(HitboxRectangle());
    timer = Timer(3.0)
      ..stop()
      ..callback = () {
        gameRef.camera.setRelativeOffset(Anchor.center);
      };
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);

    final ds = velocity * (speed * dt);
    position.add(ds);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    final text = '(${x.toInt()}, ${y.toInt()})';
    textRenderer.render(c, text, size / 2, anchor: Anchor.center);
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    if (other is Rock) {
      gameRef.camera.setRelativeOffset(Anchor.topCenter);
      timer.start();
    }
  }
}

class Map extends Component {
  static const double S = 1500;
  static const Rect bounds = Rect.fromLTWH(-S, -S, 2 * S, 2 * S);

  static final Paint _paintBorder = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  static final Paint _paintBg = Paint()..color = const Color(0xFF333333);

  Map() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(bounds, _paintBg);
    canvas.drawRect(bounds, _paintBorder);
  }

  static double genCoord() {
    return -S + R.nextDouble() * (2 * S);
  }
}

class Rock extends SquareComponent with Hitbox, Collidable, Tappable {
  static final unpressedPaint = Paint()..color = const Color(0xFF2222FF);
  static final pressedPaint = Paint()..color = const Color(0xFF414175);

  Rock(Vector2 position) : super(priority: 2) {
    this.position.setFrom(position);
    size.setValues(50, 50);
    paint = unpressedPaint;
    addHitbox(HitboxRectangle());
  }

  @override
  bool onTapDown(_) {
    paint = pressedPaint;
    return true;
  }

  @override
  bool onTapUp(_) {
    paint = unpressedPaint;
    return true;
  }

  @override
  bool onTapCancel() {
    paint = unpressedPaint;
    return true;
  }
}

class CameraAndViewportGame extends BaseGame
    with KeyboardEvents, HasCollidables, HasTappableComponents {
  late MovableSquare square;

  final Vector2 viewportResolution;

  CameraAndViewportGame({
    required this.viewportResolution,
  });

  @override
  Future<void> onLoad() async {
    viewport = FixedResolutionViewport(viewportResolution);
    add(Map());

    add(square = MovableSquare());
    camera.speed = 1;
    camera.followComponent(square, worldBounds: Map.bounds);

    for (var i = 0; i < 30; i++) {
      add(Rock(Vector2(Map.genCoord(), Map.genCoord())));
    }
  }

  @override
  void onKeyEvent(RawKeyEvent e) {
    final isKeyDown = e is RawKeyDownEvent;
    if (e.data.keyLabel == 'a') {
      square.velocity.x = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 'd') {
      square.velocity.x = isKeyDown ? 1 : 0;
    } else if (e.data.keyLabel == 'w') {
      square.velocity.y = isKeyDown ? -1 : 0;
    } else if (e.data.keyLabel == 's') {
      square.velocity.y = isKeyDown ? 1 : 0;
    }
  }
}
