import 'package:flutter/material.dart';

import './touchable_icon.dart';

class ComicListTopBar extends StatelessWidget {
  ComicListTopBar({
    this.onPressedScrollTop,
    this.onPressedFilters,
    this.onPressedRefresh,
    this.onPressedBlacklist,
    String filtersTitle,
    this.listTitle,
    this.isScreen = false,
    this.enabledBlacklist = true,
  }): this.filtersTitle = filtersTitle ?? '';

  final VoidCallback onPressedScrollTop, onPressedFilters, onPressedBlacklist, onPressedRefresh;
  final String filtersTitle, listTitle;
  final bool isScreen, enabledBlacklist;

  @override
  Widget build(BuildContext context) =>
    GestureDetector(
      onTap: onPressedScrollTop,
      child: Container(
        height: isScreen ? 56.0 : 36.0,
        padding: isScreen ? const EdgeInsets.only(top: 20.0) : null,
        color: Colors.brown[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  isScreen ? Container(
                    margin: const EdgeInsets.only(left: 8.0, right: 2.0),
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: _IconButton(
                      Icons.arrow_back_ios,
                      onPressed: () { Navigator.pop(context); },
                    ),
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
              ),
            ),
            Text(
              listTitle ?? '',
              style: TextStyle(color: Colors.amber[300], fontSize: 17.0),
            ),
            isScreen ?
            Container(
              width: 150.0,
              padding: const EdgeInsets.only(left: 40.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BlacklistButton(enabledBlacklist, onPressedBlacklist),
                  _IconButton(
                    Icons.search,
                    onPressed: () { Navigator.pop(context); }),
                ],
              ),
            ) : Container(
              width: 150.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BlacklistButton(enabledBlacklist, onPressedBlacklist),
                  _IconButton(Icons.refresh, onPressed: onPressedRefresh),
                  _IconButton(Icons.vertical_align_top, onPressed: onPressedScrollTop),
                ],
              ),
            ),
          ],
        ),
      )
    );

  static const ICON_SIZE = 28.0;
  static const ICON_COLOR = Colors.white;
}

class _BlacklistButton extends StatelessWidget {
  _BlacklistButton(this.enabled, this.onPressed);

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TouchableIcon(
    enabled ? Icons.blur_off : Icons.blur_on,
    size: ComicListTopBar.ICON_SIZE,
    color: enabled ? Colors.red[200] : ComicListTopBar.ICON_COLOR,
    onPressed: onPressed,
  );
}

class _IconButton extends StatelessWidget {
  _IconButton(this.icon, {
    Color color,
    this.onPressed,
  }) : this.color = color ?? ComicListTopBar.ICON_COLOR;

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TouchableIcon(
    icon,
    size: ComicListTopBar.ICON_SIZE,
    color: color,
    onPressed: onPressed,
  );
}
