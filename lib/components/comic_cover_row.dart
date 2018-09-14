import 'package:flutter/material.dart';

import '../store.dart';
import '../models.dart';

class ComicCoverRow extends StatelessWidget {
  ComicCoverRow(this._cover, { this.onComicPressed, this.onAuthorPressed });

  final VoidCallback onComicPressed;
  final AuthorLinkCallback onAuthorPressed;

  Widget _wrapTouch(Widget w) => GestureDetector(
    child: w,
    onTap: onComicPressed,
  );

  final ComicCover _cover;
  @override
  Widget build(BuildContext context) => _wrapTouch(Container(
    height: 242.0,
    padding: const EdgeInsets.only(right: 6.0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.orange[300])),
      color: _cover.restricted ? Colors.pink[50] : Colors.transparent,
    ),
    child: Row(children: [
      Container(
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
                fontSize: 20.0,
                color: _cover.restricted ? Colors.pink[600] : Colors.deepPurple[900],
              ),
            ),
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '[${_cover.finished ? '完结' : '连载'}] ${_cover.lastChpTitle}',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: _cover.finished ? Colors.red[800] : Colors.green[800],
                  ),
                ),
                Text(
                  '更新 ${globals.formatDate(_cover.updatedAt)}',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            // Authors
            Row(
              children: _cover.authors == null ? [
                Text(
                  '[无作者数据]',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red[600],
                  ),
                ),
              ] : _cover.authors.map((author) => Container(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: GestureDetector(
                  child: Text(
                    author.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.lightBlue[900],
                    ),
                  ),
                  onTap: () {
                    if (onAuthorPressed == null) return;
                    onAuthorPressed(author);
                  },
                )
              )).toList(),
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
                  '${_cover.restricted ? '*' : ''}${_cover.score}',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            // Introduction - short
            Container(
              height: 100.0,
              padding: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.orange[100])),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _cover.shortIntro ?? '无简介数据',
                  overflow: TextOverflow.clip,
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
