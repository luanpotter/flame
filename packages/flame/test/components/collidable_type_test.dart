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

class TestBlock extends PositionComponent with Hitbox, Collidable {
  final List<Collidable> collisions = List.empty(growable: true);

  TestBlock(Vector2 position, Vector2 size, CollidableType type)
      : super(
          position: position,
          size: size,
        ) {
    collidableType = type;
    addHitbox(
      HitboxRectangle(),
    );
  }

  bool collidedWith(Collidable otherCollidable) {
    return collisions.contains(otherCollidable);
  }

  bool collidedWithAll(
    List<Collidable> otherCollidables, {
    bool containsSelf = true,
  }) {
    return collisions
            .toSet()
            .containsAll(otherCollidables.toList()..remove(this)) &&
        collisions.length == otherCollidables.length - (containsSelf ? 1 : 0);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    collisions.add(other);
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
    'Varying CollisionType tests',
    () {
      test('Actives do collide', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.active,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.active,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensors do not collide', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.passive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.passive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.isEmpty, true);
        expect(blockB.collisions.isEmpty, true);
      });

      test('Inactives do not collide', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.inactive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.inactive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.isEmpty, true);
        expect(blockB.collisions.isEmpty, true);
      });

      test('Active collides with static', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.active,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.passive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensor collides with active', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.passive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.active,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collidedWith(blockB), true);
        expect(blockB.collidedWith(blockA), true);
        expect(blockA.collisions.length, 1);
        expect(blockB.collisions.length, 1);
      });

      test('Sensor does not collide with inactive', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.passive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.inactive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Inactive does not collide with static', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.inactive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.passive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Active does not collide with inactive', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.active,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.inactive,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Inactive does not collide with active', () {
        final blockA = TestBlock(
          Vector2.zero(),
          Vector2.all(10),
          CollidableType.inactive,
        );
        final blockB = TestBlock(
          Vector2.all(1),
          Vector2.all(10),
          CollidableType.active,
        );
        gameWithCollidables([blockA, blockB]);
        expect(blockA.collisions.length, 0);
        expect(blockB.collisions.length, 0);
      });

      test('Correct collisions with many involved collidables', () {
        final actives = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.active,
          ),
        );
        final statics = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.passive,
          ),
        );
        final inactives = List.generate(
          100,
          (_) => TestBlock(
            Vector2.random() - Vector2.random(),
            Vector2.all(10),
            CollidableType.inactive,
          ),
        );
        gameWithCollidables((actives + statics + inactives)..shuffle());
        expect(
          actives.fold<bool>(
            true,
            (hasCorrectCollisions, c) => c.collidedWithAll(actives + statics),
          ),
          true,
        );
        expect(
          statics.fold<bool>(
            true,
            (hasCorrectCollisions, c) =>
                c.collidedWithAll(actives, containsSelf: false),
          ),
          true,
        );
        expect(
          inactives.fold<bool>(
            true,
            (hasCorrectCollisions, c) => c.collisions.isEmpty,
          ),
          true,
        );
      });
    },
  );
}
