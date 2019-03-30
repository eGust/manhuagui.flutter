import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../api/request.dart';
import '../api/decrypt_chapter_json.dart';
import '../store.dart';
import 'website_meta_data.dart';
import 'comic_book.dart';
import 'comic_page.dart';

/*
{
  "bid": 20515,
  "bname": "哥布林杀手",
  "bpic": "20515.jpg",
  "cid": 239686,
  "cname": "第01回",
  "files": [
    "001.jpg.webp", "002.jpg.webp", "003.jpg.webp", "004.jpg.webp", "005.jpg.webp", "006.jpg.webp", "007.jpg.webp", "008.jpg.webp", "009.jpg.webp", "010.jpg.webp", "011.jpg.webp", "012.jpg.webp", "013.jpg.webp", "014.jpg.webp", "015.jpg.webp", "016.jpg.webp", "017.jpg.webp", "018.jpg.webp", "019.jpg.webp", "020.jpg.webp", "021.jpg.webp", "022.jpg.webp", "023.jpg.webp", "024.jpg.webp", "025.jpg.webp", "026.jpg.webp", "027.jpg.webp", "028.jpg.webp", "029.jpg.webp", "030.jpg.webp", "031.jpg.webp", "032.jpg.webp", "033.jpg.webp", "034.jpg.webp", "035.jpg.webp", "036.jpg.webp", "037.jpg.webp", "038.jpg.webp", "039.jpg.webp", "040.jpg.webp", "041.jpg.webp", "042.jpg.webp", "043.jpg.webp", "044.jpg.webp", "045.jpg.webp", "046.jpg.webp", "047.jpg.webp", "048.jpg.webp", "049.jpg.webp", "050.jpg.webp", "051.jpg.webp"
  ],
  "finished": false,
  "len": 51,
  "path": "/ps3/g/gblss_hlhj/第01回/",
  "status": 1,
  "block_cc": "",
  "nextId": 246317,
  "prevId": 0,
  "sl": {
    "md5": "6yMd3sF5HSEdzHQ1fxcBBg"
  }
}
*/

class Chapter {
  Chapter({
    @required this.chapterId,
    @required this.title,
    @required this.book,
  });

  final ComicBook book;
  final int chapterId;
  final String title;
  int pageCount, readAt, maxPage;
  int groupPrevId, groupNextId;

  int get bookId => book.bookId;
  String get key => '$bookId/$chapterId';

  String prevChpId, nextChpId, basePath, signature;
  List<String> pages;
  List<ComicPage> _pages;

  Chapter get prevByGroup => book.groupPrevOf(this);
  Chapter get nextByGroup => book.groupNextOf(this);

  FutureOr<ComicPage> page(int pageIndex) {
    if (!(_ready is bool)) {
      return _loadPage(pageIndex);
    }

    final index = pageIndex < 0 ? pageCount + pageIndex : pageIndex;
    final cached = _pages[index];
    if (cached != null) return cached;

    final pg = ComicPage(chapter: this, pageIndex: index);
    _pages[index] = pg;
    return pg;
  }

  Future<ComicPage> _loadPage(pageIndex) async {
    await load();
    return page(pageIndex);
  }

  FutureOr<ComicPage> prevPageOf(int pageIndex) {
    return pageIndex == 0 ? prevByGroup?.page(-1) : page(pageIndex - 1);
  }

  FutureOr<ComicPage> nextPageOf(int pageIndex) {
    final index = pageIndex + 1;
    return index == pageCount ? nextByGroup?.page(0) : page(index);
  }

  String get path => '/comic/$bookId/$chapterId.html';
  bool get neverRead => readAt == null;

  String getPageUrl(int index) =>
      'https://i.hamreus.com$basePath${pages[index]}$signature';

  FutureOr<bool> _ready;

  Future<bool> _refresh() async {
    final doc = await fetchDom('$PROTOCOL://$DOMAIN$path',
        headers: globals.user.cookieHeaders);
    final script = doc
        .querySelectorAll('script:not([src])')
        .map((s) => s.text)
        .firstWhere((js) => _reExtractParams.hasMatch(js));
    final m = _reExtractParams.firstMatch(script);
    final json = decryptChapterData(m[1], int.parse(m[2]), m[3]);
    final chapter = jsonDecode(json);
    pages = List.from(chapter['files']);
    pageCount = pages.length;
    _pages = List(pageCount);
    basePath = Uri.encodeFull(chapter['path']);
    signature = '?cid=$chapterId&md5=${chapter['sl']['md5']}';
    prevChpId = _safeId(chapter['prevId']);
    nextChpId = _safeId(chapter['nextId']);
    _ready = true;
    return true;
  }

  FutureOr<bool> load() {
    _ready ??= _refresh();
    return _ready;
  }

  Future<void> updateHistory(final int pageIndex) async {
    final db = globals.localDb;
    final wc = 'chapter_id = $chapterId';
    final r = await db.rawQuery('SELECT chapter_id FROM chapters WHERE $wc');
    readAt = DateTime.now().millisecondsSinceEpoch;
    maxPage = (maxPage ?? -1) < pageIndex ? pageIndex : maxPage;

    if (r.isEmpty) {
      return db.insert('chapters', {
        'chapter_id': chapterId,
        'title': title,
        'book_id': bookId,
        'read_at': readAt,
        'read_page': maxPage,
      });
    }

    return db.update(
      'chapters',
      {
        'read_at': readAt,
        'read_page': maxPage,
      },
      where: wc,
    );
  }
}

final _reExtractParams = RegExp(
  r"\);return\s+\w+;}\(" +
      r"'[\w\.]+\(({[^']+?})\)\.\w+\(\);'" + // 'c.r( 111 ).M();'
      r",(\d+),\d+,'([^']+)'" + // , 222 ,67, ' 333 '
      r"\['\\x73\\x70\\x6c\\x69\\x63']",
);

String _safeId(int n) => n > 0 ? n.toString() : null;
