import 'dart:async';
import 'package:flutter/material.dart';

import '../../store.dart';
import '../../api.dart';
import '../../models.dart';
import '../../routes.dart';
import '../progressing.dart';
import './sub_router.dart';

final _router = SubRouter(
  'home',
  Icons.home,
  () => RouteHome(),
  label: '首页',
);

class RouteHome extends StatefulWidget {
  static final router = _router;

  @override
  _RouteHomeState createState() => _RouteHomeState();
}

class _RouteHomeState extends State<RouteHome> {
  static List<MapEntry<String, List<ComicCover>>> comicGroups;
  static DateTime _updated;
  List<MapEntry<String, List<ComicCover>>> _groups = comicGroups ?? [];

  Future<void> _refresh() async {
    if (_updated != null && DateTime.now().difference(_updated).inSeconds < 100)
      return;

    final doc = await fetchDom('http://m.manhuagui.com/');
    _updated = DateTime.now();
    final grps = doc.querySelectorAll('.bar + .main-list').map((el) => MapEntry(
      el.previousElementSibling.querySelector('h2').text,
      el.querySelectorAll('li > a').map((a) => ComicCover.fromMobileDom(a)).toList()
    )).toList().reversed.toList();
    final covers = Map.fromEntries(
      grps.map((g) => g.value).expand((i) => i).map((c) => MapEntry(c.bookId, c))
    );

    if (!mounted) return;
    setState(() {
      _groups = grps;
    });

    await globals.updateCovers(covers);
    comicGroups = grps;

    if (!mounted) return;
    setState(() {
      _groups = grps;
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) => _groups.isEmpty ?
    Progressing(size: 120.0, strokeWidth: 10.0) :
    ListView(
      children: _groups.map(
        (group) => Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
              child: Text(group.key,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              height: 307.0,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: group.value.map((c) => _HomeCover(c)).toList(),
              ),
            ),
          ],
        )
      ).toList(),
  );
}

class _HomeCover extends StatelessWidget {
  _HomeCover(this.cover) : this.color = cover.finished ? Colors.red[800] : Colors.green[800];
  final ComicCover cover;
  final Color color;
  static final _tagStyle = TextStyle(
      color: Colors.blueGrey[900],
      fontSize: 12.0
    );

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 3.0, right: 3.0),
    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
    color: cover.restricted ? Colors.pink[50] : Colors.yellow[100],
    width: 210.0,
    child: Column(
      children: <Widget>[
        GestureDetector(
          child: Image.network(
            cover.getImageUrl(),
            headers: { 'Referer': 'https://m.manhuagui.com' },
          ),
          onTap: () {
            RouteHelper.navigateComic(context, cover);
          },
        ),
        Text(
          cover.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 14.0,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              cover.lastChpTitle,
              style: TextStyle(
                fontSize: 12.0
              ),
            ),
            Text(
              cover.finished ? '[完结]' : '[连载]',
              style: TextStyle(
                color: color,
                fontSize: 11.0
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: (cover.tags ?? []).map((t) => Text(t, style: _tagStyle)).toList(),
        ),
      ],
    )
  );
}
