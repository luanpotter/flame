import 'package:flame_oxygen/flame_oxygen.dart';

class TimerComponent extends Component<double> {
  late double _maxTime;

  /// Max time in seconds.
  double get maxTime => _maxTime;

  late double _timePassed;

  /// Passed time in seconds.
  double get timePassed => _timePassed;

  set timePassed(double time) {
    _timePassed = time.clamp(0, maxTime);
  }

  bool get done => _timePassed >= _maxTime;

  double get percentage => _timePassed / _maxTime;

  @override
  void init([double? maxTime]) {
    _maxTime = maxTime ?? 0;
    _timePassed = 0;
  }

  @override
  void reset() {
    _maxTime = 0;
    _timePassed = 0;
  }
}
