import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  final List<JoystickAction>? actions;
  final JoystickDirectional? directional;
  final bool keyboardEnable;
  bool _isDirectionalDownKeyboard = false;
  LogicalKeyboardKey? _currentDirectionalKey;

  Joystick({
    this.actions,
    this.directional,
    this.keyboardEnable = false,
  });

  void initialize(Vector2 size) async {
    directional?.initialize(size, this);
    actions?.forEach((action) => action.initialize(size, this));
  }

  void addAction(JoystickAction action) {
    if (actions != null && gameRef?.size != null) {
      action.initialize(gameRef!.size, this);
      actions?.add(action);
    }
  }

  void removeAction(dynamic actionId) {
    actions?.removeWhere((action) => action.actionId == actionId);
  }

  void render(Canvas canvas) {
    directional?.render(canvas);
    actions?.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    directional?.update(t);
    actions?.forEach((action) => action.update(t));
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    actions?.forEach((action) => action.actionUp(event.pointer));
    directional?.directionalUp(event.pointer);
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    directional?.directionalDown(event.pointer, event.localPosition);
    actions?.forEach((action) {
      action.actionDown(event.pointer, event.localPosition);
    });
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {
    actions?.forEach((action) {
      action.actionMove(event.pointer, event.localPosition);
    });
    directional?.directionalMove(event.pointer, event.localPosition);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    actions?.forEach((action) => action.actionUp(event.pointer));
    directional?.directionalUp(event.pointer);
  }

  @override
  void onKeyboard(RawKeyEvent event) {
    if (!keyboardEnable) return;
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }

      if (!_isDirectionalDownKeyboard) {
        joystickAction(
          JoystickActionEvent(
            id: event.logicalKey.keyId,
            event: ActionEvent.DOWN,
          ),
        );
      }
    } else if (event is RawKeyUpEvent &&
        _isDirectionalDownKeyboard &&
        _currentDirectionalKey == event.logicalKey) {
      _isDirectionalDownKeyboard = false;
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    initialize(gameSize);
    super.onGameResize(gameSize);
  }

  @override
  Future<void> onLoad() async {
    await directional?.onLoad();
    if (actions != null) {
      await Future.forEach<JoystickAction>(actions!, (element) {
        return element.onLoad();
      });
    }
  }
}
