import 'dart:collection';
import 'package:html/dom.dart';

class AuthorLink {
  AuthorLink(this.authorId, this.name);
  final int authorId;
  final String name;
}

enum CoverSize { min, xs, sm, md, lg, xl, max }

class ComicCover {
  ComicCover(this.bookId, this.name);
  ComicCover.fromLinkAttrs(LinkedHashMap<dynamic, String> linkAttrs)
    : this.bookId = int.parse(linkAttrs['href'].split('/')[2])
    , this.name = linkAttrs['title']
    ;

  final int bookId;
  String name, lastChpTitle, score;
  DateTime updatedAt;
  bool finished;

  List<AuthorLink> authors;
  List<String> tags, introduction;
  String shortIntro;

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

  static final RegExp _reDate = RegExp(r'(\d{4}-\d{2}-\d{2})');

  static ComicCover fromDom(Element element) {
    if (element.localName == 'a') {
      // mobile version
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
          cc.updatedAt = DateTime.parse(dds[3].text);
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

    if (element.localName == 'li') {
      final cover = element.querySelector('a.bcover');
      final cc = ComicCover.fromLinkAttrs(cover.attributes);
      cc.finished = cover.querySelectorAll('.sl').isEmpty;
      cc.lastChpTitle = cover.querySelector('.tt').text;

      final update = element.querySelector('.updateon');
      cc.updatedAt = DateTime.parse(_reDate.firstMatch(update.text).group(1));
      cc.score = update.querySelector('em').text;
      return cc;
    }

    if (element.localName == 'tr') {
      final tdTitle = element.querySelector('td.rank-title');
      final cc = ComicCover.fromLinkAttrs(tdTitle.querySelector('a').attributes);
      cc.finished = tdTitle.querySelector('span.cGreen') != null;
      cc.lastChpTitle = element.querySelector('.rank-update').text.trim();

      cc.updatedAt = DateTime.parse(element.querySelector('.rank-time').text.trim());
      cc.score = element.querySelector('.rank-score').text.trim();
      return cc;
    }

    // if (element.className.contains('book-detail')) {
    final cc = ComicCover.fromLinkAttrs(element.querySelector('dt > a').attributes);
    final status = element.querySelector('dd.status');
    cc.finished = status.querySelector('span.green') != null;
    cc.lastChpTitle = status.querySelector('a').text.trim();

    cc.updatedAt = DateTime.parse(status.querySelectorAll('span.read').last.text.trim());
    cc.score = element.nextElementSibling.querySelector('.score-avg strong').text;
    return cc;
  }

  static List<ComicCover> parseList(Document doc) => doc
    .querySelectorAll('ul#contList > li')
    .map((li) => ComicCover.fromDom(li)).toList();

  static List<ComicCover> parseRank(Document doc) => doc
    .querySelectorAll('table.rank-detail tr:not([class])')
    .map((tr) => ComicCover.fromDom(tr)).toList();

  static List<ComicCover> parseAuthor(Document doc) => doc
    .querySelectorAll('.book-result ul > li .book-detail')
    .map((detail) => ComicCover.fromDom(detail)).toList();

  static List<ComicCover> parseFavorate(Document doc) => doc
    .querySelectorAll('li > a')
    .map((a) => ComicCover.fromDom(a)).toList();

  static List<ComicCover> autoParseDom(Document doc) => (
      doc.querySelectorAll('ul#contList > li') +
      doc.querySelectorAll('table.rank-detail tr:not([class])') +
      doc.querySelectorAll('.book-result ul > li .book-detail')
    ).map((el) => ComicCover.fromDom(el)).toList();
}
