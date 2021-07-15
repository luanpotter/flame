import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../extensions.dart';
import '../../extensions/size.dart';
import '../game.dart';
import '../game_render_box.dart';
import 'gestures.dart';

typedef GameLoadingWidgetBuilder = Widget Function(
  BuildContext,
);

typedef GameErrorWidgetBuilder = Widget Function(
  BuildContext,
  Object error,
);

typedef OverlayWidgetBuilder<T extends Game> = Widget Function(
  BuildContext context,
  T game,
);

/// A [StatefulWidget] that is in charge of attaching a [Game] instance into the flutter tree
///
class GameWidget<T extends Game> extends StatefulWidget {
  /// The game instance in which this widget will render
  final T game;

  /// The text direction to be used in text elements in a game.
  final TextDirection? textDirection;

  /// Builder to provide a widget tree to be built whilst the [Future] provided
  /// via [Game.onLoad] is not resolved. By default this is an empty Container().
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// If set, errors during the onLoad method will not be thrown
  /// but instead this widget will be shown. If not provided, errors are
  /// propagated up.
  final GameErrorWidgetBuilder? errorBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor]
  final WidgetBuilder? backgroundBuilder;

  /// A map to show widgets overlay.
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// A List of the initially active overlays, this is used only on the first build of the widget.
  /// To control the overlays that are active use [Game.overlays]
  ///
  /// See also:
  /// - [new GameWidget]
  /// - [Game.overlays]
  final List<String>? initialActiveOverlays;

  /// Renders a [game] in a flutter widget tree.
  ///
  /// Ex:
  /// ```
  /// ...
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: MyGameClass(),
  ///   )
  /// }
  /// ...
  /// ```
  ///
  /// It is also possible to render layers of widgets over the game surface with widget subtrees.
  ///
  /// To do that a [overlayBuilderMap] should be provided. The visibility of
  /// these overlays are controlled by [Game.overlays] property
  ///
  /// Ex:
  /// ```
  /// ...
  ///
  /// final game = MyGame();
  ///
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: game,
  ///     overlayBuilderMap: {
  ///       'PauseMenu': (ctx, game) {
  ///         return Text('A pause menu');
  ///       },
  ///     },
  ///   )
  /// }
  /// ...
  /// game.overlays.add('PauseMenu');
  /// ```
  const GameWidget({
    Key? key,
    required this.game,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
  }) : super(key: key);

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with HasWidgetsOverlay.
  @override
  _GameWidgetState<T> createState() => _GameWidgetState<T>();
}

class _GameWidgetState<T extends Game> extends State<GameWidget<T>> {
  Set<String> initialActiveOverlays = {};

  Future<void>? _gameLoaderFuture;
  Future<void> get _gameLoaderFutureCache =>
      _gameLoaderFuture ?? (_gameLoaderFuture = widget.game.onLoad());

  @override
  void initState() {
    super.initState();

    // Add the initial overlays
    _initActiveOverlays();

    addOverlaysListener(widget.game);
  }

  void _initActiveOverlays() {
    if (widget.initialActiveOverlays == null) {
      return;
    }
    _checkOverlays(widget.initialActiveOverlays!.toSet());
    widget.initialActiveOverlays!.forEach((key) {
      widget.game.overlays.add(key);
    });
  }

  @override
  void didUpdateWidget(GameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game != widget.game) {
      removeOverlaysListener(oldWidget.game);

      // Reset the overlays
      _initActiveOverlays();
      addOverlaysListener(widget.game);

      // Reset the loader future
      _gameLoaderFuture = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    removeOverlaysListener(widget.game);
  }

  // widget overlay stuff
  void addOverlaysListener(T game) {
    widget.game.overlays.addListener(onChangeActiveOverlays);
    initialActiveOverlays = widget.game.overlays.value;
  }

  void removeOverlaysListener(T game) {
    game.overlays.removeListener(onChangeActiveOverlays);
  }

  void _checkOverlays(Set<String> overlays) {
    overlays.forEach((overlayKey) {
      assert(
        widget.overlayBuilderMap?.containsKey(overlayKey) ?? false,
        'A non mapped overlay has been added: $overlayKey',
      );
    });
  }

  void onChangeActiveOverlays() {
    _checkOverlays(widget.game.overlays.value);
    setState(() {
      initialActiveOverlays = widget.game.overlays.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget internalGameWidget = _GameRenderObjectWidget(widget.game);

    final hasBasicDetectors = hasBasicGestureDetectors(widget.game);
    final hasAdvancedDetectors = hasAdvancedGesturesDetectors(widget.game);

    assert(
      !(hasBasicDetectors && hasAdvancedDetectors),
      '''
        WARNING: Both Advanced and Basic detectors detected.
        Advanced detectors will override basic detectors and the later will not receive events
      ''',
    );

    if (hasBasicDetectors) {
      internalGameWidget = applyBasicGesturesDetectors(
        widget.game,
        internalGameWidget,
      );
    } else if (hasAdvancedDetectors) {
      internalGameWidget = applyAdvancedGesturesDetectors(
        widget.game,
        internalGameWidget,
      );
    }

    if (hasMouseDetectors(widget.game)) {
      internalGameWidget = applyMouseDetectors(
        widget.game,
        internalGameWidget,
      );
    }

    final stackedWidgets = [internalGameWidget];
    _addBackground(context, stackedWidgets);
    _addOverlays(context, stackedWidgets);

    // We can use Directionality.maybeOf when that method lands on stable
    final textDir = widget.textDirection ?? TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Container(
        color: widget.game.backgroundColor(),
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            widget.game.onResize(constraints.biggest.toVector2());
            return FutureBuilder(
              future: _gameLoaderFutureCache,
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  if (widget.errorBuilder == null) {
                    throw snapshot.error!;
                  } else {
                    return widget.errorBuilder!(context, snapshot.error!);
                  }
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(children: stackedWidgets);
                }
                return widget.loadingBuilder?.call(context) ?? Container();
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _addBackground(BuildContext context, List<Widget> stackWidgets) {
    if (widget.backgroundBuilder == null) {
      return stackWidgets;
    }
    final backgroundContent = KeyedSubtree(
      key: ValueKey(widget.game),
      child: widget.backgroundBuilder!(context),
    );
    stackWidgets.insert(0, backgroundContent);
    return stackWidgets;
  }

  List<Widget> _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    if (widget.overlayBuilderMap == null) {
      return stackWidgets;
    }
    final widgets = initialActiveOverlays.map((String overlayKey) {
      final builder = widget.overlayBuilderMap![overlayKey]!;
      return KeyedSubtree(
        key: ValueKey(overlayKey),
        child: builder(context, widget.game),
      );
    });
    stackWidgets.addAll(widgets);
    return stackWidgets;
  }
}

class _GameRenderObjectWidget extends LeafRenderObjectWidget {
  final Game game;

  const _GameRenderObjectWidget(this.game);

  @override
  RenderBox createRenderObject(BuildContext context) {
    return GameRenderBox(context, game);
  }

  @override
  void updateRenderObject(BuildContext context, GameRenderBox renderObject) {
    renderObject.game = game;
  }
}
