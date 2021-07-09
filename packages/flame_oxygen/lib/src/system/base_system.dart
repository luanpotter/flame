part of flame_oxygen.system;

/// System that provides base rendering for default components.
///
/// Based on the PositionComponent logic from Flame.
abstract class BaseSystem extends System with RenderSystem {
  Query? _query;

  /// List of all the entities found using the [filters].
  List<Entity> get entities => _query?.entities ?? [];

  /// Filters used for querying entities.
  ///
  /// The [PositionComponent] and [SizeComponent] will be added automatically.
  List<Filter<Component>> get filters;

  @override
  @mustCallSuper
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      ...filters,
    ]);
  }

  @override
  void dispose() {
    _query = null;
    super.dispose();
  }

  @override
  void render(Canvas canvas) {
    for (final entity in entities) {
      final position = entity.get<PositionComponent>()!;
      final size = entity.get<SizeComponent>()!.size;
      final anchor = entity.get<AnchorComponent>()?.anchor ?? Anchor.topLeft;
      final angle = entity.get<AngleComponent>()?.radians ?? 0;

      canvas
        ..save()
        ..translate(position.x, position.y)
        ..rotate(angle);

      final delta = -anchor.toVector2()
        ..multiply(size);
      canvas.translate(delta.x, delta.y);

      // Handle inverted rendering by moving center and flipping.
      // if (renderFlipX || renderFlipY) {
      //   canvas.translate(width / 2, height / 2);
      //   canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      //   canvas.translate(-width / 2, -height / 2);
      // }
      renderEntity(canvas, entity);

      canvas.restore();
    }
  }

  /// Render given entity.
  ///
  /// The canvas is already prepared for this entity.
  void renderEntity(Canvas canvas, Entity entity);
}
