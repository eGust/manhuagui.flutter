import 'package:flutter/material.dart';

import '../components/home/side_bar.dart';
import '../components/home/route_home.dart';
import '../components/home/route_comic_newest.dart';
import '../components/home/route_comic_rank.dart';
import '../components/home/route_comic_update.dart';
import '../components/home/route_author.dart';
import '../components/home/route_favorite.dart';
import '../components/home/route_history.dart';
import '../components/home/route_configuration.dart';

import '../store.dart';

class HomeScreen extends StatefulWidget{
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  SideBarItem _sbSettings;

  SideBarItem convertSideBarItem(SubRouter router) =>
    SideBarItem(
      router,
      onPressed: () => setState(() {
        this.path = router.path;
      }),
    );

  static final _sbColor = Colors.brown[900];
  static final _bgColor = Colors.yellow[100];

  @override
  void initState() {
    super.initState();

    _sbSettings = convertSideBarItem(RouteConfiguration.router);
    sbItemMap = {
      'settings': _sbSettings,
    };

    final sbRouterItems = [
      RouteHome.router,
      RouteComicUpdate.router,
      RouteComicNewest.router,
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

  Map<String, Widget> _routeCache = {};

  Widget get currentWidget {
    var w = _routeCache[path];
    if (w == null) {
      w = _current.router.createWidget();
      _routeCache[path] = w;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    if (globals.screenSize == null) {
      globals.screenSize = MediaQuery.of(context).size;
      final w = globals.screenSize.width;
      globals.prevThreshold = w * 2 / 7;
      globals.nextThreshold = w * 5 / 7;
    }
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      color: _sbColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SideBar(sbItemList, _sbSettings, color: _sbColor),
          Expanded(
            flex: 1,
            child: Container(
              child: currentWidget,
              color: _bgColor,
            ),
          ),
        ],
      ),
    );
  }
}
