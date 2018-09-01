import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteFavorite extends StatelessWidget {
  static final router = SubRouter(
    'favorite',
    Icons.favorite,
    () => RouteFavorite(),
    label: '我的收藏',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'favorite',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
