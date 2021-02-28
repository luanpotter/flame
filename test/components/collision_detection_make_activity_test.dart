import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/collision_detection.dart'
    as CollisionDetectionFunction;
import 'package:test/test.dart';

class _TestBlock extends PositionComponent with Hitbox, Collidable {
  Set<Collidable> onCollisions = {};
  Set<Collidable> cacheCollisions = {};
  _TestBlock() {
    addShape(HitboxCircle());
  }
  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    onCollisions.add(other);
    super.onCollision(points, other);
  }
}

class _TestBlockA extends _TestBlock {
  _TestBlockA(Vector2 pos, Vector2 size) {
    activeCollision = false;
    position = pos;
    this.size = size;
  }
}

class _TestBlockB extends _TestBlock {
  _TestBlockB(Vector2 pos, Vector2 size) {
    activeCollision = false;
    position = pos;
    this.size = size;
  }
}

class _TestBlockC extends _TestBlock {
  _TestBlockC(Vector2 pos, Vector2 size) {
    activeCollision = true;
    position = pos;
    this.size = size;
  }
}

class _TestBlockD extends _TestBlock {
  _TestBlockD(Vector2 pos, Vector2 size) {
    activeCollision = true;
    position = pos;
    this.size = size;
  }
}

void _testCollisionDetection(List<Collidable> collidables) {
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    for (var y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points =
          CollisionDetectionFunction.intersections(collidableX, collidableY);
      if (points.isNotEmpty) {
        collidableX.onCollision(points, collidableY);
        collidableY.onCollision(points, collidableX);
      }
    }
  }
}

void main() {
  group('collision_detection_make_activity', () {
    test('Activity Marker is no empty tests', () {
      final tba = _TestBlockA(Vector2(0, 0), Vector2(10, 10));
      final tbb = _TestBlockA(Vector2(0, 0), Vector2(10, 10));
      final tbc = _TestBlockA(Vector2(0, 0), Vector2(10, 10));
      final tbs = [tba, tbb, tbc];
      _testCollisionDetection(tbs);
      tbs.forEach((element) {
        element.cacheCollisions = element.onCollisions;
      });
      CollisionDetectionFunction.collisionDetection(tbs);
      tbs.forEach((element) {
        expect(element.cacheCollisions.isNotEmpty, true);
        expect(element.onCollisions.isNotEmpty, true);
      });
    });
    test('Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(x.toDouble(), y.toDouble()));
        }
      }

      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
            return _TestBlockA(e, size);
          case 1:
            return _TestBlockB(e, size);
          case 2:
            return _TestBlockC(e, size);
          case 3:
            return _TestBlockD(e, size);
        }
      }).toList();
      cList.shuffle();
      _testCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollisions = element.onCollisions;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollision;
      }).forEach((element) {
        expect(
          element.cacheCollisions.length == element.onCollisions.length,
          true,
        );

        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollisions)
                    ..addAll(element.onCollisions))
                  .length ==
              element.onCollisions.length,
          true,
        );
      });
    });

    test('No Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(x.toDouble(), y.toDouble()));
        }
      }

      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
            return _TestBlockA(e, size);
          case 1:
            return _TestBlockB(e, size);
          case 2:
            return _TestBlockA(e, size);
          case 3:
            return _TestBlockB(e, size);
        }
      }).toList();
      cList.shuffle();
      _testCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollisions = element.onCollisions;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollision;
      }).forEach((element) {
        expect(
          element.cacheCollisions.length == element.onCollisions.length,
          true,
        );

        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollisions)
                    ..addAll(element.onCollisions))
                  .length ==
              element.onCollisions.length,
          true,
        );
      });
    });

    test('Random Activity Marker tests', () {
      final size = Vector2(5, 5);
      final vList = <Vector2>[];
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 10; x++) {
          vList.add(Vector2(
            x.toDouble() * Random().nextInt(4),
            y.toDouble() * Random().nextInt(4),
          ));
        }
      }
      final cList = vList.map((e) {
        switch (e.x.toInt() % 4) {
          case 0:
            return _TestBlockA(e, size);
          case 1:
            return _TestBlockB(e, size);
          case 2:
            return _TestBlockC(e, size);
          case 3:
            return _TestBlockD(e, size);
        }
      }).toList();
      cList.shuffle();
      _testCollisionDetection(cList);
      cList.forEach((element) {
        element.cacheCollisions = element.onCollisions;
      });
      CollisionDetectionFunction.collisionDetection(cList);
      cList.where((element) {
        return element.activeCollision;
      }).forEach((element) {
        expect(
          element.cacheCollisions.length == element.onCollisions.length,
          true,
        );
        expect(
          (<Collidable>{}
                    ..addAll(element.cacheCollisions)
                    ..addAll(element.onCollisions))
                  .length ==
              element.onCollisions.length,
          true,
        );
      });
    });
  });
}
