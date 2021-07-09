part of flame_oxygen.component;

class ParticleComponent extends Component<Particle> {
  Particle? particle;

  /// Returns progress of the [particle].
  double? get progress => particle?.progress;

  @override
  void init([Particle? data]) => particle = data;

  @override
  void reset() => particle = null;
}
