import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

import '../../components.dart';
import '../../extensions.dart';
import '../components/component.dart';
import '../components/mixins/collidable.dart';
import '../components/mixins/draggable.dart';
import '../components/mixins/has_collidables.dart';
import '../components/mixins/has_game_ref.dart';
import '../components/mixins/hoverable.dart';
import '../components/mixins/tappable.dart';
import '../fps_counter.dart';
import 'camera.dart';
import 'game.dart';
import 'projector.dart';
import 'viewport.dart';

/// This is a more complete and opinionated implementation of Game.
///
/// BaseGame should be extended to add your game logic.
/// [update], [render] and [onResize] methods have default implementations.
/// This is the recommended structure to use for most games.
/// It is based on the Component system.
class BaseGame extends Game with FPSCounter {
  /// The list of components to be updated and rendered by the base game.
  late final ComponentSet components = createComponentSet();

  /// The camera translates the coordinate space after the viewport is applied.
  final Camera camera = Camera();

  /// The viewport transforms the coordinate space depending on your chosen
  /// implementation.
  /// The default implementation no-ops, but you can use this to have a fixed
  /// screen ratio for example.
  Viewport get viewport => _viewport;

  Viewport _viewport = DefaultViewport();
  set viewport(Viewport value) {
    if (hasLayout) {
      final previousSize = canvasSize;
      _viewport = value;
      onResize(previousSize);
    } else {
      _viewport = value;
    }
    _combinedProjector = Projector.compose([camera, value]);
  }

  late Projector _combinedProjector;

  final Vector2 _sizeBuffer = Vector2.zero();

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations and camera zooming.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size {
    assertHasLayout();
    return _sizeBuffer
      ..setFrom(viewport.effectiveSize)
      ..scale(1 / camera.zoom);
  }

  /// This is the original Flutter widget size, without any transformation.
  Vector2 get canvasSize {
    assertHasLayout();
    return viewport.canvasSize;
  }

  BaseGame() {
    camera.gameRef = this;
    _combinedProjector = Projector.compose([camera, viewport]);
  }

  /// This method setps up the OrderedSet instance used by this game, before
  /// any lifecycle methods happen.
  ///
  /// You can return a specific sub-class of OrderedSet, like
  /// [QueryableOrderedSet] for example, that we use for Collidables.
  ComponentSet createComponentSet() {
    final components = ComponentSet.createDefault(
      (c, {BaseGame? gameRef}) => prepare(c),
    );
    if (this is HasCollidables) {
      components.register<Collidable>();
    }
    return components;
  }

  /// This method is called for every component added.
  /// It does preparation on a component before any update or render method is called on it.
  ///
  /// You can use this to setup your mixins, pre-calculate stuff on every component, or anything you desire.
  /// By default, this calls the first time resize for every component, so don't forget to call super.preAdd when overriding.
  @mustCallSuper
  void prepare(Component c) {
    assert(
      hasLayout,
      '"prepare/add" called before the game is ready. Did you try to access it on the Game constructor? Use the "onLoad" method instead.',
    );

    if (c is Collidable) {
      assert(
        this is HasCollidables,
        'You can only use the Hitbox/Collidable feature with games that has the HasCollidables mixin',
      );
    }
    if (c is Tappable) {
      assert(
        this is HasTappableComponents,
        'Tappable Components can only be added to a BaseGame with HasTappableComponents',
      );
    }
    if (c is Draggable) {
      assert(
        this is HasDraggableComponents,
        'Draggable Components can only be added to a BaseGame with HasDraggableComponents',
      );
    }
    if (c is Hoverable) {
      assert(
        this is HasHoverableComponents,
        'Hoverable Components can only be added to a BaseGame with HasHoverableComponents',
      );
    }

    if (debugMode && c is BaseComponent) {
      c.debugMode = true;
    }

    if (c is HasGameRef) {
      c.gameRef = this;
    }

    // first time resize
    c.onGameResize(size);
  }

  /// Prepares and registers a component to be added on the next game tick
  ///
  /// This methods is an async operation since it await the `onLoad` method of
  /// the component. Nevertheless, this method only need to be waited to finish
  /// if by some reason, your logic needs to be sure that the component has
  /// finished loading, otherwise, this method can be called without waiting
  /// for it to finish as the BaseGame already handle the loading of the
  /// component.
  ///
  /// *Note:* Do not add components on the game constructor. This method can
  /// only be called after the game already has its layout set, this can be
  /// verified by the [hasLayout] property, to add components upon a game
  /// initialization, the [onLoad] method can be used instead.
  Future<void> add(Component c) {
    return components.addChild(c);
  }

  /// Adds a list of components, calling addChild for each one.
  ///
  /// The returned Future completes once all are loaded and added.
  /// Component loading is done in parallel.
  Future<void> addAll(Iterable<Component> cs) {
    return components.addChildren(cs);
  }

  /// Removes a component from the component list, calling onRemove for it and
  /// its children.
  void remove(Component c) {
    components.remove(c);
  }

  /// Removes all the components in the list and calls onRemove for all of them
  /// and their children.
  void removeAll(Iterable<Component> cs) {
    components.removeAll(cs);
  }

  /// This implementation of render basically calls [renderComponent] for every component, making sure the canvas is reset for each one.
  ///
  /// You can override it further to add more custom behavior.
  /// Beware of however you are rendering components if not using this; you must be careful to save and restore the canvas to avoid components messing up with each other.
  @override
  @mustCallSuper
  void render(Canvas canvas) {
    viewport.render(canvas, (c) {
      components.forEach((comp) => renderComponent(c, comp));
    });
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component c) {
    canvas.save();
    if (!c.isHud) {
      camera.apply(canvas);
    }
    c.renderTree(canvas);
    canvas.restore();
  }

  /// This implementation of update updates every component in the list.
  ///
  /// It also actually adds the components added via [add] since the previous tick,
  /// and remove those that are marked for destruction via the [Component.shouldRemove] method.
  /// You can override it further to add more custom behavior.
  @override
  @mustCallSuper
  void update(double dt) {
    components.updateComponentList();

    if (this is HasCollidables) {
      (this as HasCollidables).handleCollidables();
    }

    components.forEach((c) => c.update(dt));
    camera.update(dt);
  }

  /// This implementation of resize passes the resize call along to every
  /// component in the list, enabling each one to make their decisions as how to handle the resize.
  ///
  /// It also updates the [size] field of the class to be used by later added components and other methods.
  /// You can override it further to add more custom behavior, but you should seriously consider calling the super implementation as well.
  /// This implementation also uses the current [viewport] in order to transform the coordinate system appropriately.
  @override
  @mustCallSuper
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);
    viewport.resize(canvasSize.clone());
    components.forEach((c) => c.onGameResize(size));
  }

  /// Returns whether this [Game] is in debug mode or not.
  ///
  /// Returns `false` by default. Override it, or set it to true, to use debug mode.
  /// You can use this value to enable debug behaviors for your game and many components will
  /// show extra information on the screen when debug mode is activated
  bool debugMode = false;

  /// Changes the priority of [component] and reorders the games component list.
  ///
  /// Returns true if changing the component's priority modified one of the
  /// components that existed directly on the game and false if it
  /// either was a child of another component, if it didn't exist at all or if
  /// it was a component added directly on the game but its priority didn't
  /// change.
  bool changePriority(
    Component component,
    int priority, {
    bool reorderRoot = true,
  }) {
    if (component.priority == priority) {
      return false;
    }
    component.changePriorityWithoutResorting(priority);
    if (reorderRoot) {
      if (component.parent != null && component.parent is BaseComponent) {
        (component.parent! as BaseComponent).reorderChildren();
      } else if (components.contains(component)) {
        components.rebalanceAll();
      }
    }
    return true;
  }

  /// Since changing priorities is quite an expensive operation you should use
  /// this method if you want to change multiple priorities at once so that the
  /// tree doesn't have to be reordered multiple times.
  void changePriorities(Map<Component, int> priorities) {
    var hasRootComponents = false;
    final parents = <BaseComponent>{};
    priorities.forEach((component, priority) {
      final wasUpdated = changePriority(
        component,
        priority,
        reorderRoot: false,
      );
      if (wasUpdated) {
        if (component.parent != null && component.parent is BaseComponent) {
          parents.add(component.parent! as BaseComponent);
        } else {
          hasRootComponents |= components.contains(component);
        }
      }
    });
    if (hasRootComponents) {
      components.rebalanceAll();
    }
    parents.forEach((parent) => parent.reorderChildren());
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  @override
  Vector2 projectVector(Vector2 vector) {
    return _combinedProjector.projectVector(vector);
  }

  @override
  Vector2 unprojectVector(Vector2 vector) {
    return _combinedProjector.unprojectVector(vector);
  }

  @override
  Vector2 scaleVector(Vector2 vector) {
    return _combinedProjector.scaleVector(vector);
  }

  @override
  Vector2 unscaleVector(Vector2 vector) {
    return _combinedProjector.unscaleVector(vector);
  }
}
