import 'package:flutter/material.dart';

import 'sub_router.dart';
import 'home_comic_list.dart';

class RouteComicNewest extends StatelessWidget {
  static final router = SubRouter(
    'comic_newest',
    Icons.drive_eta,
    () => RouteComicNewest(),
    label: '新上架',
  );

  @override
  Widget build(BuildContext context) => HomeComicList(router);
}
