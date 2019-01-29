import 'package:flutter/material.dart';

import '../../models.dart';
import '../../routes.dart';

class CoverHeader extends StatelessWidget {
  CoverHeader(this.comic);

  final ComicBook comic;

  @override
  Widget build(BuildContext context) => Container(
        height: 180.0,
        color: comic.restricted ? Colors.pink[50] : Colors.yellow[50],
        child: Row(
          children: [
            Container(
              width: 120.0,
              child: Image.network(
                comic.getImageUrl(size: CoverSize.xl),
                headers: {'Referer': 'https://m.manhuagui.com'},
              ),
            ),
            Expanded(
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '[${comic.finished ? '完结' : '连载'}] ${comic.lastUpdatedChapter}',
                    style: TextStyle(
                      fontSize: 15.0,
                      color:
                          comic.finished ? Colors.red[800] : Colors.green[800],
                    ),
                  ),
                  Text(
                    '更新 ${comic.updatedAt}',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Row(
                    children: comic.authors == null
                        ? [
                            Text(
                              '[无作者数据]',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.red[600],
                              ),
                            ),
                          ]
                        : comic.authors
                            .map((author) => Container(
                                padding: const EdgeInsets.only(
                                  left: 5.0,
                                  right: 5.0,
                                ),
                                child: GestureDetector(
                                  child: Text(
                                    author.name,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.lightBlue[900],
                                    ),
                                  ),
                                  onTap: () {
                                    RouteHelper.pushAuthor(context, author);
                                  },
                                )))
                            .toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            (comic.tags ?? ['[无类型数据]']).join(' '),
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '${comic.restricted ? '[R] ' : ''}${comic.score ?? '??'}',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        ' ${comic.rank ?? '...'}',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50.0,
                    child: SingleChildScrollView(
                      child: Text(
                        comic.introduction.join('\n'),
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      );
}
