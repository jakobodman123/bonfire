import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/game_interface/interface_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameInterface extends GameComponent {
  List<InterfaceComponent> _components = [];
  final textConfigGreen = TextConfig(color: Colors.green, fontSize: 14);
  final textConfigYellow = TextConfig(color: Colors.yellow, fontSize: 14);
  final textConfigRed = TextConfig(color: Colors.red, fontSize: 14);

  @override
  bool get isHud => true;

  @override
  int get priority =>
      LayerPriority.getPriorityInterface(gameRef?.highestPriority ?? 0);

  @override
  void render(Canvas c) {
    _components.forEach((i) => i.render(c));
    _drawFPS(c);
  }

  @override
  void update(double t) {
    _components.forEach((i) {
      i.gameRef = gameRef;
      i.update(t);
    });
  }

  @override
  void onGameResize(Vector2 size) {
    _components.forEach((i) => i.onGameResize(size));
    super.onGameResize(size);
  }

  Future<void> add(InterfaceComponent component) async {
    removeById(component.id);
    await component.onLoad();
    _components.add(component);
  }

  void removeById(int id) {
    if (_components.isEmpty) return;
    _components.removeWhere((i) => i.id == id);
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _components.forEach((i) => i.handlerPointerDown(event));
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    _components.forEach((i) => i.handlerPointerUp(event));
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    _components.forEach((i) => i.handlerPointerCancel(event));
  }

  void _drawFPS(Canvas c) {
    if (gameRef?.showFPS == true && gameRef?.size != null) {
      double? fps = gameRef?.fps(100);
      getTextConfigFps(fps ?? 0.0).render(
        c,
        'FPS: ${fps?.toStringAsFixed(2)}',
        Vector2((gameRef?.size.x ?? 0.0) - 100, 20),
      );
    }
  }

  TextConfig getTextConfigFps(double fps) {
    if (fps >= 58) {
      return textConfigGreen;
    }

    if (fps >= 48) {
      return textConfigYellow;
    }

    return textConfigRed;
  }

  @override
  Future<void> onLoad() {
    return Future.forEach<InterfaceComponent>(_components, (element) {
      return element.onLoad();
    });
  }

  @override
  bool hasGesture() => true;
}
