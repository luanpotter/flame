import '../../../components.dart';
import '../../../game.dart';
import '../../components/position_component.dart';
import '../../extensions/vector2.dart';
import '../../geometry/rectangle.dart';
import 'hitbox.dart';

/// [CollidableType.active] collides with other [Collidable]s of type active or static
/// [CollidableType.passive] collides with other [Collidable]s of type active
/// [CollidableType.inactive] will not collide with any other [Collidable]s
enum CollidableType {
  active,
  passive,
  inactive,
}

mixin Collidable on Hitbox {
  CollidableType collidableType = CollidableType.active;

  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {}
  void onCollisionEnd(Collidable other) {}
}

class ScreenCollidable extends PositionComponent
    with Hitbox, Collidable, HasGameRef<BaseGame> {
  @override
  CollidableType collidableType = CollidableType.passive;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    addHitbox(HitboxRectangle());
  }

  final _zeroVector = Vector2.zero();
  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.unprojectVector(_zeroVector);
    size = gameRef.size;
  }
}
