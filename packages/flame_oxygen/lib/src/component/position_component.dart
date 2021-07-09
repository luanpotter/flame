part of flame_oxygen.component;

class PositionComponent extends Component<Vector2> {
  late Vector2 _position;

  Vector2 get position => _position;
  set position(Vector2 position) => _position.setFrom(position);

  double get x => _position.x;
  set x(double x) => _position.x = x;

  double get y => _position.y;
  set y(double y) => _position.y = y;

  @override
  void init([Vector2? position]) {
    _position = position?.clone() ?? Vector2.zero();
  }

  @override
  void reset() => _position.setZero();
}
