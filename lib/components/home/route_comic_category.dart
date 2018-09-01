import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteComicCategory extends StatelessWidget {
  static final router = SubRouter(
    'comic_category',
    Icons.category,
    () => RouteComicCategory(),
    label: '漫画大全',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'comic_category',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
