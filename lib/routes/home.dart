import 'package:flutter/material.dart';

import '../components/home/side_bar.dart';
import '../components/home/route_configuration.dart';
import '../components/home/route_author.dart';
import '../components/home/route_comic_category.dart';
import '../components/home/route_comic_rank.dart';
import '../components/home/route_comic_update.dart';
import '../components/home/route_favorite.dart';
import '../components/home/route_history.dart';
import '../components/home/route_home.dart';

const TEST_URL = 'https://i.hamreus.com/ps1/g/GrandBlue/%E7%AC%AC19%E5%9B%9E/03.jpg.webp?cid=199830&md5=tt2xffnmOLvq8k_RumWz_g';

class Home extends StatefulWidget{
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _path = 'home';
  String get path => _path;
  set path(String val) {
    if (_path == val) return;
    _current.focused = false;
    _path = val;
    _current.focused = true;
  }

  SideBarItem get _current => sbItemMap[_path];

  Map<String, SideBarItem> sbItemMap;
  List<SideBarItem> sbItemList;
  SideBarItem sbSettings;

  SideBarItem convertSideBarItem(SubRouter router) =>
    SideBarItem(
      icon: router.icon,
      label: router.label,
      createWidget: router.createWidget,
      onPressed: () => setState(() {
        this.path = router.path;
      }),
    );

  void init() {
    sbSettings = convertSideBarItem(RouteConfiguration.router);
    sbItemMap = { 'settings': sbSettings };

    final sbRouterItems = [
      RouteHome.router,
      RouteComicUpdate.router,
      RouteComicCategory.router,
      RouteComicRank.router,
      RouteAuthor.router,
      RouteFavorite.router,
      RouteHistory.router,
    ];
    sbItemList = sbRouterItems.map((router) {
      final sb = convertSideBarItem(router);
      sbItemMap[router.path] = sb;
      return sb;
    }).toList();

    _current.focused = true;
  }

  static final _sbColor = Colors.brown[800];
  static final _bgColor = Colors.yellow[100];

  @override
  Widget build(BuildContext context) {
    if (sbItemMap == null) init();

    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      color: _sbColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SideBar(sbItemList, sbSettings, color: _sbColor),
          Expanded(
            child: Container(
              child: _current.createWidget(),
              color: _bgColor,
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }
}
