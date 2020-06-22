import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/joystick/Joystick_action.dart';
import 'package:flame/components/joystick/Joystick_directional.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';

abstract class JoystickListener {
  void joystickChangeDirectional(JoystickDirectionalEvent event);
  void joystickAction(JoystickActionEvent event);
}

abstract class JoystickController extends Component with HasGameRef<BaseGame> {
  final List<JoystickListener> _observers = [];

  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _observers.forEach((o) => o.joystickChangeDirectional(event));
  }

  void joystickAction(JoystickActionEvent event) {
    _observers.forEach((o) => o.joystickAction(event));
  }

  void addObserver(JoystickListener listener) {
    _observers.add(listener);
  }

  void onReceiveDrag(DragEvent drag) {}

  @override
  bool isHud() => true;
}

class JoystickComponent extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;

  JoystickComponent({this.actions, this.directional});

  void addAction(JoystickAction action) {
    if (gameRef?.size != null) {
      action.initialize(gameRef.size, this);
      actions?.add(action);
    }
  }

  void removeAction(int actionId) {
    actions?.removeWhere((action) => action.actionId == actionId);
  }

  @override
  void render(Canvas canvas) {
    directional?.render(canvas);
    actions?.forEach((action) => action.render(canvas));
  }

  @override
  void update(double t) {
    directional?.update(t);
    actions?.forEach((action) => action.update(t));
  }

  @override
  void resize(Size size) {
    directional?.initialize(size, this);
    actions?.forEach((action) => action.initialize(size, this));
    super.resize(size);
  }

  @override
  void onReceiveDrag(DragEvent event) {
    directional?.onReceiveDrag(event);
    actions?.forEach((action) => action.onReceiveDrag(event));
  }
}