import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../components/comic/comic_banner.dart';
import '../components/comic/cover_header.dart';
import '../components/comic/chapter_tabs.dart';
import '../components/comic/action_section.dart';

class ComicScreen extends StatefulWidget {
  ComicScreen(this.cover);

  final ComicCover cover;

  @override
  _ComicScreenState createState() => _ComicScreenState(cover);
}

class _ComicScreenState extends State<ComicScreen> {
  _ComicScreenState(ComicCover cover): this.comic = ComicBook.fromCover(cover);

  ComicBook comic;

  void _refresh() async {
    final book = ComicBook.fromCover(comic);
    await book.update();
    book.updateFavorite();
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
    padding: EdgeInsets.only(top: globals.statusBarHeight),
    color: comic.finished ? Colors.pink[900] : Colors.lightBlue[900],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        ComicBanner(comic.name),
        CoverHeader(comic),
        ActionSection(comic),
        ChapterTabs(comic),
      ],
    ),
  );
}
