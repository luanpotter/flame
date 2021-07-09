part of flame_oxygen.system;

/// Allow a [System] to be part of the render loop from Flame.
mixin RenderSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// The [Game] this system belongs to.
  Game? get game => world?.game;

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  @override
  void execute(double delta) => throw Exception(
        'RenderSystem.execute is not supported in flame_oxygen',
      );
}
