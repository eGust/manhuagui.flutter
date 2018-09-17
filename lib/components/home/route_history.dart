import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteHistory extends StatelessWidget {
  static final router = SubRouter(
    'history',
    Icons.history,
    () => RouteHistory(),
    label: '最近阅读',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'history',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
