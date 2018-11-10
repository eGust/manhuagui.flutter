import 'dart:async';
import 'package:html/dom.dart';

import './selectors.dart';
import '../api/request.dart';

const PROTOCOL = 'https';
const DOMAIN = 'www.manhuagui.com';

abstract class Displayable {
  String get display;
  String get value;
}

typedef SelectedDisplayable = void Function(Displayable);

class Filter extends Displayable {
  Filter({this.title, this.link});
  final String title;
  final String link;

  @override
  String get display => title;

  @override
  String get value => link;

  Map<String, dynamic> toJson() => {'title': title, 'link': link};
  Filter.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        link = json['link'];
}

class Order extends Displayable {
  Order({this.title, this.linkBase});
  final String title;
  final String linkBase;

  @override
  String get display => title;

  @override
  String get value => linkBase;

  String pathWith(int page) =>
      page > 1 ? '${linkBase}_p$page.html' : '$linkBase.html';

  Map<String, dynamic> toJson() => {'title': title, 'linkBase': linkBase};
  Order.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        linkBase = json['linkBase'];
}

const PATH_LIST = '/list/';
const PATH_RANK = '/rank/';
const PATH_AUTHOR = '/alist/';

class FilterGroup {
  static final filterAll = Filter(link: null, title: '全部');
  FilterGroup({this.title, this.key, this.filters});

  final String title;
  final String key;
  final List<Filter> filters;

  FilterGroup.fromDom(Element group)
      : title =
            group.querySelector('label').text.trim().split('：')[0].substring(1),
        key = group.className.replaceAll('filter', '').trim(),
        filters = group
            .querySelectorAll('li > a:not(.on)')
            .map((el) => Filter(
                  title: el.text,
                  link: el.attributes['href'].split('/')[2],
                ))
            .toList();

  Map<String, dynamic> toJson() => {
        'title': title,
        'key': key,
        'filters': filters.map((f) => f.toJson()).toList(),
      };
  FilterGroup.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        key = json['key'],
        filters = (json['filters'] as List)
            .map((json) => Filter.fromJson(json))
            .toList();
}

class WebsiteMetaData {
  WebsiteMetaData();

  DateTime timestamp;
  List<FilterGroup> comicFilterGroupList, authorFilterGroupList;
  // Map<String, FilterGroup> comicFilterGroupMap, authorFilterGroupMap;
  List<Order> comicListOrders, authorListOrders;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp?.toIso8601String(),
        'comicFilterGroupList':
            comicFilterGroupList.map((g) => g.toJson()).toList(),
        'authorFilterGroupList':
            authorFilterGroupList.map((g) => g.toJson()).toList(),
        'comicListOrders': comicListOrders.map((g) => g.toJson()).toList(),
        'authorListOrders': authorListOrders.map((g) => g.toJson()).toList(),
      };

  // static Map<String, FilterGroup> _convertListToMap(List<FilterGroup> list) =>
  //   list.asMap().map((_, group) => MapEntry(group.key, group));

  static List<FilterGroup> _decodeJsonList(List json) =>
      (json ?? []).map((json) => FilterGroup.fromJson(json)).toList();
  static List<Order> _decodeJsonOrders(List json) =>
      (json ?? []).map((json) => Order.fromJson(json)).toList();

  WebsiteMetaData.fromJson(Map<String, dynamic> json) {
    timestamp =
        json['timestamp'] == null ? null : DateTime.parse(json['timestamp']);
    comicFilterGroupList = _decodeJsonList(json['comicFilterGroupList']);
    // comicFilterGroupMap = _convertListToMap(comicFilterGroupList);

    authorFilterGroupList = _decodeJsonList(json['authorFilterGroupList']);
    // authorFilterGroupMap = _convertListToMap(authorFilterGroupList);

    comicListOrders = _decodeJsonOrders(json['comicListOrders']);
    authorListOrders = _decodeJsonOrders(json['authorListOrders']);
  }

  Future<MapEntry<List<FilterGroup>, List<Order>>> fetchParse(
      String basePath) async {
    final doc = await fetchDom('$PROTOCOL://$DOMAIN$basePath');
    var list = doc
        .querySelectorAll('.filter-nav > .filter')
        .map((el) => FilterGroup.fromDom(el))
        .toList();
    final orders = doc.querySelectorAll('.book-sort ul > li > a').map((a) {
      final link = a.attributes['href']
          .substring(basePath.length)
          .replaceAll('.html', '');
      return Order(
        title: a.text,
        linkBase: link.isEmpty ? 'index' : link,
      );
    }).toList();
    list = list.length > 5
        ? list.where((grp) => grp.key != 'letter').toList()
        : list;
    return MapEntry(list, orders);
  }

  Future<WebsiteMetaData> refresh() async {
    timestamp = DateTime.now();
    final comicList = await fetchParse(PATH_LIST);
    comicFilterGroupList = comicList.key;
    // comicFilterGroupMap = _convertListToMap(comicFilterGroupList);
    comicListOrders = comicList.value;

    final authorList = await fetchParse(PATH_AUTHOR);
    authorFilterGroupList = authorList.key;
    // authorFilterGroupMap = _convertListToMap(authorFilterGroupList);
    authorListOrders = authorList.value;

    return this;
  }

  SelectorMeta _comicMeta, _authorMeta;

  SelectorMeta get comicMeta {
    _comicMeta = _comicMeta ??
        SelectorMeta(
          filterGroups: comicFilterGroupList,
          orders: comicListOrders,
        );
    return _comicMeta;
  }

  SelectorMeta get authorMeta {
    _authorMeta = _authorMeta ??
        SelectorMeta(
          filterGroups: authorFilterGroupList,
          orders: authorListOrders,
        );
    return _authorMeta;
  }

  FilterSelector createComicSelector(String order) => FilterSelector(
        '/list/',
        comicMeta,
        order: order,
      );

  FilterSelector createAuthorSelector() => FilterSelector(
        '/alist/',
        authorMeta,
      );
}
