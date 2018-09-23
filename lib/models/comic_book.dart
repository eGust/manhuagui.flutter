import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart' show parse;

import '../api/request.dart';
import '../api/decrypt_chapter_json.dart';
import './website_meta_data.dart';
import './author.dart';
import './comic_cover.dart';
import './chapter.dart';
import '../store.dart';

class ComicBook extends ComicCover {
  ComicBook(int bookId): super(bookId, null);
  static Map<String, ComicBook> books = {};

  int rank;
  List<int> votes = [];
  List<String> alias = [], introduction = [];
  // List<FilterSelector> filters;

  List<String> chapterGroups = [];
  Map<String, List<int>> groupedChapterIdListMap = {};
  Map<int, Chapter> chapterMap = {};

  ComicBook.fromCover(ComicCover cover): super(cover.bookId, cover.name) {
    lastChpTitle = cover.lastChpTitle;
    score = cover.score;
    updatedAt = cover.updatedAt;

    finished = cover.finished;
    restricted = cover.restricted;
    shortIntro = cover.shortIntro;

    authors = List.from(cover.authors ?? []);
    tags = List.from(cover.tags ?? []);
    tagSet = Set.from(cover.tagSet ?? []);
    history = Map.from(cover.history);
  }

  Chapter groupPrevOf(Chapter ch) => chapterMap[ch?.groupPrevId];
  Chapter groupNextOf(Chapter ch) => chapterMap[ch?.groupNextId];

  Chapter prevOf(Chapter ch) => chapterMap[ch?.prevChpId];
  Chapter nextOf(Chapter ch) => chapterMap[ch?.nextChpId];

  String get url => "$PROTOCOL://$DOMAIN$path";
  String get voteUrl => 'http://www.manhuagui.com/tools/vote.ashx?act=get&bid=$bookId';

  Future<void> _updateMain() async {
    var doc = await fetchDom(url);
    final content = doc.querySelector('.book-cont');
    if (name == null) name = content.querySelector('.book-title > h1').text;

    // lastChpTitle, updatedAt, finished
    final status = content.querySelector('li.status');
    lastChpTitle = status.querySelector('a').text;
    updatedAt = status.querySelectorAll('span.red').last.text;
    finished = status.querySelector('.dgreen') != null;

    // rank, tags, authors, alias, introduction
    rank = int.parse(content.querySelector('.rank strong').text);
    tags = tags == null || tags.isEmpty ?
      content.querySelectorAll('li:not(.status) a[href^="/list/"]')
        .map((link) => link.text).toList() : tags;
    authors = content.querySelectorAll('a[href^="/author/"]')
      .map((link) => AuthorLink(int.parse(link.attributes['href'].split('/')[2]), link.text))
      .toList();
    alias = ( content.querySelectorAll('a[href="$path"]')
            + content.querySelectorAll('.book-title > h2') )
            .map((link) => link.text.trim())
            .where((name) => name.length > 0).toList();
    shortIntro = content.querySelector('#intro-cut').text;
    introduction = content.querySelectorAll('#intro-all > *')
      .map((p) => p.text.trim()).toList();

    // chapters
    final restrictEl = doc.querySelector('#__VIEWSTATE');
    restricted = restrictEl != null;
    if (restricted) {
      final html = lzDecompressFromBase64(restrictEl.attributes['value']);
      doc = parse('<div class="chapter">$html</div>');
    }

    chapterMap = {};
    groupedChapterIdListMap = {};
    chapterGroups = doc.querySelector('.chapter')
      .querySelectorAll('.chapter-list')
      .map((el) {
        var h4 = el.previousElementSibling;
        if (h4.localName != 'h4') h4 = h4.previousElementSibling;

        final groupName = h4.text;
        final groupChapterIdList = <int>[];

        el.querySelectorAll('ul').reversed.forEach((ul) {
          groupChapterIdList.addAll(
            ul.querySelectorAll('li > a')
            .map((link) {
              final attrs = link.attributes;
              final chapterId = int.parse(attrs['href'].split('/')[3].replaceAll('.html', ''));
              final chapter = Chapter(chapterId, attrs['title'], bookId);
              chapter.pageCount = int.parse(link.querySelector('i').text.replaceAll('p', ''));

              chapterMap[chapterId] = chapter;
              return chapterId;
            }),
          );
        });

        for (var i = 1; i < groupChapterIdList.length; i += 1) {
          final latterId = groupChapterIdList[i - 1];
          final formerId = groupChapterIdList[i];
          chapterMap[latterId].groupPrevId = formerId;
          chapterMap[formerId].groupNextId = latterId;
        }

        groupedChapterIdListMap[groupName] = groupChapterIdList;
        return groupName;
      }).toList();
  }

  Future<void> _updateScore() async {
    if (score != null) return;
    // votes
    final Map<String, dynamic> voteData = (await getJson(voteUrl))['data'];
    votes = [0,
      voteData['s1'],
      voteData['s2'],
      voteData['s3'],
      voteData['s4'],
      voteData['s5'],
    ];
    votes[0] = votes[1] + votes[2] + votes[3] + votes[4] + votes[5];

    score = (
        (votes[5] * 5 + votes[4] * 4 + votes[3] * 3 + votes[2] * 2 + votes[1] * 1)
          * 2 / votes[0]
      ).toStringAsFixed(1);
  }

  Future<void> updateHistory({ final int lastChapterId, final bool updateCover = false }) async {
    final db = globals.localDb;
    final wc = 'book_id = $bookId';
    final r = await db.rawQuery('SELECT max_read_chapter_id FROM books WHERE $wc');

    if (r.isEmpty) {
      await db.insert('books', {
        'book_id': bookId,
        'cover_json': jsonEncode(this),
        'is_favorate': 0,
        'last_read_chapter_id': lastChapterId,
        'max_read_chapter_id': lastChapterId,
      });
      return;
    }

    final int maxChapterId = r.first['max_read_chapter_id'];
    final Map<String, dynamic> attrs = {
      'last_read_chapter_id': lastChapterId,
    };

    if (updateCover) attrs['cover_json'] = jsonEncode(this);
    if (lastChapterId > maxChapterId) attrs['max_read_chapter_id'] = lastChapterId;

    await db.update('books', attrs, where: wc);
  }

  Future<void> update() =>
    Future.wait([
      _updateMain(),
      _updateScore(),
    ]);
}
