import 'package:flutter/material.dart';

import '../models.dart';
import '../routes.dart';

class ComicCoverRow extends StatelessWidget {
  ComicCoverRow(this._cover, this._context);

  void _pressedComic() {
    RouteHelper.navigateComic(_context, _cover);
  }

  void _pressedAuthor(final AuthorLink author) {
    RouteHelper.navigateAuthor(_context, author);
  }

  Widget _wrapTouch(Widget w) => GestureDetector(
    child: w,
    onTap: _pressedComic,
  );

  final ComicCover _cover;
  final BuildContext _context;

  @override
  Widget build(BuildContext context) => _wrapTouch(Container(
    height: 242.0,
    padding: const EdgeInsets.only(right: 6.0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.orange[300])),
      color: _cover.restricted ? Colors.pink[50] : Colors.yellow[100],
    ),
    child: Row(children: [
      SizedBox(
        width: 180.0,
        height: 240.0,
        child: Image.network(
          _cover.getImageUrl(),
          headers: { 'Referer': 'https://m.manhuagui.com' },
        ),
      ),
      Expanded(child: Container(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            Text(
              _cover.name,
              style: TextStyle(
                fontSize: 19.0,
                color: _cover.restricted ? Colors.pink[600] : Colors.deepPurple[900],
              ),
            ),
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '[${_cover.finished ? '完结' : '连载'}] ${_cover.lastChpTitle ?? ''}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: _cover.finished ? Colors.red[800] : Colors.green[800],
                  ),
                ),
                Text(
                  _cover.updatedAt == null ? '' : '更新于 ${_cover.updatedAt}',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            // Authors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: _cover.authors == null ? [
                    Text(
                      '[无作者数据]',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.red[600],
                      ),
                    ),
                  ] : _cover.authors.map((author) => Container(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: GestureDetector(
                      child: Text(
                        author.name,
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.lightBlue[900],
                        ),
                      ),
                      onTap: () {
                        _pressedAuthor(author);
                      },
                    )
                  )).toList(),
                ),
                _cover.isFavorite ?
                  const Icon(Icons.favorite, color: Colors.red, size: 30.0) :
                  const Icon(Icons.favorite_border, color: Colors.orange, size: 30.0),
              ],
            ),
            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  (_cover.tags ?? ['[无类型数据]']).join(' '),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  '${_cover.restricted ? '*' : ''}${_cover.score ?? ''}',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            // Introduction - short
            Container(
              height: 96.0,
              padding: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.orange[100])),
              ),
              child: ClipRect(
                child: Text(
                  _cover.shortIntro ?? '无简介数据',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    ]),
  ));
}
