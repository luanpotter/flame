part of flame_oxygen.system;

/// Allow a [System] to be part of the update loop from Flame.
mixin UpdateSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// The [Game] this system belongs to.
  OxygenGame? get game => world?.game;

  /// Implement this method to update the game state, given the time [delta]
  /// that has passed since the last update.
  void update(double delta);

  @override
  void execute(double delta) => throw Exception(
        'UpdateSystem.execute is not supported in flame_oxygen',
      );
}
