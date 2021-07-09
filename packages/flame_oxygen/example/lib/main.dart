import 'dart:math';

import 'package:example/component/timer_component.dart';
import 'package:example/system/kawabunga_system.dart';
import 'package:flame/game.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'component/velocity_component.dart';
import 'system/debug_system.dart';
import 'system/move_system.dart';
import 'system/sprite_system.dart';

void main() {
  runApp(GameWidget(game: ExampleGame()));
}

class ExampleGame extends OxygenGame with FPSCounter {
  @override
  Future<void> init() async {
    if (kDebugMode) {
      world.registerSystem(DebugSystem());
    }
    world.registerSystem(MoveSystem());
    world.registerSystem(SpriteSystem());
    world.registerSystem(KawabungaSystem());

    world.registerComponent<TimerComponent, double>(() => TimerComponent());
    world.registerComponent<VelocityComponent, Vector2>(
      () => VelocityComponent(),
    );

    final random = Random();
    for (var i = 0; i < 10; i++) {
      createEntity(
        name: 'Entity $i',
        position: size / 2,
        size: Vector2.all(64),
        angle: 0,
      )
        ..add<SpriteComponent, SpriteInit>(
          SpriteInit(await loadSprite('pizza.png')),
        )
        ..add<VelocityComponent, Vector2>(Vector2(
          random.nextDouble() * 100 * (random.nextDouble() < 0.5 ? 1 : -1),
          random.nextDouble() * 100 * (random.nextDouble() < 0.5 ? 1 : -1),
        ));
    }
  }
}
