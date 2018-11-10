import 'dart:async';
import 'package:html/dom.dart';

import '../api/request.dart' as request;
import './website_meta_data.dart';
import './selectors.dart';
import './comic_cover.dart';

typedef AuthorLinkCallback = void Function(AuthorLink);

class AuthorLink {
  AuthorLink(this.authorId, this.name);
  final int authorId;
  final String name;

  Map<String, dynamic> toJson() => {
        'author_id': authorId,
        'name': name,
      };

  AuthorLink.fromJson(Map<String, dynamic> json)
      : authorId = json['author_id'],
        name = json['name'];
}

class AuthorCover extends AuthorLink {
  AuthorCover({final int authorId, final String name}) : super(authorId, name);
  static AuthorCover fromDom(Element li) {
    final a = li.querySelector('a');
    final author = AuthorCover(
      authorId: int.parse(a.attributes['href'].split('/')[2]),
      name: a.text,
    );

    final fonts = li.querySelectorAll('font');
    author.region = fonts[0].text;
    author.comicCount = int.parse(fonts[1].text);

    final update = li.querySelector('.updateon');
    author.score = update.querySelector('em').text;
    author.updatedAt = ComicCover.reDate.firstMatch(update.text).group(1);
    return author;
  }

  String region, score, updatedAt;
  int comicCount;

  static Iterable<AuthorCover> parseDesktop(Document doc) => doc
      .querySelectorAll('ul#contList > li')
      .map((li) => AuthorCover.fromDom(li));
}

class AuthorPage extends AuthorLink {
  AuthorPage.fromLink(AuthorLink link, Order order)
      : this.order = order,
        super(link.authorId, link.name);
  Order order;
  int page = 1, pageCount;

  String get path => "/author/$authorId/${order.pathWith(page)}";
  String get url => "$PROTOCOL://$DOMAIN$path";

  Future<Document> fetchDom() async {
    final doc = await request.fetchDom(url);
    pageCount ??= FilterSelector.parsePageCount(doc);
    return doc;
  }
}
