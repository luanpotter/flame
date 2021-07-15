import 'dart:ui';

import 'package:meta/meta.dart';

import '../../game.dart';
import '../../input.dart';
import '../effects/effects.dart';
import '../effects/effects_handler.dart';
import '../extensions/vector2.dart';
import '../text.dart';
import 'component.dart';
import 'component_set.dart';
import 'mixins/has_game_ref.dart';

/// This can be extended to represent a basic Component for your game.
///
/// The difference between this and [Component] is that the [BaseComponent] can
/// have children, handle effects and can be used to see whether a position on
/// the screen is on your component, which is useful for handling gestures.
abstract class BaseComponent extends Component {
  final EffectsHandler _effectsHandler = EffectsHandler();

  late final ComponentSet children = createComponentSet();

  /// If the component has a parent it will be set here
  BaseComponent? _parent;

  @override
  BaseComponent? get parent => _parent;

  /// This is set by the BaseGame to tell this component to render additional
  /// debug information, like borders, coordinates, etc.
  /// This is very helpful while debugging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to
  /// identify issues.
  bool debugMode = false;

  Color debugColor = const Color(0xFFFF00FF);

  Paint get debugPaint => Paint()
    ..color = debugColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  TextPaint get debugTextPaint => TextPaint(
        config: TextPaintConfig(
          color: debugColor,
          fontSize: 12,
        ),
      );

  BaseComponent({int? priority}) : super(priority: priority);

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components on [BaseGame] are always updated by the same amount. The
  /// time each one takes to update adds up to the next update cycle.
  @mustCallSuper
  @override
  void update(double dt) {
    children.updateComponentList();
    _effectsHandler.update(dt);
    children.forEach((c) => c.update(dt));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    preRender(canvas);
  }

  @mustCallSuper
  @override
  void renderTree(Canvas canvas) {
    render(canvas);
    postRender(canvas);
    children.forEach((c) {
      canvas.save();
      c.renderTree(canvas);
      canvas.restore();
    });

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  /// A render cycle callback that runs before the component and its children
  /// has been rendered.
  @protected
  void preRender(Canvas canvas) {}

  /// A render cycle callback that runs after the component has been
  /// rendered, but before any children has been rendered.
  void postRender(Canvas canvas) {}

  void renderDebugMode(Canvas canvas) {}

  @mustCallSuper
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    children.forEach((child) => child.onGameResize(gameSize));
  }

  @mustCallSuper
  @override
  void onMount() {
    super.onMount();
    children.forEach((child) => child.onMount());
  }

  @mustCallSuper
  @override
  void onRemove() {
    super.onRemove();
    children.forEach((child) => child.onRemove());
  }

  /// Called to check whether the point is to be counted as within the component
  /// It needs to be overridden to have any effect, like it is in
  /// PositionComponent.
  bool containsPoint(Vector2 point) => false;

  /// Add an effect to the component
  void addEffect(ComponentEffect effect) {
    _effectsHandler.add(effect, this);
  }

  /// Mark an effect for removal on the component
  void removeEffect(ComponentEffect effect) {
    _effectsHandler.removeEffect(effect);
  }

  /// Remove all effects
  void clearEffects() {
    _effectsHandler.clearEffects();
  }

  /// Get a list of non removed effects
  List<ComponentEffect> get effects => _effectsHandler.effects;

  void prepare(Component child, {Game? gameRef}) {
    if (this is HasGameRef) {
      final c = this as HasGameRef;
      gameRef ??= c.hasGameRef ? c.gameRef : null;
    } else if (gameRef == null) {
      assert(
        !isMounted,
        'Parent was already added to Game and has no HasGameRef; in this case, gameRef is mandatory.',
      );
    }
    if (gameRef is BaseGame) {
      gameRef.prepare(child);
    }

    if (child is BaseComponent) {
      child._parent = this;
      child.debugMode = debugMode;
    }
  }

  /// Uses the game passed in, or uses the game from [HasGameRef] otherwise,
  /// to prepare the child component before it is added to the list of children.
  /// Note that this component needs to be added to the game first if
  /// [this.gameRef] should be used to prepare the child.
  /// For children that don't need preparation from the game instance can
  /// disregard both the options given above.
  Future<void> addChild(Component child, {BaseGame? gameRef}) {
    return children.addChild(child, gameRef: gameRef);
  }

  /// Adds mutiple children.
  ///
  /// See [addChild] for details (or `children.addChildren()`).
  Future<void> addChildren(List<Component> cs, {BaseGame? gameRef}) {
    return children.addChildren(cs, gameRef: gameRef);
  }

  /// Whether the children list contains the given component.
  ///
  /// This method uses reference equality.
  bool containsChild(Component c) => children.contains(c);

  /// Call this if any of this component's children priorities have changed
  /// at runtime.
  ///
  /// This will call `rebalanceAll` on the [children] ordered set.
  void reorderChildren() => children.rebalanceAll();

  /// This method first calls the passed handler on the leaves in the tree,
  /// the children without any children of their own.
  /// Then it continues through all other children. The propagation continues
  /// until the handler returns false, which means "do not continue", or when
  /// the handler has been called with all children
  ///
  /// This method is important to be used by the engine to propagate actions
  /// like rendering, taps, etc, but you can call it yourself if you need to
  /// apply an action to the whole component chain.
  /// It will only consider components of type T in the hierarchy,
  /// so use T = Component to target everything.
  bool propagateToChildren<T extends Component>(
    bool Function(T) handler,
  ) {
    var shouldContinue = true;
    for (final child in children) {
      if (child is BaseComponent) {
        shouldContinue = child.propagateToChildren(handler);
      }
      if (shouldContinue && child is T) {
        shouldContinue = handler(child);
      }
      if (!shouldContinue) {
        break;
      }
    }
    return shouldContinue;
  }

  @protected
  Vector2 eventPosition(PositionInfo info) {
    return isHud ? info.eventPosition.widget : info.eventPosition.game;
  }

  ComponentSet createComponentSet() {
    final components = ComponentSet.createDefault(prepare);
    if (this is HasGameRef) {
      components.register<HasGameRef>();
    }
    return components;
  }
}
