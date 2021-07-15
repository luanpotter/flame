import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';

class MyComponent extends PositionComponent {}

class MyHitboxComponent extends PositionComponent with Hitbox {}

void main() {
  group('PositionComponent overlap test', () {
    test('overlap', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(4.0, 4.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('overlap on edge', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 1.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with x', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(4.0, 1.0);
      expect(component.containsPoint(point), false);
    });

    test('not overlapping with y', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 4.0);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(3.1, 2.0);
      expect(component.containsPoint(point), true);
    });

    test('not overlapping with angle', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.center;

      final point = Vector2(1.0, 0.1);
      expect(component.containsPoint(point), false);
    });

    test('overlapping with angle and topLeft anchor', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(1.0, 1.0);
      component.size.setValues(2.0, 2.0);
      component.angle = math.pi / 4;
      component.anchor = Anchor.topLeft;

      final point = Vector2(1.0, 3.1);
      expect(component.containsPoint(point), true);
    });

    test('component with hitbox contains point', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]);
      component.addHitbox(hitbox);

      final point = component.position + component.size / 4;
      expect(component.containsPoint(point), true);
    });

    test('component with anchor topLeft contains point on edge', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(-1, -1);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(1, 1)), true);
      expect(component.containsPoint(Vector2(1, -1)), true);
      expect(component.containsPoint(Vector2(-1, -1)), true);
      expect(component.containsPoint(Vector2(-1, 1)), true);
    });

    test('component with anchor bottomRight contains point on edge', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1, 1);
      component.anchor = Anchor.bottomRight;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(1, 1)), true);
      expect(component.containsPoint(Vector2(1, -1)), true);
      expect(component.containsPoint(Vector2(-1, -1)), true);
      expect(component.containsPoint(Vector2(-1, 1)), true);
    });

    test('component with anchor topRight does not contain close points', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1, 1);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      final hitbox = HitboxRectangle();
      component.addHitbox(hitbox);

      expect(component.containsPoint(Vector2(0.0, 0.0)), false);
      expect(component.containsPoint(Vector2(0.9, 0.9)), false);
      expect(component.containsPoint(Vector2(3.1, 3.1)), false);
      expect(component.containsPoint(Vector2(1.1, 3.1)), false);
    });

    test('component with hitbox does not contains point', () {
      final Hitbox component = MyHitboxComponent();
      component.position.setValues(1.0, 1.0);
      component.anchor = Anchor.topLeft;
      component.size.setValues(2.0, 2.0);
      component.addHitbox(HitboxPolygon([
        Vector2(1, 0),
        Vector2(0, -1),
        Vector2(-1, 0),
        Vector2(0, 1),
      ]));

      final point = Vector2(1.1, 1.1);
      expect(component.containsPoint(point), false);
    });

    test('component with zero size does not contain point', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(0.0, 0.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), false);
    });

    test('component with zero size does not contain point', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 2.0);
      component.size.setValues(0.0, 0.0);
      component.angle = 0.0;
      component.anchor = Anchor.center;

      final point = Vector2(2.0, 2.0);
      expect(component.containsPoint(point), false);
    });

    test('component with anchor center has the same center and position', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 1.0);
      component.size.setValues(3.0, 1.0);
      component.angle = 2.0;
      component.anchor = Anchor.center;

      expect(component.center, component.position);
      expect(component.absoluteCenter, component.position);
      expect(
        component.topLeftPosition,
        component.position - component.size / 2,
      );
    });

    test('component with anchor topLeft has the correct center', () {
      final PositionComponent component = MyComponent();
      component.position.setValues(2.0, 1.0);
      component.size.setValues(3.0, 1.0);
      component.angle = 0.0;
      component.anchor = Anchor.topLeft;

      expect(component.center, component.position + component.size / 2);
      expect(component.absoluteCenter, component.position + component.size / 2);
    });

    test('component with parent has the correct center', () {
      final parent = MyComponent();
      parent.position.setValues(2.0, 1.0);
      parent.anchor = Anchor.topLeft;
      final child = MyComponent();
      child.position.setValues(2.0, 1.0);
      child.size.setValues(3.0, 1.0);
      child.angle = 0.0;
      child.anchor = Anchor.topLeft;
      parent.addChild(child);

      expect(child.absoluteTopLeftPosition, child.position + parent.position);
      expect(
        child.absoluteTopLeftPosition,
        child.topLeftPosition + parent.topLeftPosition,
      );
      expect(child.absoluteCenter, parent.position + child.center);
    });
  });
}
