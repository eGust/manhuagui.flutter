import 'package:flutter/material.dart';

import './sub_router.dart';
import './home_comic_list.dart';

class RouteComicCategory extends StatelessWidget {
  static final router = SubRouter(
    'comic_category',
    Icons.category,
    () => RouteComicCategory(),
    label: '漫画大全',
  );

  @override
  Widget build(BuildContext context) => HomeComicList(router);
}
