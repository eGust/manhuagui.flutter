import 'dart:async';
import 'dart:convert';

import '../api/request.dart';
import '../api/decrypt_chapter_json.dart';
import './website_meta_data.dart';
import '../store.dart';

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
  Chapter(this.chapterId, this.title, this.bookId);

  final int chapterId, bookId;
  final String title;
  int pageCount, readAt;
  int groupPrevId, groupNextId;

  String prevChpId, nextChpId, basePath, signature;
  List<String> pages;

  String get path => '/comic/$bookId/$chapterId.html';
  bool get neverRead => readAt == null;

  String getPageUrl(int index) => 'http://i.hamreus.com$basePath${pages[index]}$signature';

  bool _refreshing = false, _ready = false;

  Future<void> _refresh() async {
    _refreshing = true;
    final doc = await fetchDom('$PROTOCOL://$DOMAIN$path', headers: globals.user.cookieHeaders);
    final m = _reExtractParams.firstMatch(doc.querySelector('script:not([src])').text);
    final json = decryptChapterData(m[1], int.parse(m[2]), m[3]);
    final chapter = jsonDecode(json);
    pages = List<String>.from(chapter['files']);
    pageCount = pages.length;
    basePath = Uri.encodeFull(chapter['path']);
    signature = '?cid=$chapterId&md5=${chapter['sl']['md5']}';
    prevChpId = _safeId(chapter['prevId']);
    nextChpId = _safeId(chapter['nextId']);
    _refreshing = false;
    _ready = true;
  }

  Future<void> load() async {
    if (_ready) return;
    if (!_refreshing) return await _refresh();

    do {
      await Future.delayed(const Duration(milliseconds: 10), () {});
    } while (_refreshing);
  }

  Future<void> updateHistory(final int pageIndex) async {
    final db = globals.localDb;
    final wc = 'chapter_id = $chapterId';
    final r = await db.rawQuery('SELECT chapter_id FROM chapters WHERE $wc');
    readAt = DateTime.now().millisecondsSinceEpoch;

    if (r.isEmpty) {
      return db.insert('chapters', {
        'chapter_id': chapterId,
        'title': title,
        'book_id': bookId,
        'read_at': readAt,
        'read_page': pageIndex,
      });
    }

    return db.update('chapters',
      {
        'read_at': readAt,
        'read_page': pageIndex,
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
