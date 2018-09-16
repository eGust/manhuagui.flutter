import 'dart:async';
import 'package:html/dom.dart';

import '../api/request.dart' as request;
import './website_meta_data.dart';
import './selectors.dart';

typedef AuthorLinkCallback = void Function(AuthorLink);

class AuthorLink {
  AuthorLink(this.authorId, this.name);
  final int authorId;
  final String name;
}

class AuthorPage extends AuthorLink {
  AuthorPage.fromLink(AuthorLink link, Order order)
    : this.order = order
    , super(link.authorId, link.name)
    ;
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
