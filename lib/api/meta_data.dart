import 'dart:async';
import 'package:html/dom.dart';

import 'request.dart';

const PROTOCOL = 'http';
const DOMAIN = 'www.manhuagui.com';

class Filter {
  Filter({ this.title, this.link });
  final String title;
  final String link;

  Map<String, dynamic> toJson() => { 'title': title, 'link': link };
  Filter.fromJson(Map<String, dynamic> json)
    : title = json['title']
    , link = json['link']
    ;
}

class Order {
  Order({ this.title, this.linkBase });
  final String title;
  final String linkBase;

  Map<String, dynamic> toJson() => { 'title': title, 'linkBase': linkBase };
  Order.fromJson(Map<String, dynamic> json)
    : title = json['title']
    , linkBase = json['linkBase']
    ;
}

const PATH_LIST = '/list/';
const PATH_RANK = '/rank/';
const PATH_AUTHOR = '/alist/';

class FilterGroup {
  static final filterAll = Filter(link: null, title: '全部');
  final String title;
  final String key;
  final List<Filter> filters;

  FilterGroup.fromDom(Element group)
    : title = group.querySelector('label').text.trim().split('：')[0].substring(1)
    , key = group.className.replaceAll('filter', '').trim()
    , filters = group.querySelectorAll('li > a:not(.on)').map((el) => Filter(
        title: el.text,
        link: el.attributes['href'].split('/')[2],
      )).toList()
    ;

  Map<String, dynamic> toJson() => {
      'title': title,
      'key': key,
      'filters': filters.map((f) => f.toJson()).toList(),
    };
  FilterGroup.fromJson(Map<String, dynamic> json)
    : title = json['title']
    , key = json['key']
    , filters = (json['key'] as List).map((json) => Filter.fromJson(json)).toList()
    ;
}

class MetaData {
  MetaData();
  List<FilterGroup> comicFilterGroupList, authorFilterGroupList;
  // Map<String, FilterGroup> comicFilterGroupMap, authorFilterGroupMap;
  List<Order> comicListOrders, comicRankOrders, authorListOrders;

  Map<String, dynamic> toJson() => {
      'comicFilterGroupList': comicFilterGroupList.map((g) => g.toJson()).toList(),
      'authorFilterGroupList': authorFilterGroupList.map((g) => g.toJson()).toList(),
      'comicListOrders': comicListOrders.map((g) => g.toJson()).toList(),
      'comicRankOrders': comicRankOrders.map((g) => g.toJson()).toList(),
      'authorListOrders': comicRankOrders.map((g) => g.toJson()).toList(),
    };

  // static Map<String, FilterGroup> _convertListToMap(List<FilterGroup> list) =>
  //   list.asMap().map((_, group) => MapEntry(group.key, group));

  static List<FilterGroup> _decodeJsonList(json) =>
    ((json ?? []) as List<Map<String, dynamic>>).map((json) => FilterGroup.fromJson(json)).toList();
  static List<Order> _decodeJsonOrders(json) =>
    ((json ?? []) as List<Map<String, dynamic>>).map((json) => Order.fromJson(json)).toList();

  MetaData.fromJson(Map<String, dynamic> json) {
    comicFilterGroupList = _decodeJsonList(json['comicFilterGroupList']);
    // comicFilterGroupMap = _convertListToMap(comicFilterGroupList);

    authorFilterGroupList = _decodeJsonList(json['authorFilterGroupList']);
    // authorFilterGroupMap = _convertListToMap(authorFilterGroupList);

    comicListOrders = _decodeJsonOrders(json['comicListOrders']);
    comicRankOrders = _decodeJsonOrders(json['comicRankOrders']);
    authorListOrders = _decodeJsonOrders(json['authorListOrders']);
  }

  Future<MapEntry<List<FilterGroup>, List<Order>>> fetchParse(String url) async {
    final doc = await fetchDom(url);
    final list = doc.querySelectorAll('.filter-nav > .filter')
      .map((el) => FilterGroup.fromDom(el)).toList();
    final orders = doc.querySelectorAll('.book-sort ul > li > a')
      .map((a) {
        final link = a.attributes['href'].substring(PATH_LIST.length).replaceAll('.html', '');
        return Order(
            title: a.text,
            linkBase: link.isEmpty ? 'index' : link,
          );
      }).toList();
    return MapEntry(list, orders);
  }

  Future refresh() async {
    final comicList = await fetchParse('$PROTOCOL://$DOMAIN$PATH_LIST');
    comicFilterGroupList = comicList.key;
    // comicFilterGroupMap = _convertListToMap(comicFilterGroupList);
    comicListOrders = comicList.value;

    final authorList = await fetchParse('$PROTOCOL://$DOMAIN$PATH_AUTHOR');
    authorFilterGroupList = authorList.key;
    // authorFilterGroupMap = _convertListToMap(authorFilterGroupList);
    authorListOrders = authorList.value;

    final docRank = await fetchDom('$PROTOCOL://$DOMAIN$PATH_RANK');
    comicRankOrders = docRank.querySelectorAll('.top-tab ul > li > a')
      .map((a) {
        final link = a.attributes['href'].substring(PATH_LIST.length).replaceAll('.html', '');
        return Order(
            title: a.text,
            linkBase: link.isEmpty ? 'index' : link,
          );
      }).toList();
  }
}
