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
    SELECT
      books.book_id, books.name, books.cover_json, books.max_chapter_id,
      chapters.chapter_id, chapters.title, chapters.read_at, chapters.read_page
    FROM books
    INNER JOIN chapters ON chapter_id = last_chapter_id
    ORDER BY chapters.read_at DESC
    LIMIT 500
    ''');

    setState(() {
      comics = rows.map((row) {
          final cc = ComicCover(row['book_id'], row['name']);
          cc.loadJson(jsonDecode(row['cover_json']));
          return cc;
        }).toList();
    });
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(0.0),
    children: List<Widget>.from(comics.map((comic) => ComicCoverRow(comic, context))),
  );
}
