import 'package:flutter/services.dart';

class StatusBar {
  bool _hidden = false;
  bool get hidden => _hidden;
  set hidden(bool value) {
    if (value == _hidden) return;
    _hidden = value;
    SystemChrome.setEnabledSystemUIOverlays(value ? [] : SystemUiOverlay.values);
  }
}
