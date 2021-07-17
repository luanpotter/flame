import 'dart:ui';

import '../../../components.dart';
import '../../palette.dart';

const _kMain = 'main';

/// Adds a collection of paints to a component
///
/// Component will always have a main Paint that can be accessed
/// by the [paint] getter/setter and other paints can be manipulated/accessed
/// using [getPaint], [setPaint] and [deletePaint]
mixin HasPaint on BaseComponent {
  final Map<String, Paint> _paints = {
    'main': BasicPalette.white.paint(),
  };

  Paint get paint => _paints[_kMain]!;
  set paint(Paint paint) => _paints[_kMain] = paint;

  /// Gets a paint from the collection
  Paint getPaint(String? key) {
    final paint = _paints[key ?? _kMain];

    if (paint == null) {
      throw ArgumentError('No Paint found for $key');
    }

    return paint;
  }

  /// Sets a paint on the collection
  void setPaint(String key, Paint paint) => _paints[key] = paint;

  /// Removes a paint from the collection
  ///
  /// Note that the main paint can't be removed
  void deletePaint(String key) {
    if (key == _kMain) {
      throw ArgumentError('Cannot remove the main paint');
    }

    _paints.remove(key);
  }

  void makeTransparent({String? paintId}) {
    setOpacity(0, paintId: paintId);
  }

  void makeOpaque({String? paintId}) {
    setOpacity(1, paintId: paintId);
  }

  void setOpacity(double opacity, {String? paintId}) {
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('Opacity needs to be between 0 and 1');
    }

    getPaint(paintId).color = paint.color.withOpacity(opacity);
  }

  double getOpacity({String? paintId}) {
    return getPaint(paintId).color.opacity;
  }

  void setColor(Color color, {String? paintId}) {
    getPaint(paintId).color = color;
  }

  void tint(Color color, {String? paintId}) {
    getPaint(paintId).colorFilter = ColorFilter.mode(color, BlendMode.multiply);
  }
}
