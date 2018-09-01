import 'dart:async';
import 'package:flutter/material.dart';

import '../../store.dart';
import '../../api.dart';
import '../../models.dart';
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
  List<MapEntry<String, List<ComicCover>>> comicGroups = [];

  @override
  void initState() {
    super.initState();
    (() async {
      final doc = await fetchDom('http://m.manhuagui.com/');
      final grps = doc.querySelectorAll('.bar + .main-list').map((el) => MapEntry(
        el.previousElementSibling.querySelector('h2').text,
        el.querySelectorAll('li > a').map((a) => ComicCover.fromDom(a)).toList()
      )).toList();
      final covers = grps.map((g) => g.value).expand((List<ComicCover> i) => i).toList();
      await globals.db.updateCovers(covers);

      setState(() {
        comicGroups = grps;
      });
    })();
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: comicGroups.map(
      (group) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(group.key),
          Container(
            height: 300.0,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: group.value.map((c) => _Cover(c)).toList(),
            ),
          ),
        ],
      )
    ).toList(),
  );
}

class _Cover extends StatelessWidget {
  _Cover(this.cover) : this.color = cover.finished ? Colors.red[800] : Colors.green[800];
  final ComicCover cover;
  final Color color;
  static const _tagStyle = const TextStyle(
      fontSize: 9.0
    );

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(5.0),
    width: 210.0,
    child: Column(
      children: <Widget>[
        Image.network(
          cover.getImageUrl(),
          headers: { 'Referer': 'https://m.manhuagui.com' },
        ),
        Text(
          cover.name,
          style: TextStyle(
            color: color,
            fontSize: 14.0
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              cover.lastChpTitle,
              style: TextStyle(
                color: color,
                fontSize: 11.0
              ),
            ),
          ] + cover.authors.map((a) => Text(
            a.name,
            style: const TextStyle(
              fontSize: 11.0
            ),
          )).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: cover.tags.map((tag) => Text(tag, style: _tagStyle)).toList(),
        ),
      ],
    )
  );
}
