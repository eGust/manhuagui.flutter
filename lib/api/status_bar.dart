import 'package:flutter/services.dart';

abstract class StatusBar {
  static bool _hidden = false;

  static bool get hidden => _hidden;
  static set hidden(bool value) {
    if (value == _hidden) return;
    _hidden = value;
    SystemChrome.setEnabledSystemUIOverlays(
        value ? [] : SystemUiOverlay.values);
  }

  static void init() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  static void hide() {
    hidden = true;
  }

  static void show() {
    hidden = false;
  }
}
