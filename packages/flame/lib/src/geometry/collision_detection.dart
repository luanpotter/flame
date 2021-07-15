import '../../extensions.dart';
import '../../geometry.dart';
import '../components/mixins/collidable.dart';

final Set<int> _collidableHashes = {};
final Set<int> _shapeHashes = {};

int _collidableTypeCompare(Collidable a, Collidable b) {
  return a.collidableType.index - b.collidableType.index;
}

/// Check whether any [Collidable] in [collidables] collide with each other and
/// call their onCollision methods accordingly.
void collisionDetection(List<Collidable> collidables) {
  collidables.sort(_collidableTypeCompare);
  for (var x = 0; x < collidables.length; x++) {
    final collidableX = collidables[x];
    if (collidableX.collidableType != CollidableType.active) {
      break;
    }

    for (var y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      if (collidableY.collidableType == CollidableType.inactive) {
        break;
      }

      final intersectionPoints = intersections(collidableX, collidableY);
      if (intersectionPoints.isNotEmpty) {
        collidableX.onCollision(intersectionPoints, collidableY);
        collidableY.onCollision(intersectionPoints, collidableX);
        final collisionHash = _combinedHash(collidableX, collidableY);
        _collidableHashes.add(collisionHash);
      } else {
        _handleCollisionEnd(collidableX, collidableY);
      }
    }
  }
}

bool hasActiveCollision(Collidable collidableA, Collidable collidableB) {
  return _collidableHashes.contains(
    _combinedHash(collidableA, collidableB),
  );
}

bool hasActiveShapeCollision(HitboxShape shapeA, HitboxShape shapeB) {
  return _shapeHashes.contains(
    _combinedHash(shapeA, shapeB),
  );
}

void _handleCollisionEnd(Collidable collidableA, Collidable collidableB) {
  if (hasActiveCollision(collidableA, collidableB)) {
    collidableA.onCollisionEnd(collidableB);
    collidableB.onCollisionEnd(collidableA);
    _collidableHashes.remove(_combinedHash(collidableA, collidableB));
  }
}

void _handleShapeCollisionEnd(HitboxShape shapeA, HitboxShape shapeB) {
  if (hasActiveShapeCollision(shapeA, shapeB)) {
    shapeA.onCollisionEnd(shapeB);
    shapeB.onCollisionEnd(shapeA);
    _shapeHashes.remove(_combinedHash(shapeA, shapeB));
  }
}

/// Check what the intersection points of two collidables are
/// returns an empty list if there are no intersections
Set<Vector2> intersections(
  Collidable collidableA,
  Collidable collidableB,
) {
  if (!collidableA.possiblyOverlapping(collidableB)) {
    // These collidables can't have any intersection points
    if (hasActiveCollision(collidableA, collidableB)) {
      for (final shapeA in collidableA.hitboxes) {
        for (final shapeB in collidableB.hitboxes) {
          _handleShapeCollisionEnd(shapeA, shapeB);
        }
      }
    }
    return {};
  }

  final result = <Vector2>{};
  final currentResult = <Vector2>{};
  for (final shapeA in collidableA.hitboxes) {
    for (final shapeB in collidableB.hitboxes) {
      currentResult.addAll(shapeA.intersections(shapeB));
      if (currentResult.isNotEmpty) {
        result.addAll(currentResult);
        // Do callbacks to the involved shapes
        shapeA.onCollision(currentResult, shapeB);
        shapeB.onCollision(currentResult, shapeA);
        currentResult.clear();
        _shapeHashes.add(_combinedHash(shapeA, shapeB));
      } else {
        _handleShapeCollisionEnd(shapeA, shapeB);
      }
    }
  }
  return result;
}

int _combinedHash(Object o1, Object o2) {
  return o1.hashCode ^ o2.hashCode;
}
