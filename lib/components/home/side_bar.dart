import 'package:flutter/material.dart';

import 'sub_router.dart';
import '../../routes.dart';

export './sub_router.dart';
export '../../api.dart';

class SideBarItem {
  SideBarItem(
    this.router, {
    this.onPressed,
    this.focused = false,
  });
  final SubRouter router;
  final VoidCallback onPressed;
  bool focused;
}

class SideBar extends StatelessWidget {
  SideBar(this._mainButtons, this._settings, {Color color})
      : this.color = color ?? Colors.brown[900];

  static const _SIDE_BAR_WIDTH = 72.0;

  final List<SideBarItem> _mainButtons;
  final SideBarItem _settings;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: _SIDE_BAR_WIDTH,
        color: color,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconLabelButton(
              Icons.search,
              onPressed: () {
                RouteHelper.pushSearch(context);
              },
            ),
            Container(
              child: Column(
                children: _mainButtons
                    .map((item) => IconLabelButton.forSideBar(item))
                    .toList(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
            IconLabelButton.forSideBar(_settings),
          ],
        ),
      );
}

class IconLabelButton extends StatelessWidget {
  IconLabelButton(this.icon,
      {this.focused = false, this.onPressed, this.label});

  IconLabelButton.forSideBar(SideBarItem item)
      : this.onPressed = item.onPressed,
        this.icon = item.router.icon,
        this.label = item.router.label,
        this.focused = item.focused;

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool focused;

  static final _focusedColor = Colors.yellow[200];
  static final _normalColor = Colors.white;

  List<Widget> _createChildren() {
    final color = focused ? _focusedColor : _normalColor;
    final iconItem = Icon(
      icon,
      color: color,
      size: 45.0,
    );
    final text = label == null
        ? null
        : Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14.0,
            ),
          );

    return label == null ? [iconItem] : [iconItem, text];
  }

  @override
  Widget build(BuildContext context) => Container(
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.fromLTRB(5.0, 12.0, 5.0, 12.0)),
          ),
          child: Column(children: _createChildren()),
        ),
        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      );
}
