import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

class TestGame extends BaseGame with HasCollidables {
  TestGame() {
    onResize(Vector2.all(200));
  }
}

class TestHitbox extends HitboxRectangle {
  final Set<HitboxShape> collisions = {};
  int endCounter = 0;

  TestHitbox() {
    onCollision = (_, shape) => collisions.add(shape);
    onCollisionEnd = (shape) {
      endCounter++;
      collisions.remove(shape);
    };
  }

  bool hasCollisionWith(HitboxShape otherShape) {
    return collisions.contains(otherShape);
  }
}

class TestBlock extends PositionComponent with Hitbox, Collidable {
  final Set<Collidable> collisions = {};
  final hitbox = TestHitbox();
  int endCounter = 0;

  TestBlock(Vector2 position, Vector2 size)
      : super(
          position: position,
          size: size,
        ) {
    addHitbox(hitbox);
  }

  bool hasCollisionWith(Collidable otherCollidable) {
    return collisions.contains(otherCollidable);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    collisions.add(other);
  }

  @override
  void onCollisionEnd(Collidable other) {
    endCounter++;
    collisions.remove(other);
  }
}

void main() {
  TestGame gameWithCollidables(List<Collidable> collidables) {
    final game = TestGame();
    game.addAll(collidables);
    game.update(0);
    expect(game.components.isNotEmpty, collidables.isNotEmpty);
    return game;
  }

  group(
    'Collision callbacks are called properly',
    () {
      test('collidable callbacks are called', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
        );
        final game = gameWithCollidables([blockA, blockB]);
        expect(blockA.hasCollisionWith(blockB), true);
        expect(blockB.hasCollisionWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
        blockB.position = Vector2.all(21);
        expect(blockA.endCounter, 0);
        expect(blockB.endCounter, 0);
        game.update(0);
        expect(blockA.hasCollisionWith(blockB), false);
        expect(blockB.hasCollisionWith(blockA), false);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
        game.update(0);
        expect(blockA.endCounter, 1);
        expect(blockB.endCounter, 1);
      });

      test('hitbox callbacks are called', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
        );
        final hitboxA = blockA.hitbox;
        final hitboxB = blockB.hitbox;
        final game = gameWithCollidables([blockA, blockB]);
        expect(hitboxA.hasCollisionWith(hitboxB), true);
        expect(hitboxB.hasCollisionWith(hitboxA), true);
        expect(hitboxA.collisions.length, 1);
        expect(hitboxB.collisions.length, 1);
        blockB.position = Vector2.all(21);
        expect(hitboxA.endCounter, 0);
        expect(hitboxB.endCounter, 0);
        game.update(0);
        expect(hitboxA.hasCollisionWith(hitboxB), false);
        expect(hitboxB.hasCollisionWith(hitboxA), false);
        expect(hitboxA.collisions.length, 0);
        expect(hitboxB.collisions.length, 0);
        game.update(0);
        expect(hitboxA.endCounter, 1);
        expect(hitboxB.endCounter, 1);
      });
    },
  );
}
