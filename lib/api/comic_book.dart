import 'dart:async';
import 'package:html/parser.dart' show parse;

import 'meta_data.dart';
import 'request.dart';
import 'comic_cover.dart';
import 'chapter.dart';
import 'decrypt_chapter_json.dart';

class ComicBook extends ComicCover {
  ComicBook(String bookId): super(bookId, null);
  static Map<String, ComicBook> books = {};

  int rank;
  List<int> votes;
  List<AuthorLink> authors;
  List<String> tags, alias, introduction;
  // List<FilterSelector> filters;

  List<String> chapterGroups;
  Map<String, List<String>> groupedChapterIdListMap;
  Map<String, Chapter> chapterMap;

  ComicBook.fromCover(ComicCover cover): super(cover.bookId, cover.name) {
    lastChpTitle = cover.lastChpTitle;
    score = cover.score;
    updatedAt = cover.updatedAt;
    finished = cover.finished;
  }

  String get url => "$PROTOCOL://$DOMAIN$path";
  String get voteUrl => 'http://www.manhuagui.com/tools/vote.ashx?act=get&bid=$bookId';

  Future refresh() async {
    var doc = await fetchDom(url);
    final content = doc.querySelector('.book-cont');

    if (name == null) name = content.querySelector('.book-title > h1').text;

    // ComicCover
    if (score == null) {
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

      // lastChpTitle, score, updatedAt, finished
      final status = content.querySelector('li.status');
      lastChpTitle = status.querySelector('a').text;
      score = (
          (votes[5] * 5 + votes[4] * 4 + votes[3] * 3 + votes[2] * 2 + votes[1] * 1)
            * 2 / votes[0]
        ).toStringAsFixed(1);
      updatedAt = DateTime.parse(status.querySelectorAll('span.red').last.text);
      finished = status.querySelector('.dgreen') != null;
    }

    // rank, tags, authors, alias, introduction
    rank = int.parse(content.querySelector('.rank strong').text);
    tags = content.querySelectorAll('li:not(.status) a[href^="/list/"]')
      .map((link) => link.text).toList();
    authors = content.querySelectorAll('a[href^="/author/"]')
      .map((link) => AuthorLink(link.attributes['href'].split('/')[2], link.text))
      .toList();
    alias = ( content.querySelectorAll('a[href="$path"]')
            + content.querySelectorAll('.book-title > h2') )
            .map((link) => link.text.trim())
            .where((name) => name.length > 0).toList();
    introduction = content.querySelectorAll('#intro-all > *')
      .map((p) => p.text.trim()).toList();

    // chapters
    final adult = doc.querySelector('#__VIEWSTATE');
    if (adult != null) {
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
        final groupChapterIdList = <String>[];

        el.querySelectorAll('ul').reversed.forEach((ul) {
          groupChapterIdList.addAll(
            ul.querySelectorAll('li > a')
            .map((link) {
              final attrs = link.attributes;
              final chapterId = attrs['href'].split('/')[3].replaceAll('.html', '');
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
}
