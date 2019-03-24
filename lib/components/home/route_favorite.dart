import 'dart:async';
import 'package:flutter/material.dart';

import 'sub_router.dart';
import '../progressing.dart';
import '../list_top_bar.dart';
import '../comic_cover_row.dart';
import '../login_form.dart';
import '../../store.dart';
import '../../models.dart';

class RouteFavorite extends StatefulWidget {
  static final router = SubRouter(
    'favorite',
    Icons.favorite,
    () => RouteFavorite(),
    label: '收藏',
  );

  @override
  _RouteFavoriteState createState() => _RouteFavoriteState();
}

class _RouteFavoriteState extends State<RouteFavorite> {
  final _scroll = ScrollController();
  final _bookIds = Set<int>();
  final _comics = <ComicCover>[];

  int _page = 0;
  bool _isLastPage = false, _fetching = false, _indicator = false;

  static const _NEXT_THRESHOLD = 2500.0; // > 10 items

  void _scrollToTop() {
    _scroll.animateTo(
      0.1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> _refresh({bool indicator = false}) async {
    setState(() {
      _indicator = indicator;
      _page = 0;
      _isLastPage = false;
      _fetching = true;
      _comics.clear();
      _bookIds.clear();
    });
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_isLastPage || !mounted || !globals.user.isLogin) return;
    setState(() {
      _fetching = true;
    });

    _page += 1;
    final rawCovers = await globals.user.getFavorites(pageNo: _page);
    final covers =
        rawCovers.where((c) => !_bookIds.contains(c.bookId)).toList();
    final coverMap = Map.fromEntries(covers.map((c) => MapEntry(c.bookId, c)));
    await globals.updateCovers(coverMap);
    _isLastPage = covers.isEmpty;

    if (!mounted) return;
    setState(() {
      _fetching = false;
      _comics.addAll(covers);
      _bookIds.addAll(covers.map((c) => c.bookId));
    });
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels + _NEXT_THRESHOLD >
          _scroll.position.maxScrollExtent) {
        if (_fetching || !mounted) return;
        _fetchNextPage();
      }
    });

    if (globals.user.isLogin) {
      _refresh(indicator: true);
    } else {
      WidgetsBinding.instance.addPostFrameCallback(_askLogin);
    }
  }

  void _askLogin(Duration _) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: const Text('此功能需要登录！'),
            content: Container(
              height: 120.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.lightBlue[700],
                    child: const Text('登录',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        )),
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => SimpleDialog(
                              title: const Text('用户登录'),
                              children: [
                                LoginForm(),
                              ],
                            ),
                      );
                      if (!globals.user.isLogin) return;
                      Navigator.pop(context);
                      _refresh(indicator: true);
                    },
                  ),
                  RaisedButton(
                    color: Colors.red[900],
                    child: const Text('关闭',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        )),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _updateHistory() async {
    await globals.updateChapterProgresses(_comics);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          TopBarFrame(onPressed: _scrollToTop),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scroll,
              itemCount: _comics.length + 1,
              padding: const EdgeInsets.all(0.0),
              itemBuilder: (_, i) => i == _comics.length
                  ? Progressing(visible: _indicator && _fetching)
                  : ComicCoverRow(_comics[i], context,
                      onPopComic: _updateHistory),
            ),
          )),
        ],
      );
}
