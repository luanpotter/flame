part of flame_oxygen.component;

class SizeComponent extends Component<Vector2> {
  late Vector2 _size;

  Vector2 get size => _size;
  set size(Vector2 position) => _size.setFrom(position);

  double get width => _size.x;
  set width(double x) => _size.x = width;

  double get height => _size.y;
  set height(double height) => _size.y = height;

  @override
  void init([Vector2? size]) => _size = size?.clone() ?? Vector2.zero();

  @override
  void reset() => _size.setZero();
}
