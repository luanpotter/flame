import 'dart:ui' hide Offset;

import '../anchor.dart';
import '../extensions/offset.dart';
import '../extensions/rect.dart';
import '../extensions/vector2.dart';
import '../geometry/rectangle.dart';
import 'base_component.dart';
import 'component.dart';
import 'mixins/hitbox.dart';

/// A [Component] implementation that represents a component that has a
/// specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension [size], on the [position],
/// rotated around its [anchor] with angle [angle].
///
/// It also uses the [anchor] property to properly position itself.
///
/// A [PositionComponent] can have children. The children are all updated and
/// rendered automatically when this is updated and rendered.
/// They are translated by this component's (x,y). They do not need to fit
/// within this component's (width, height).
abstract class PositionComponent extends BaseComponent {
  /// The position of this component on the screen (relative to the anchor).
  final Vector2 _position;
  Vector2 get position => _position;
  set position(Vector2 position) => _position.setFrom(position);

  /// X position of this component on the screen (relative to the anchor).
  double get x => _position.x;
  set x(double x) => _position.x = x;

  /// Y position of this component on the screen (relative to the anchor).
  double get y => _position.y;
  set y(double y) => _position.y = y;

  /// The size that this component is rendered with.
  /// This is not necessarily the source size of the asset.
  final Vector2 _size;
  Vector2 get size => _size;
  set size(Vector2 size) => _size.setFrom(size);

  /// Width (size) that this component is rendered with.
  double get width => size.x;
  set width(double width) => size.x = width;

  /// Height (size) that this component is rendered with.
  double get height => size.y;
  set height(double height) => size.y = height;

  /// Get the absolute position, with the anchor taken into consideration
  Vector2 get absolutePosition => absoluteParentPosition + position;

  /// Get the relative top left position regardless of the anchor and angle
  Vector2 get topLeftPosition {
    return anchor.toOtherAnchorPosition(
      position,
      Anchor.topLeft,
      size,
    );
  }

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position = position + (anchor.toVector2()..multiply(size));
  }

  /// Get the absolute top left position regardless of whether it is a child or not
  Vector2 get absoluteTopLeftPosition {
    final p = parent;
    if (p is PositionComponent) {
      return p.absoluteTopLeftPosition + topLeftPosition;
    } else {
      return topLeftPosition;
    }
  }

  /// Get the position that everything in this component is positioned in relation to
  /// If this component has no parent the absolute parent position is the origin,
  /// otherwise it's the parents absolute top left position
  Vector2 get absoluteParentPosition {
    final p = parent;
    if (p is PositionComponent) {
      return p.absoluteTopLeftPosition;
    } else {
      return Vector2.zero();
    }
  }

  /// Get the position of the center of the component's bounding rectangle
  Vector2 get center {
    if (anchor == Anchor.center) {
      return position;
    } else {
      return anchor.toOtherAnchorPosition(position, Anchor.center, size)
        ..rotate(angle, center: absolutePosition);
    }
  }

  /// Get the absolute center of the component
  Vector2 get absoluteCenter => absoluteParentPosition + center;

  /// Angle (with respect to the x-axis) this component should be rendered with.
  /// It is rotated around its anchor.
  double angle;

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [position] is relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor anchor;

  /// Whether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Whether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  /// Returns the relative position/size of this component.
  /// Relative because it might be translated by their parents (which is not considered here).
  Rect toRect() => topLeftPosition.toPositionedRect(size);

  /// Returns the absolute position/size of this component.
  /// Absolute because it takes any possible parent position into consideration.
  Rect toAbsoluteRect() => absoluteTopLeftPosition.toPositionedRect(size);

  /// Mutates position and size using the provided [rect] as basis.
  /// This is a relative rect, same definition that [toRect] use
  /// (therefore both methods are compatible, i.e. setByRect ∘ toRect = identity).
  void setByRect(Rect rect) {
    size.setValues(rect.width, rect.height);
    topLeftPosition = rect.topLeft.toVector2();
  }

  PositionComponent({
    Vector2? position,
    Vector2? size,
    this.angle = 0.0,
    this.anchor = Anchor.topLeft,
    this.renderFlipX = false,
    this.renderFlipY = false,
    int? priority,
  })  : _position = position ?? Vector2.zero(),
        _size = size ?? Vector2.zero(),
        super(priority: priority);

  @override
  bool containsPoint(Vector2 point) {
    final rectangle = Rectangle.fromRect(toAbsoluteRect(), angle: angle)
      ..position = absoluteCenter;
    return rectangle.containsPoint(point);
  }

  double angleTo(PositionComponent c) => position.angleTo(c.position);

  double distance(PositionComponent c) => position.distanceTo(c.position);

  @override
  void renderDebugMode(Canvas canvas) {
    if (this is Hitbox) {
      (this as Hitbox).renderHitboxes(canvas);
    }
    canvas.drawRect(size.toRect(), debugPaint);
    debugTextPaint.render(
      canvas,
      'x: ${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}',
      Vector2(-50, -15),
    );

    final rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextPaint.render(
      canvas,
      'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
      Vector2(width - 50, height),
    );
  }

  @override
  void preRender(Canvas canvas) {
    canvas.translate(x, y);
    canvas.rotate(angle);
    final delta = -anchor.toVector2()
      ..multiply(size);
    canvas.translate(delta.x, delta.y);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
    }
  }
}
