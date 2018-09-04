import 'package:flutter/material.dart';

import './sub_router.dart';
import './comic_list.dart';

class RouteComicRank extends StatelessWidget {
  static final router = SubRouter(
    'comic_rank',
    Icons.insert_chart,
    () => RouteComicRank(),
    label: '排行榜',
  );

  @override
  Widget build(BuildContext context) => ComicList(router);
}
