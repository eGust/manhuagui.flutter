import 'dart:async';
import 'package:html/dom.dart';

import '../api/request.dart' as request;
import 'website_meta_data.dart';

enum SelectorType { Comic, Author }

class SelectorMeta {
  SelectorMeta({ this.filterGroups, this.orders })
    : linkGroupMap = _buildLinkGroupMap(filterGroups);

  static Map<String, String> _buildLinkGroupMap(List<FilterGroup> filterGroups) {
    Map<String, String> r = {};
    filterGroups.forEach((grp) {
      grp.filters.forEach((f) {
        r[f.link] = grp.key;
      });
    });
    return r;
  }

  final List<FilterGroup> filterGroups;
  // final Map<String, FilterGroup> groupMap;
  final List<Order> orders;
  final Map<String, String> linkGroupMap;
}

class FilterSelector {
  FilterSelector(this.basePath, this.meta, { String order })
    : this.order = order ?? meta.orders.first.linkBase
    ;
  final SelectorMeta meta;
  final String basePath;

  String order;
  int page = 1;
  int pageCount;

  Map<String, String> filters = {};

  void selectFilter({ String link, String group }) {
    if (link == null) {
      filters[group] = null;
    } else {
      filters[group ?? meta.linkGroupMap[link]] = link;
    }
  }

  String get fullPath {
    final filterPath = meta.filterGroups
      .map((grp) => filters[grp.key])
      .where((link) => link != null).join('_');
    return "$basePath${filterPath.isEmpty ? '' : '$filterPath/'}${order}_p$page.html";
  }

  String get url => '$PROTOCOL://$DOMAIN$fullPath';

  static final _rePageNo = RegExp(r'_p(\d+)\.html');

  Future<Document> fetchDom() async {
    final doc = await request.fetchDom(url);
    final links = doc.querySelectorAll('a.prev');
    pageCount = links.isEmpty ? 1 : int.parse(_rePageNo.firstMatch(
        links.last.attributes['href'],
      )[1]);
    return doc;
  }

  @override
  String toString() => fullPath;
}
