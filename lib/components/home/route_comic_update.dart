import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteComicUpdate extends StatelessWidget {
  static final router = SubRouter(
    'comic_update',
    Icons.update,
    () => RouteComicUpdate(),
    label: '最近更新',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'comic_update',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
