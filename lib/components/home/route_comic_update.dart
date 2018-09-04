import 'package:flutter/material.dart';

import './sub_router.dart';
import './comic_list.dart';

class RouteComicUpdate extends StatelessWidget {
  static final router = SubRouter(
    'comic_update',
    Icons.update,
    () => RouteComicUpdate(),
    label: '最近更新',
  );

  @override
  Widget build(BuildContext context) => ComicList(router);
}
