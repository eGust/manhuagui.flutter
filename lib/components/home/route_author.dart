import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteAuthor extends StatelessWidget {
  static final router = SubRouter(
    'author',
    Icons.person,
    () => RouteAuthor(),
    label: '漫画家',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'author',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
