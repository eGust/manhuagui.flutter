import 'package:flutter/material.dart';

import './sub_router.dart';
export './sub_router.dart';

class SideBarItem {
  SideBarItem(this.router, {
    this.onPressed,
    this.focused = false,
  });
  final SubRouter router;
  final VoidCallback onPressed;
  bool focused;
}

class SideBar extends StatelessWidget {
  SideBar(this.mainButtons, this.settings, { Color color }):
    this.color = color ?? Colors.brown[800];

  static const _SIDE_BAR_WIDTH = 80.0;

  final List<SideBarItem> mainButtons;
  final SideBarItem settings;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
    child: Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: mainButtons.map((item) => IconButton(item)).toList(),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            padding: const EdgeInsets.only(top: 50.0, bottom: 60.0),
          ),
          IconButton(settings),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      width: _SIDE_BAR_WIDTH,
      color: Colors.brown[800],
      alignment: Alignment.center,
    ),
  );
}

class IconButton extends StatelessWidget {
  IconButton(SideBarItem item)
    : this.onPressed = item.onPressed
    , this.router = item.router
    , this.focused = item.focused
    ;

  final VoidCallback onPressed;
  final SubRouter router;
  final bool focused;

  static final _focusedColor = Colors.yellow[200];
  static final _normalColor = Colors.white;

  List<Widget> _createChildren() {
    final color = focused ? _focusedColor : _normalColor;
    final icon = Icon(
        router.icon,
        color: color,
        size: 40.0,
      );
    final text = router.label == null ? null : Text(
        router.label,
        style: TextStyle(
          color: color,
          fontSize: 14.0,
        ),
      );

    return router.label == null ? [icon] : [icon, text];
  }

  @override
  Widget build(BuildContext context) => Container(
    child: FlatButton(
      onPressed: onPressed,
      padding: const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
      child: Column(children: _createChildren()),
    ),
    margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
  );
}
