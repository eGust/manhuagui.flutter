import 'dart:async';
import 'package:html/parser.dart' show parse;

import '../api/request.dart';
import '../api/decrypt_chapter_json.dart';
import 'website_meta_data.dart';
import 'comic_cover.dart';
import 'chapter.dart';

class ComicBook extends ComicCover {
  ComicBook(int bookId): super(bookId, null);
  static Map<String, ComicBook> books = {};

  int rank;
  List<int> votes;
  List<String> alias, introduction;
  // List<FilterSelector> filters;

  List<String> chapterGroups;
  Map<String, List<int>> groupedChapterIdListMap;
  Map<int, Chapter> chapterMap;

  ComicBook.fromCover(ComicCover cover): super(cover.bookId, cover.name) {
    lastChpTitle = cover.lastChpTitle;
    score = cover.score;
    authors = cover.authors;
    tags = cover.tags;
    shortIntro = cover.shortIntro;
    updatedAt = cover.updatedAt;
    finished = cover.finished;
  }

  String get url => "$PROTOCOL://$DOMAIN$path";
  String get voteUrl => 'http://www.manhuagui.com/tools/vote.ashx?act=get&bid=$bookId';

  Future<void> _updateMain() async {
    var doc = await fetchDom(url);
    final content = doc.querySelector('.book-cont');
    if (name == null) name = content.querySelector('.book-title > h1').text;

    // lastChpTitle, updatedAt, finished
    final status = content.querySelector('li.status');
    lastChpTitle = status.querySelector('a').text;
    updatedAt = DateTime.parse(status.querySelectorAll('span.red').last.text);
    finished = status.querySelector('.dgreen') != null;

    // rank, tags, authors, alias, introduction
    rank = int.parse(content.querySelector('.rank strong').text);
    tags = content.querySelectorAll('li:not(.status) a[href^="/list/"]')
      .map((link) => link.text).toList();
    authors = content.querySelectorAll('a[href^="/author/"]')
      .map((link) => AuthorLink(int.parse(link.attributes['href'].split('/')[2]), link.text))
      .toList();
    alias = ( content.querySelectorAll('a[href="$path"]')
            + content.querySelectorAll('.book-title > h2') )
            .map((link) => link.text.trim())
            .where((name) => name.length > 0).toList();
    introduction = content.querySelectorAll('#intro-all > *')
      .map((p) => p.text.trim()).toList();

    // chapters
    final adult = doc.querySelector('#__VIEWSTATE');
    isAdult = adult != null;
    if (isAdult) {
      final html = lzDecompressFromBase64(adult.attributes['value']);
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
          final prevId = groupChapterIdList[i - 1];
          final nextId = groupChapterIdList[i];
          chapterMap[prevId].groupNextId = nextId;
          chapterMap[nextId].groupPrevId = prevId;
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

  Future<void> update() =>
    Future.wait([
      _updateMain(),
      _updateScore(),
    ]);
}
