import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteComicRank extends StatelessWidget {
  static final router = SubRouter(
    'comic_rank',
    Icons.insert_chart,
    () => RouteComicRank(),
    label: '排行榜',
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'comic_rank',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
