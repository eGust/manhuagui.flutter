import 'dart:async';
import 'package:flutter/material.dart';

import '../components/comic_list.dart';
import '../components/filter_group_list.dart';
import '../store.dart';
import '../models.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class AuthorScreen extends StatelessWidget {
  AuthorScreen(this.author);
  final AuthorLink author;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Container(
        color: Colors.brown[900],
        height: globals.statusBarHeight,
      ),
      Expanded(
        child: ComicList(AuthorComicListManager(author)),
      )
    ],
  );
}

class AuthorComicListManager extends ComicListManagerBase {
  AuthorComicListManager(AuthorLink link)
    : author = AuthorPage.fromLink(link, globals.metaData.comicListOrders.first)
    , orderList = globals.metaData.comicListOrders
    ;

  final AuthorPage author;
  final List<Order> orderList;

  @override
  bool get popupFilterDialog => false;

  @override
  void resetPageIndex() {
    author.page = 0;
  }

  @override
  bool get isScreen => true;

  @override
  String get filtersTitle => author.order.title;

  @override
  String get listTitle => author.name;

  @override
  bool get useBlacklist => false;

  @override
  bool get isLastPage => author.page == author.pageCount;

  @override
  Future<Iterable<ComicCover>> fetchNextPage() async {
    author.page += 1;
    final doc = await author.fetchDom();
    return ComicCover.parseAuthor(doc);
  }

  @override
  Future<bool> showDialogChanged(BuildContext context) async {
    final oldOrder = author.order;
    author.order = await showDialog<Order>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text('排序'),
            FlatButton(
              child: Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, oldOrder);
              },
            ),
          ],
        ),
        children: [
          Row(children: orderList.map((order) =>
            DisplayableButton(
              item: order,
              selected: order == oldOrder,
              onPressed: () {
                Navigator.pop(context, order);
              },
            )).toList(),
          ),
        ],
      ),
    );

    return oldOrder != author.order;
  }
}
