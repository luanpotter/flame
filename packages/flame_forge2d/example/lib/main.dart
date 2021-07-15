import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:forge2d_samples/widget_sample.dart';

import 'blob_sample.dart';
import 'camera_sample.dart';
import 'circle_stress_sample.dart';
import 'composition_sample.dart';
import 'contact_callbacks_sample.dart';
import 'domino_sample.dart';
import 'draggable_sample.dart';
import 'joint_sample.dart';
import 'mouse_joint_sample.dart';
import 'position_body_sample.dart';
import 'sprite_body_sample.dart';
import 'tappable_sample.dart';

String link(String example) =>
    'https://github.com/flame-engine/flame_forge2d/tree/main/example/lib/$example';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dashbook = Dashbook(theme: ThemeData.dark());

  dashbook.storiesOf('Flame with Forge2D').decorator(TopDecorator())
    ..add(
      'Blob sample',
      (DashbookContext ctx) => GameWidget(game: BlobSample()),
      codeLink: link('blob_sample.dart'),
    )
    ..add(
      'Composition sample',
      (DashbookContext ctx) => GameWidget(game: CompositionSample()),
      codeLink: link('composition_sample.dart'),
      info: CompositionSample.info,
    )
    ..add(
      'Domino sample',
      (DashbookContext ctx) => GameWidget(game: DominoSample()),
      codeLink: link('domino_sample.dart'),
    )
    ..add(
      'Contact Callbacks',
      (DashbookContext ctx) => GameWidget(game: ContactCallbacksSample()),
      codeLink: link('contact_callbacks_sample.dart'),
    )
    ..add(
      'Circle stress sample',
      (DashbookContext ctx) => GameWidget(game: CircleStressSample()),
      codeLink: link('circle_stress_sample.dart'),
    )
    ..add(
      'Sprite Bodies',
      (DashbookContext ctx) => GameWidget(game: SpriteBodySample()),
      codeLink: link('sprite_body_sample.dart'),
    )
    ..add(
      'PositionBodyComponent',
      (DashbookContext ctx) => GameWidget(game: PositionBodySample()),
      codeLink: link('position_body_sample.dart'),
    )
    ..add(
      'Tappable Body',
      (DashbookContext ctx) => GameWidget(game: TappableSample()),
      codeLink: link('tappable_sample.dart'),
    )
    ..add(
      'Draggable Body',
      (DashbookContext ctx) => GameWidget(game: DraggableSample()),
      codeLink: link('draggable_sample.dart'),
    )
    ..add(
      'Basic joint',
      (DashbookContext ctx) => GameWidget(game: JointSample()),
      codeLink: link('joint_sample.dart'),
    )
    ..add(
      'Mouse Joint',
      (DashbookContext ctx) => GameWidget(game: MouseJointSample()),
      codeLink: link('mouse_joint_sample.dart'),
    )
    ..add(
      'Camera',
      (DashbookContext ctx) => GameWidget(game: CameraSample()),
      codeLink: link('camera_sample.dart'),
    )
    ..add(
      'Widget overlay',
      (DashbookContext ctx) => WidgetSample.gameWidget(),
      codeLink: link('widget_sample.dart'),
    );
  runApp(dashbook);
}

class TopDecorator extends Decorator {
  @override
  Widget decorate(Widget child) {
    return Align(
      child: child,
      alignment: Alignment.topCenter,
    );
  }
}
