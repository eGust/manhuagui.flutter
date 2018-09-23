import 'package:flutter/material.dart';

import './touchable_icon.dart';
import './user_status.dart';

class TopBarFrame extends StatelessWidget {
  TopBarFrame({
    this.left = _BLANK_LIST,
    this.right = _BLANK_LIST,
    this.middle = const UserStatusButton(),
    this.onPressed,
  });

  static const _BLANK_LIST = [const Text('')];

  final VoidCallback onPressed;
  final List<Widget> left, right;
  final Widget middle;

  @override
  Widget build(BuildContext context) => Container(
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 36.0,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        color: Colors.brown[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: left,
            )),
            middle,
            Container(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: right,
            )),
          ],
        ),
      ),
    ),
  );
}

class ListTopBar extends StatelessWidget {
  static const MIDDLE_TEXT_STYLE = TextStyle(color: Colors.white, fontSize: 17.0);

  ListTopBar({
    this.onPressedScrollTop,
    this.onPressedFilters,
    this.onPressedRefresh,
    this.onPressedBlacklist,
    String filtersTitle,
    String listTitle,
    this.isScreen = false,
    this.blacklistEnabled = true,
  }): this.filtersTitle = filtersTitle ?? ''
    , middle = listTitle == null ?
        UserStatusButton() :
        Text(listTitle, style: MIDDLE_TEXT_STYLE)
    ;

  final VoidCallback onPressedScrollTop, onPressedFilters, onPressedBlacklist, onPressedRefresh;
  final String filtersTitle;
  final Widget middle;
  final bool isScreen, blacklistEnabled;

  @override
  Widget build(BuildContext context) => TopBarFrame(
    onPressed: onPressedScrollTop,
    middle: middle,
    left: [
      isScreen ? _IconButton(
        Icons.arrow_back_ios,
        onPressed: () { Navigator.pop(context); },
      ) : Container(),
      FlatButton(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: const Icon(Icons.filter_list, color: Colors.white, size: 28.0),
              margin: const EdgeInsets.only(right: 10.0),
            ),
            Text(filtersTitle.isEmpty ? '全部' : filtersTitle,
              style: filtersTitle.isEmpty ?
                TextStyle(color: Colors.grey[100], fontSize: 18.0) :
                TextStyle(color: Colors.amber[300], fontSize: 17.0),
            ),
          ],
        ),
        onPressed: onPressedFilters,
      ),
    ],
    right: isScreen ? [
      BlacklistButton(blacklistEnabled, onPressedBlacklist),
      _IconButton(
        Icons.search,
        onPressed: () {},
      ),
    ] : [
      BlacklistButton(blacklistEnabled, onPressedBlacklist),
      _IconButton(Icons.refresh, onPressed: onPressedRefresh),
      _IconButton(Icons.vertical_align_top, onPressed: onPressedScrollTop),
    ],
  );

  static const ICON_SIZE = 28.0;
  static const ICON_COLOR = Colors.white;
}

class BlacklistButton extends StatelessWidget {
  BlacklistButton(this.enabled, this.onPressed);

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => onPressed == null ?
    Container() :
    TouchableIcon(
      enabled ? Icons.blur_off : Icons.blur_on,
      size: ListTopBar.ICON_SIZE,
      color: enabled ? Colors.red[200] : ListTopBar.ICON_COLOR,
      onPressed: onPressed,
    );
}

class _IconButton extends StatelessWidget {
  _IconButton(this.icon, {
    Color color,
    this.onPressed,
  }) : this.color = color ?? ListTopBar.ICON_COLOR;

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TouchableIcon(
    icon,
    size: ListTopBar.ICON_SIZE,
    color: color,
    onPressed: onPressed,
  );
}
