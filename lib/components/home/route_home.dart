import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteHome extends StatelessWidget {
  static final router = SubRouter(
    'home',
    Icons.home,
    () => RouteHome(),
    label: '首页',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'home',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
