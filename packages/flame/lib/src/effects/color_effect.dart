import 'dart:ui';

import 'package:flutter/animation.dart';

import '../components/mixins/has_paint.dart';
import 'effects.dart';

class ColorEffect extends ComponentEffect<HasPaint> {
  final Color color;
  final double duration;
  final String? paintId;

  late Paint _original;

  late ColorTween _tween;

  ColorEffect({
    required this.color,
    required this.duration,
    this.paintId,
    Curve? curve,
    bool initialIsInfinite = false,
    bool initialIsAlternating = false,
  }) : super(
          initialIsInfinite,
          initialIsAlternating,
          curve: curve,
        );

  @override
  void initialize(HasPaint component) {
    super.initialize(component);
    peakTime = duration;

    _original = component.getPaint(paintId);

    _tween = ColorTween(
      begin: _original.color,
      end: color,
    );
  }

  @override
  void setComponentToEndState() {
    component?.tint(color);
  }

  @override
  void setComponentToOriginalState() {
    component?.paint = _original;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final color = _tween.lerp(curveProgress);
    if (color != null) {
      component?.tint(color);
    }
  }
}
