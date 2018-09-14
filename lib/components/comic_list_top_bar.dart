import 'package:flutter/material.dart';

class ComicListTopBar extends StatelessWidget {
  ComicListTopBar({
    this.onPressedScrollTop,
    this.onPressedFilters,
    this.onPressedRefresh,
    this.onPressedBlacklist,
    String filtersTitle,
    this.listTitle,
    this.enabledBlacklist = true,
  }): this.filtersTitle = filtersTitle ?? '';

  final VoidCallback onPressedScrollTop, onPressedFilters, onPressedBlacklist, onPressedRefresh;
  final String filtersTitle, listTitle;
  final bool enabledBlacklist;

  @override
  Widget build(BuildContext context) =>
    GestureDetector(
      onTap: onPressedScrollTop,
      child: Container(
        height: 36.0,
        color: Colors.brown[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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
            Text(
              listTitle ?? '',
              style: TextStyle(color: Colors.amber[300], fontSize: 17.0),
            ),
            Container(
              width: 150.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    child: enabledBlacklist ?
                      Icon(Icons.blur_off, color: Colors.red[200], size: 28.0) :
                      const Icon(Icons.blur_on, color: Colors.white, size: 28.0) ,
                    onTap: onPressedBlacklist,
                  ),
                  GestureDetector(
                    child: const Icon(Icons.refresh, color: Colors.white, size: 28.0) ,
                    onTap: onPressedRefresh,
                  ),
                  GestureDetector(
                    child: const Icon(Icons.vertical_align_top, color: Colors.white, size: 28.0) ,
                    onTap: onPressedScrollTop,
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
}
