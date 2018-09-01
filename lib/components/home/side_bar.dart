import 'package:flutter/material.dart';

import './sub_router.dart';
export './sub_router.dart';

class SideBarItem {
  SideBarItem({
    this.icon,
    this.label,
    this.createWidget,
    this.onPressed = _doNothing,
    this.focused = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final WidgetGenerator createWidget;
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
            padding: const EdgeInsets.only(top: 100.0, bottom: 60.0),
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

void _doNothing() {}

class IconButton extends StatelessWidget {
  IconButton(SideBarItem item)
    : this.icon = item.icon
    , this.label = item.label
    , this.focused = item.focused
    , this.onPressed = item.onPressed
    ;

  final IconData icon;
  final String label;
  final bool focused;
  final VoidCallback onPressed;

  static final _focusedColor = Colors.yellow[200];
  static final _normalColor = Colors.white;

  Color get color => focused ? _focusedColor : _normalColor;

  @override
  Widget build(BuildContext context) =>   Container(
    child: FlatButton(
      onPressed: onPressed,
      padding: const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
      child: Column(
        children: label == null
          ? <Widget>[
            Icon(
              icon,
              color: color,
              size: 40.0,
            ),
          ]
          : <Widget>[
            Icon(
              icon,
              color: color,
              size: 40.0,
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.0,
              ),
            ),
          ],
      ),
    ),
    margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
  );
}
