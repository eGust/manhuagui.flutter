import 'package:flutter/material.dart';

typedef WidgetGenerator = Widget Function();

class SubRouter {
  SubRouter(
    this.path,
    this.icon,
    this.createWidget,
    { String label }
  ) : this.label = label;

  final String path;
  final IconData icon;
  final String label;
  final WidgetGenerator createWidget;
}
