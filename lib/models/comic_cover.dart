import 'dart:collection';
import 'package:html/dom.dart';

import './author.dart';

enum CoverSize { min, xs, sm, md, lg, xl, max }

class ComicCover {
  ComicCover(this.bookId, this.name);
  ComicCover.fromLinkAttrs(LinkedHashMap<dynamic, String> linkAttrs)
    : this.bookId = int.parse(linkAttrs['href'].split('/')[2])
    , this.name = linkAttrs['title']
    ;

  final int bookId;
  String name, lastChpTitle, score, updatedAt;
  bool finished, restricted = false;

  List<AuthorLink> authors;
  List<String> tags;
  Set<String> tagSet;
  String shortIntro;
  Map<String, int> history = {};

  static const Map<CoverSize, String> _coverSizeMap = {
    CoverSize.min: 's/', // 92 * 122
    CoverSize.xs: 'l/', // 78 * 104
    CoverSize.sm: 'm/', // 114 * 152
    CoverSize.md: 'b/', // 132 * 176
    CoverSize.lg: 'h/', // 180 * 240
    CoverSize.xl: 'g/', // 240 * 360
    CoverSize.max: '', // 360 * 480
  };

  String get path => "/comic/$bookId/";
  String getImageUrl({CoverSize size = CoverSize.lg}) =>
    "https://cf.hamreus.com/cpic/${_coverSizeMap[size]}$bookId.jpg";

  static final reDate = RegExp(r'(\d{4}-\d{2}-\d{2})');

  static ComicCover fromMobileDom(Element element) {
    final bookId = int.parse(element.attributes['href'].split('/')[2]);
    final name = element.querySelector('h3').text.trim();
    final cc = ComicCover(bookId, name);

    // finished
    (() {
      var ef = element.querySelector('.thumb > i');
      if (ef != null) {
        cc.finished = ef.text.trim() == '完结';
        return;
      }

      ef = element.querySelector('em');
      if (ef != null) {
        cc.finished = ef.classes.contains('green');
        return;
      }
    })();

    // last chapter/updatedAt
    (() {
      final dds = element.querySelectorAll('dl > dd');
      if (dds.isNotEmpty) {
        cc.lastChpTitle = dds[2].text;
        cc.updatedAt = dds[3].text;
        return;
      }

      final le = element.querySelector('p > span');
      if (le != null) {
        cc.lastChpTitle = le.text;
        return;
      }
    })();

    return cc;
  }

  static ComicCover fromDesktopDom(Element element) {
    final cover = element.querySelector('a.bcover');
    final cc = ComicCover.fromLinkAttrs(cover.attributes);
    cc.finished = cover.querySelectorAll('.sl').isEmpty;
    cc.lastChpTitle = cover.querySelector('.tt').text
      .replaceAll('更新至', '').replaceAll('[完]', '');

    final update = element.querySelector('.updateon');
    cc.updatedAt = reDate.firstMatch(update.text).group(1);
    cc.score = update.querySelector('em').text;
    return cc;
  }

  static ComicCover fromAuthorDom(Element element) {
    final cc = ComicCover.fromLinkAttrs(element.querySelector('dt > a').attributes);
    final status = element.querySelector('dd.status');
    cc.finished = status.querySelector('span.green') != null;
    cc.lastChpTitle = status.querySelector('a').text.trim();

    cc.updatedAt = status.querySelectorAll('span.red').last.text.trim();
    cc.score = element.nextElementSibling.querySelector('.score-avg strong').text;
    return cc;
  }

  static ComicCover fromDomAuto(Element element) {
    if (element.localName == 'a') return fromMobileDom(element);
    if (element.localName == 'li') return fromDesktopDom(element);
    if (element.className.contains('book-detail')) fromDesktopDom(element);
    return null;
  }

  static Iterable<ComicCover> parseDesktop(Document doc) => doc
    .querySelectorAll('ul#contList > li')
    .map((li) => ComicCover.fromDesktopDom(li));

  static Iterable<ComicCover> parseAuthor(Document doc) => doc
    .querySelectorAll('.book-result ul li .book-detail')
    .map((detail) => ComicCover.fromAuthorDom(detail));

  static Iterable<ComicCover> parseFavorate(Document doc) => doc
    .querySelectorAll('li > a')
    .map((a) => ComicCover.fromDesktopDom(a));

  Map<String, dynamic> toJson() => {
    'as': authors,
    'tg': tags,
    'ts': tagSet.toList(),
    'in': shortIntro,
    'ad': restricted,
  };

  void loadJson(Map<String, dynamic> json) {
    authors = List.from((json['as'] as List).map((a) => AuthorLink.fromJson(a)));
    tags = List.from(json['tg']);
    tagSet = Set.from(json['ts']);
    shortIntro = json['in'];
    restricted = json['ad'];
  }
}
