import 'dart:async';
import 'package:html/dom.dart';

import '../api/request.dart' as request;
import 'website_meta_data.dart';

enum SelectorType { Comic, Author }

class SelectorMeta {
  SelectorMeta({ this.filterGroups, this.orders })
    : linkGroupMap = _buildLinkGroupMap(filterGroups)
    , linkTitleMap = _buildLinkTitleMap(filterGroups)
    , orderMap = Map.fromEntries(orders.map((order) => MapEntry(order.linkBase, order)))
    ;

  static Map<String, String> _buildLinkGroupMap(List<FilterGroup> filterGroups) {
    Map<String, String> r = {};
    filterGroups.forEach((grp) {
      grp.filters.forEach((f) {
        r[f.link] = grp.key;
      });
    });
    return r;
  }

  static Map<String, String> _buildLinkTitleMap(List<FilterGroup> filterGroups) {
    Map<String, String> r = {};
    filterGroups.forEach((grp) {
      grp.filters.forEach((f) {
        r[f.link] = f.title;
      });
    });
    return r;
  }

  final List<FilterGroup> filterGroups;
  // final Map<String, FilterGroup> groupMap;
  final List<Order> orders;
  final Map<String, Order> orderMap;
  final Map<String, String> linkGroupMap, linkTitleMap;
}

class FilterSelector {
  FilterSelector(this.basePath, this.meta, { String order, Iterable<String> blacklist })
    : this.order = order ?? meta.orders.first.linkBase
    , this.blacklist = Set.from(blacklist ?? [])
    ;
  final SelectorMeta meta;
  final String basePath;

  String order;
  Set<String> blacklist;
  int page = 1;
  int pageCount;

  Map<String, String> filters = {};

  Order get currentOrder => meta.orderMap[order];

  void selectFilter({ String link, String group }) {
    if (link == null) {
      filters[group] = null;
    } else {
      filters[group ?? meta.linkGroupMap[link]] = link;
    }
  }

  String get filterPath => meta.filterGroups
    .map((grp) => filters[grp.key])
    .where((link) => link != null).join('_');

  String get fullPath =>
    "$basePath${filterPath.isEmpty ? '' : '$filterPath/'}${order}_p$page.html";

  String get url => '$PROTOCOL://$DOMAIN$fullPath';

  static final rePageNo = RegExp(r'_p(\d+)\.html');

  static int parsePageCount(Document doc) {
    final links = doc.querySelectorAll('a.prev');
    return links.isEmpty ? 1 : int.parse(rePageNo.firstMatch(
        links.last.attributes['href'],
      )[1]);
  }

  Future<Document> fetchDom() async {
    final doc = await request.fetchDom(url);
    pageCount ??= parsePageCount(doc);
    return doc;
  }

  bool get isLastPage => page == pageCount;

  @override
  String toString() => fullPath;
}
