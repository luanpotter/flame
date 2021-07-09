import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';

class SpriteSystem extends BaseSystem {
  @override
  List<Filter<Component>> get filters => [Has<SpriteComponent>()];

  @override
  void renderEntity(Canvas canvas, Entity entity) {
    final size = entity.get<SizeComponent>()!.size;
    final sprite = entity.get<SpriteComponent>()?.sprite;

    sprite?.render(canvas, size: size);
  }
}
