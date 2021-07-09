import 'package:flame/game.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flutter/material.dart';

class DebugSystem extends BaseSystem {
  final debugPaint = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.stroke;

  final textPainter = TextPaint(
    config: const TextPaintConfig(
      color: Colors.green,
      fontSize: 10,
    ),
  );

  @override
  List<Filter<Component>> get filters => [];

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPainter.copyWith((config) => config.withFontSize(16)).render(
          canvas,
          [
            'FPS: ${(world!.game as FPSCounter).fps()}',
            'Entities: ${world!.entities.length}',
          ].join('\n'),
          Vector2.zero(),
        );
  }

  @override
  void renderEntity(Canvas canvas, Entity entity) {
    final size = entity.get<SizeComponent>()!.size;

    canvas.drawRect(Vector2.zero() & size, debugPaint);

    textPainter.render(
      canvas,
      [
        'position: ${entity.get<PositionComponent>()!.position}',
        'size: $size',
        'angle: ${entity.get<AngleComponent>()?.radians ?? 0}',
        'anchor: ${entity.get<AnchorComponent>()?.anchor ?? Anchor.topLeft}'
      ].join('\n'),
      Vector2(size.x + 2, 0),
    );
    textPainter.render(
      canvas,
      entity.name ?? '',
      Vector2(size.x / 2, size.y + 2),
      anchor: Anchor.topCenter,
    );
  }
}
