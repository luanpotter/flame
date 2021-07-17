import 'package:flutter/material.dart';

import '../components/base_component.dart';
import '../components/position_component.dart';
import '../extensions/vector2.dart';

export './color_effect.dart';
export './move_effect.dart';
export './opacity_effect.dart';
export './rotate_effect.dart';
export './scale_effect.dart';
export './sequence_effect.dart';

abstract class ComponentEffect<T extends BaseComponent> {
  T? component;
  Function()? onComplete;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  bool _isPaused = false;
  bool get isPaused => _isPaused;
  void resume() => _isPaused = false;
  void pause() => _isPaused = true;

  /// If the animation should first follow the initial curve and then follow the
  /// curve backwards
  bool isInfinite;
  bool isAlternating;
  final bool isRelative;
  final bool _initialIsInfinite;
  final bool _initialIsAlternating;
  double? percentage;
  double curveProgress = 0.0;
  double peakTime = 0.0;
  double currentTime = 0.0;
  double driftTime = 0.0;
  int curveDirection = 1;
  Curve curve;

  /// If this is set to true the effect will not be set to its original state
  /// once it is done.
  bool skipEffectReset = false;

  double get iterationTime => peakTime * (isAlternating ? 2 : 1);

  ComponentEffect(
    this._initialIsInfinite,
    this._initialIsAlternating, {
    this.isRelative = false,
    Curve? curve,
    this.onComplete,
  })  : isInfinite = _initialIsInfinite,
        isAlternating = _initialIsAlternating,
        curve = curve ?? Curves.linear;

  @mustCallSuper
  void update(double dt) {
    if (isAlternating) {
      curveDirection = isMax() ? -1 : (isMin() ? 1 : curveDirection);
    }
    if (isInfinite) {
      if ((!isAlternating && isMax()) || (isAlternating && isMin())) {
        reset();
      }
    }
    if (!hasCompleted()) {
      currentTime += (dt + driftTime) * curveDirection;
      percentage = (currentTime / peakTime).clamp(0.0, 1.0).toDouble();
      curveProgress = curve.transform(percentage!);
      _updateDriftTime();
      currentTime = currentTime.clamp(0.0, peakTime).toDouble();
    }
  }

  @mustCallSuper
  void initialize(T component) {
    this.component = component;
  }

  void dispose() => _isDisposed = true;

  /// Whether the effect has completed or not.
  bool hasCompleted() {
    return (!isInfinite && !isAlternating && isMax()) ||
        (!isInfinite && isAlternating && isMin()) ||
        isDisposed;
  }

  bool isMax() => percentage == null ? false : percentage == 1.0;
  bool isMin() => percentage == null ? false : percentage == 0.0;
  bool isRootEffect() => component?.effects.contains(this) == true;

  /// Resets the effect and the component which the effect was added to.
  void reset() {
    resetEffect();
    setComponentToOriginalState();
  }

  /// Resets the effect to its original state so that it can be re-run.
  void resetEffect() {
    _isDisposed = false;
    percentage = null;
    currentTime = 0.0;
    curveDirection = 1;
    isInfinite = _initialIsInfinite;
    isAlternating = _initialIsAlternating;
  }

  // When the time overshoots the max and min it needs to add that time to
  // whatever is going to happen next, for example an alternation or
  // following effect in a SequenceEffect.
  void _updateDriftTime() {
    if (isMax()) {
      driftTime = currentTime - peakTime;
    } else if (isMin()) {
      driftTime = currentTime.abs();
    } else {
      driftTime = 0;
    }
  }

  /// Called when the effect is removed from the component.
  /// Calls the [onComplete] callback if it is defined and sets the effect back
  /// to its original state so that it can be re-added.
  void onRemove() {
    onComplete?.call();
    if (!skipEffectReset) {
      resetEffect();
    }
  }

  void setComponentToOriginalState();
  void setComponentToEndState();
}

abstract class PositionComponentEffect
    extends ComponentEffect<PositionComponent> {
  /// Used to be able to determine the start state of the component
  Vector2? originalPosition;
  double? originalAngle;
  Vector2? originalSize;

  /// Used to be able to determine the end state of a sequence of effects
  Vector2? endPosition;
  double? endAngle;
  Vector2? endSize;

  /// Whether the state of a certain field was modified by the effect
  final bool modifiesPosition;
  final bool modifiesAngle;
  final bool modifiesSize;

  PositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    bool isRelative = false,
    Curve? curve,
    this.modifiesPosition = false,
    this.modifiesAngle = false,
    this.modifiesSize = false,
    VoidCallback? onComplete,
  }) : super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          curve: curve,
          onComplete: onComplete,
        );

  @mustCallSuper
  @override
  void initialize(PositionComponent component) {
    super.initialize(component);
    this.component = component;
    originalPosition = component.position.clone();
    originalAngle = component.angle;
    originalSize = component.size.clone();

    /// If these aren't modified by the extending effect it is assumed that the
    /// effect didn't bring the component to another state than the one it
    /// started in
    endPosition = component.position.clone();
    endAngle = component.angle;
    endSize = component.size.clone();
  }

  /// Only change the parts of the component that is affected by the
  /// effect, and only set the state if it is the root effect (not part of
  /// another effect, like children of a CombinedEffect or SequenceEffect).
  void _setComponentState(Vector2? position, double? angle, Vector2? size) {
    if (isRootEffect()) {
      if (modifiesPosition) {
        assert(
          position != null,
          '`position` must not be `null` for an effect which modifies `position`',
        );
        component?.position.setFrom(position!);
      }
      if (modifiesAngle) {
        assert(
          angle != null,
          '`angle` must not be `null` for an effect which modifies `angle`',
        );
        component?.angle = angle!;
      }
      if (modifiesSize) {
        assert(
          size != null,
          '`size` must not be `null` for an effect which modifies `size`',
        );
        component?.size.setFrom(size!);
      }
    }
  }

  @override
  void setComponentToOriginalState() {
    _setComponentState(originalPosition, originalAngle, originalSize);
  }

  @override
  void setComponentToEndState() {
    _setComponentState(endPosition, endAngle, endSize);
  }
}

abstract class SimplePositionComponentEffect extends PositionComponentEffect {
  double? duration;
  double? speed;

  SimplePositionComponentEffect(
    bool initialIsInfinite,
    bool initialIsAlternating, {
    this.duration,
    this.speed,
    Curve? curve,
    bool isRelative = false,
    bool modifiesPosition = false,
    bool modifiesAngle = false,
    bool modifiesSize = false,
    VoidCallback? onComplete,
  })  : assert(
          (duration != null) ^ (speed != null),
          'Either speed or duration necessary',
        ),
        super(
          initialIsInfinite,
          initialIsAlternating,
          isRelative: isRelative,
          curve: curve,
          modifiesPosition: modifiesPosition,
          modifiesAngle: modifiesAngle,
          modifiesSize: modifiesSize,
          onComplete: onComplete,
        );
}
