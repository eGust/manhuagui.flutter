import 'package:flutter/material.dart';

import '../store.dart';
import '../models.dart';
import '../utils.dart';
import '../routes.dart';
import '../components/touchable_icon.dart';

class ComicScreen extends StatefulWidget {
  ComicScreen(this.cover);

  final ComicCover cover;

  @override
  _ComicScreenState createState() => _ComicScreenState(cover);
}

class _ComicScreenState extends State<ComicScreen> {
  _ComicScreenState(ComicCover cover): this.comic = ComicBook.fromCover(cover);

  ComicBook comic;

  void goBack() {
    Navigator.pop(context);
  }

  void _refresh() async {
    final book = ComicBook.fromCover(comic);
    await book.update();
    if (!mounted) return;

    setState(() {
      comic = book;
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 20.0),
    color: comic.finished ? Colors.pink[900] : Colors.lightBlue[900],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          height: 36.0,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TouchableIcon(
                Icons.arrow_back,
                size: 28.0,
                color: Colors.white,
                onPressed: goBack,
              ),
              Text(
                comic.name,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              TouchableIcon(
                Icons.search,
                size: 28.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
        Container(
          height: 360.0,
          color: comic.restricted ? Colors.pink[50] : Colors.yellow[50],
          child: Row(
            children: [
              Container(
                width: 240.0,
                child: Image.network(
                  comic.getImageUrl(size: CoverSize.xl),
                  headers: { 'Referer': 'https://m.manhuagui.com' },
                ),
              ),
              Expanded(child: Container(
                padding: const EdgeInsets.fromLTRB(6.0, 3.0, 15.0, 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '[${comic.finished ? '完结' : '连载'}] ${comic.lastChpTitle}',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: comic.finished ? Colors.red[800] : Colors.green[800],
                          ),
                        ),
                        Text(
                          '更新 ${globals.formatDate(comic.updatedAt)}',
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: comic.authors == null ? [
                        Text(
                          '[无作者数据]',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.red[600],
                          ),
                        ),
                      ] : comic.authors.map((author) => Container(
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
                            Routes.navigateAuthor(context, author);
                          },
                        )
                      )).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          (comic.tags ?? ['[无类型数据]']).join(' '),
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          '${comic.restricted ? '[R] ' : ''}${comic.score}',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          '${comic.rank}',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 220.0,
                      child: SingleChildScrollView(
                        child: Text(
                          (comic.introduction ?? []).join('\n'),
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
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Wrap(
              children: comic.chapterMap.values.map((ch) => Container(
                margin: const EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                child: ActionChip(
                  label: Text(ch.title),
                  onPressed: () {},
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}
