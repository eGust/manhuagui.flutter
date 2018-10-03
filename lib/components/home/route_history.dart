import 'dart:convert';
import 'package:flutter/material.dart';

import './sub_router.dart';
import '../comic_cover_row.dart';
import '../../store.dart';
import '../../models.dart';

class RouteHistory extends StatefulWidget {
  static final router = SubRouter(
    'history',
    Icons.history,
    () => RouteHistory(),
    label: '历史',
  );

  @override
  _RouteHistoryState createState() => _RouteHistoryState();
}

class _RouteHistoryState extends State<RouteHistory> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  List<ComicCover> comics = [];

  void _loadHistory() async {
    final rows = await globals.localDb.rawQuery('''
    SELECT books.book_id, books.name
      , cover_json, last_chapter_id, max_chapter_id
      , last_chapter.title last_chapter_title, last_chapter.read_page
      , max_chapter.title max_chapter_title, max_chapter.read_page
    FROM books
    INNER JOIN chapters last_chapter ON last_chapter.chapter_id = last_chapter_id
    LEFT JOIN chapters max_chapter ON max_chapter.chapter_id = max_chapter_id
    ORDER BY last_chapter.read_at DESC
    LIMIT 500
    ''');

    setState(() {
      comics = rows.map((row) {
          final cc = ComicCover(row['book_id'], row['name']);
          cc.loadJson(jsonDecode(row['cover_json']));
          cc.lastChapterId = row['last_chapter_id'];
          cc.lastChapterPage = row['last_chapter_page'];
          cc.lastReadChapter = row['last_chapter_title'];
          cc.maxChapterId = row['max_chapter_id'];
          cc.maxChapterPage = row['max_chapter_page'];
          cc.maxReadChapter = row['max_chapter_title'];
          return cc;
        }).toList();
    });
  }

  void _updateProgresses() async {
    await globals.updateChapterProgresses(comics);
    if (!mounted) return;
    setState(() { });
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(0.0),
    children: List<Widget>.from(comics.map((comic) =>
      ComicCoverRow(comic, context, onPopComic: _updateProgresses)
    )),
  );
}
