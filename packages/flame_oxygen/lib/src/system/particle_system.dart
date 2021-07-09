part of flame_oxygen.system;

/// Allows Particles from Flame to be rendered.
class ParticleSystem extends System with RenderSystem, UpdateSystem {
  Query? _query;

  @override
  void init() => _query = createQuery([Has<ParticleComponent>()]);

  @override
  void dispose() {
    _query = null;
    super.dispose();
  }

  @override
  void render(Canvas canvas) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      final particle = entity.get<ParticleComponent>()!.particle;
      particle?.render(canvas);
    }
  }

  @override
  void update(double delta) {
    for (final entity in _query?.entities ?? <Entity>[]) {
      final particle = entity.get<ParticleComponent>()!.particle;
      particle?.update(delta);
    }
  }
}
