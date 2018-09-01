import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteConfiguration extends StatelessWidget {
  static final router = SubRouter(
    'settings',
    Icons.settings,
    () => RouteConfiguration(),
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'settings',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
