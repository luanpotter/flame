import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

enum Shapes { circle, rectangle, polygon }

abstract class MyCollidable extends PositionComponent
    with Draggable, Hitbox, Collidable {
  double rotationSpeed = 0.0;
  final Vector2 velocity;
  final delta = Vector2.zero();
  double angleDelta = 0;
  bool _isDragged = false;
  late final Paint _activePaint;
  final Color _defaultColor = Colors.blue.withOpacity(0.8);
  final Set<Collidable> _activeCollisions = {};
  final ScreenCollidable screenCollidable;

  MyCollidable(
    Vector2 position,
    Vector2 size,
    this.velocity,
    this.screenCollidable,
  ) {
    this.position = position;
    this.size = size;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    _activePaint = Paint()..color = _defaultColor;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isDragged) {
      return;
    }
    delta.setFrom(velocity * dt);
    position.add(delta);
    angleDelta = dt * rotationSpeed;
    angle = (angle + angleDelta) % (2 * pi);
    // Takes rotation into consideration (which topLeftPosition doesn't)
    final topLeft = absoluteCenter - (size / 2);
    if (topLeft.x + size.x < 0 ||
        topLeft.y + size.y < 0 ||
        topLeft.x > screenCollidable.size.x ||
        topLeft.y > screenCollidable.size.y) {
      final moduloSize = screenCollidable.size + size;
      topLeftPosition = topLeftPosition % moduloSize;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderHitboxes(canvas, paint: _activePaint);
    if (_isDragged) {
      final localCenter = (size / 2).toOffset();
      canvas.drawCircle(localCenter, 5, _activePaint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    final isNew = _activeCollisions.add(other);
    if (isNew) {
      _activePaint.color = collisionColor(other).withOpacity(0.8);
    }
  }

  @override
  void onCollisionEnd(Collidable other) {
    _activeCollisions.remove(other);
    if (_activeCollisions.isEmpty) {
      _activePaint.color = _defaultColor;
    }
  }

  Color collisionColor(Collidable other) {
    switch (other.runtimeType) {
      case ScreenCollidable:
        return Colors.teal;
      case CollidablePolygon:
        return Colors.deepOrange;
      case CollidableCircle:
        return Colors.green;
      case CollidableRectangle:
        return Colors.cyan;
      case CollidableSnowman:
        return Colors.amber;
      default:
        return Colors.pink;
    }
  }

  @override
  bool onDragUpdate(int pointerId, _) {
    _isDragged = true;
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    velocity.setFrom(info.velocity / 10);
    _isDragged = false;
    return true;
  }
}

class CollidablePolygon extends MyCollidable {
  CollidablePolygon(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    final shape = HitboxPolygon([
      Vector2(-1.0, 0.0),
      Vector2(-0.8, 0.6),
      Vector2(0.0, 1.0),
      Vector2(0.6, 0.9),
      Vector2(1.0, 0.0),
      Vector2(0.6, -0.8),
      Vector2(0, -1.0),
      Vector2(-0.8, -0.8),
    ]);
    addHitbox(shape);
  }
}

class CollidableRectangle extends MyCollidable {
  CollidableRectangle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    addHitbox(HitboxRectangle());
  }
}

class CollidableCircle extends MyCollidable {
  CollidableCircle(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    final shape = HitboxCircle();
    addHitbox(shape);
  }
}

class SnowmanPart extends HitboxCircle {
  final startColor = Colors.blue.withOpacity(0.8);
  final hitPaint = Paint();

  SnowmanPart(double definition, Vector2 relativeOffset, Color hitColor)
      : super(definition: definition) {
    this.relativeOffset.setFrom(relativeOffset);
    hitPaint..color = startColor;
    onCollision = (Set<Vector2> intersectionPoints, HitboxShape other) {
      if (other.component is ScreenCollidable) {
        hitPaint..color = startColor;
      } else {
        hitPaint.color = hitColor.withOpacity(0.8);
      }
    };
  }

  @override
  void render(Canvas canvas, _) {
    super.render(canvas, hitPaint);
  }
}

class CollidableSnowman extends MyCollidable {
  CollidableSnowman(
    Vector2 position,
    Vector2 size,
    Vector2 velocity,
    ScreenCollidable screenCollidable,
  ) : super(position, size, velocity, screenCollidable) {
    rotationSpeed = 0.3;
    anchor = Anchor.topLeft;
    final top = SnowmanPart(0.4, Vector2(0, -0.8), Colors.red);
    final middle = SnowmanPart(0.6, Vector2(0, -0.3), Colors.yellow);
    final bottom = SnowmanPart(1.0, Vector2(0, 0.5), Colors.green);
    addHitbox(top);
    addHitbox(middle);
    addHitbox(bottom);
  }
}

class MultipleShapes extends BaseGame
    with HasCollidables, HasDraggableComponents {
  final TextPaint fpsTextPaint = TextPaint(
    config: TextPaintConfig(
      color: BasicPalette.white.color,
    ),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final screenCollidable = ScreenCollidable();
    final snowman = CollidableSnowman(
      Vector2.all(150),
      Vector2(100, 200),
      Vector2(-100, 100),
      screenCollidable,
    );
    MyCollidable lastToAdd = snowman;
    add(screenCollidable);
    add(snowman);
    var totalAdded = 1;
    while (totalAdded < 20) {
      lastToAdd = createRandomCollidable(lastToAdd, screenCollidable);
      final lastBottomRight =
          lastToAdd.toAbsoluteRect().bottomRight.toVector2();
      if (lastBottomRight.x < size.x && lastBottomRight.y < size.y) {
        add(lastToAdd);
        totalAdded++;
      } else {
        break;
      }
    }
  }

  final _rng = Random();
  final _distance = Vector2(100, 0);

  MyCollidable createRandomCollidable(
    MyCollidable lastCollidable,
    ScreenCollidable screen,
  ) {
    final collidableSize = Vector2.all(50) + Vector2.random(_rng) * 100;
    final isXOverflow = lastCollidable.position.x +
            lastCollidable.size.x / 2 +
            _distance.x +
            collidableSize.x >
        size.x;
    var position = _distance + Vector2(0, lastCollidable.position.y + 200);
    if (!isXOverflow) {
      position = (lastCollidable.position + _distance)
        ..x += collidableSize.x / 2;
    }
    final velocity = (Vector2.random(_rng) - Vector2.random(_rng)) * 400;
    final rotationSpeed = 0.5 - _rng.nextDouble();
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    switch (shapeType) {
      case Shapes.circle:
        return CollidableCircle(position, collidableSize, velocity, screen)
          ..rotationSpeed = rotationSpeed;
      case Shapes.rectangle:
        return CollidableRectangle(position, collidableSize, velocity, screen)
          ..rotationSpeed = rotationSpeed;
      case Shapes.polygon:
        return CollidablePolygon(position, collidableSize, velocity, screen)
          ..rotationSpeed = rotationSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    fpsTextPaint.render(
      canvas,
      '${fps(120).toStringAsFixed(2)}fps',
      Vector2(0, size.y - 24),
    );
  }
}
