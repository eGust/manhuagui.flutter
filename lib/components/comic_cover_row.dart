import 'package:flutter/material.dart';

import '../models.dart';
import '../routes.dart';

class ComicCoverRow extends StatelessWidget {
  ComicCoverRow(this._cover, this._context, {this.onPopComic});

  final VoidCallback onPopComic;

  void _pressedComic() async {
    await RouteHelper.pushComic(_context, _cover);
    if (onPopComic == null) return;
    onPopComic();
  }

  void _pressedAuthor(final AuthorLink author) {
    RouteHelper.pushAuthor(_context, author);
  }

  Widget _wrapTouch(Widget w) => GestureDetector(
        child: w,
        onTap: _pressedComic,
      );

  final ComicCover _cover;
  final BuildContext _context;

  @override
  Widget build(BuildContext context) => _wrapTouch(Container(
        height: 241.0,
        padding: const EdgeInsets.only(right: 6.0),
        decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: Colors.amber)),
          color: _cover.restricted ? Colors.pink[50] : Colors.yellow[100],
        ),
        child: Row(children: [
          SizedBox(
            width: 180.0,
            height: 240.0,
            child: Image.network(
              _cover.getImageUrl(),
              headers: {'Referer': 'https://m.manhuagui.com'},
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.fromLTRB(6.0, 5.0, 6.0, 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                    // Title
                    Text(
                      _cover.name,
                      style: TextStyle(
                        fontSize: _cover.name.length < 27 ? 19.0 : 17.0,
                        color: _cover.restricted
                            ? Colors.pink[600]
                            : Colors.deepPurple[900],
                      ),
                    ),
                    // Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '[${_cover.progress}] ${_cover.lastUpdatedChapterTitle}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: _cover.finished
                                ? Colors.red[800]
                                : Colors.green[800],
                          ),
                        ),
                        Text(
                          _cover.updatedAt == null
                              ? ''
                              : '更新于 ${_cover.updatedAt}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                    // Authors
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: _cover.authors == null
                              ? [
                                  Text(
                                    '[无作者数据]',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ]
                              : _cover.authors
                                  .map((author) => Container(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
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
                                      )))
                                  .toList(),
                        ),
                        _cover.isFavorite
                            ? const Icon(Icons.favorite,
                                color: Colors.red, size: 24.0)
                            : const Icon(Icons.favorite_border,
                                color: Colors.orange, size: 24.0),
                      ],
                    ),
                    // Tags
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          (_cover.tags ?? ['[无类型数据]']).join(' '),
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        Text(
                          '${_cover.restricted ? '*' : ''}${_cover.score ?? ''}',
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ],
                    ),
                  ] +
                  (_cover.maxReadChapter == null &&
                          _cover.lastReadChapter == null
                      ? <Widget>[]
                      : <Widget>[
                          // Read Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  '[阅读进度] ${_cover.maxReadChapterTitle} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  '[上次阅读] ${_cover.lastReadChapterTitle}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ]) +
                  <Widget>[
                    // Introduction - short
                    Container(
                      height: 83.0,
                      padding: const EdgeInsets.only(top: 5.0),
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: Colors.orange[100])),
                      ),
                      child: ClipRect(
                        child: Text(
                          _cover.shortIntro ?? '无简介数据',
                          style: TextStyle(
                            fontSize: 14.0,
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
