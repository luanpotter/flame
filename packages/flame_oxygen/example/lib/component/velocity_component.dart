import 'package:flame/extensions.dart';
import 'package:flame_oxygen/flame_oxygen.dart';

class VelocityComponent extends Component<Vector2> {
  late Vector2 _velocity;

  Vector2 get velocity => _velocity;
  set velocity(Vector2 position) => _velocity.setFrom(position);

  @override
  void init([Vector2? velocity]) => _velocity = velocity ?? Vector2.zero();

  @override
  void reset() => _velocity.setZero();
}
