import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:forge2d/forge2d.dart' hide Transform;

import 'boundaries.dart';

class WidgetSample extends Forge2DGame with TapDetector {
  Body? currentBody;
  Function()? updateState;

  Vector2 screenPosition() {
    return worldToScreen(currentBody?.worldCenter ?? Vector2.zero());
  }

  WidgetSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    addAll(boundaries);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updateState?.call();
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    if (currentBody != null) {
      world.destroyBody(currentBody!);
    }

    final bodyDef = BodyDef()
      ..angularVelocity = 3
      ..position = details.eventPosition.game
      ..type = BodyType.dynamic;
    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = 2;
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..restitution = 0.95;
    body.createFixture(fixtureDef);
    currentBody = body;
  }

  static GameWidget gameWidget() {
    return GameWidget<WidgetSample>(
      game: WidgetSample(),
      overlayBuilderMap: {
        'button': (ctx, game) {
          return BodyButtonWidget(game);
        },
      },
      initialActiveOverlays: const ['button'],
    );
  }
}

class BodyButtonWidget extends StatefulWidget {
  final WidgetSample _game;

  const BodyButtonWidget(this._game);

  @override
  State<StatefulWidget> createState() {
    return _BodyButtonState(_game);
  }
}

class _BodyButtonState extends State<BodyButtonWidget> {
  final WidgetSample _game;

  _BodyButtonState(this._game) {
    _game.updateState = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _game.screenPosition().y,
      right: _game.screenPosition().x,
      child: widgets.Transform.rotate(
        angle: _game.currentBody?.angle ?? 1.0,
        child: ElevatedButton(
          onPressed: () => setState(() => print(_game.currentBody?.angle)),
          child: const Text(
            'Flying button!',
            textScaleFactor: 2.0,
          ),
        ),
      ),
    );
  }
}
