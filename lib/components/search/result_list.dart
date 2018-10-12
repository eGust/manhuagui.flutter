import 'dart:async';
import 'package:flutter/material.dart';

import '../progressing.dart';
import '../touchable_icon.dart';
import '../comic_cover_row.dart';
import '../list_top_bar.dart';
import '../../store.dart';
import '../../models.dart';
import '../../api.dart';

class ResultList extends StatefulWidget {
  ResultList(this.searchKey, { this.onResearch });
  final String searchKey;
  final VoidCallback onResearch;

  String get search => Uri.encodeComponent(searchKey);

  @override
  _ResultListState createState() => _ResultListState(this);
}

class _ResultListState extends State<ResultList> {
  _ResultListState(this.parent);
  final ResultList parent;

  final _scroller = ScrollController();
  final _bookIds = Set<int>();
  final _comics = <ComicCover>[];

  int _page = 0, _pageCount;
  bool _fetching = false, _indicator = false, _useBlacklist = true;

  bool get _isLastPage => _page == _pageCount;

  static const _NEXT_THRESHOLD = 2500.0; // > 10 items
  static const _BASE_URL = 'https://www.manhuagui.com/s/'; // > 10 items
  static const _ORDER_MAP = {
    '': '最新更新',
    '_o1': '最近最热',
    '_o2': '最新上架',
    '_o3': '评分最高',
  };

  String _order = '';

  void _switchOrder() async {
    final newOrder = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('排序'),
            TouchableIcon(Icons.close,
              onPressed: () {
                Navigator.pop(context, null);
              },
            )
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            width: 240.0,
            height: 240.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List<Widget>.from(
                _ORDER_MAP.entries.map((pair) =>
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context, pair.key);
                    },
                    color: pair.key == _order ? Colors.deepOrange[800] : Colors.orange[700],
                    child: Text(pair.value, style: TextStyle(
                      color: pair.key == _order ? Colors.white : Colors.brown[700],
                      fontSize: 18.0,
                    )),
                  )
                )
              ),
            )
          )
        ],
      ),
    );

    if (newOrder == null) return;
    _order = newOrder;
    _refresh(indicator: true);
  }

  String get url
    => '$_BASE_URL${parent.search}$_order${_page > 1 ? '_p$_page' : ''}.html';

  void _scrollToTop() {
    _scroller.animateTo(
      0.1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> _refresh({ bool indicator = false }) async {
    setState(() {
      _indicator = indicator;
      _page = 0;
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
    final doc = await fetchDom(url);
    final covers = ComicCover.parseAuthor(doc).toList();
    final coverMap = Map.fromEntries(covers.map((c) => MapEntry(c.bookId, c)));
    await globals.updateCovers(coverMap);
    _pageCount ??= FilterSelector.parsePageCount(doc);

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
    _scroller.addListener(() {
      if (_scroller.position.pixels + _NEXT_THRESHOLD > _scroller.position.maxScrollExtent) {
        if (_fetching || !mounted) return;
        _fetchNextPage();
      }
    });

    _refresh(indicator: true);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  void _updateHistory() async {
    await globals.updateChapterProgresses(_comics);
    if (!mounted) return;
    setState(() {});
  }

  void _toggleBlacklist() {
    setState(() {
      _useBlacklist = !_useBlacklist;
    });
  }

  bool _isComicNotInBlacklist(ComicCover cover) =>
    globals.blacklistSet.intersection(cover.tagSet).isEmpty;

  List<ComicCover> get _filteredComicList =>
    _useBlacklist ? _comics.where(_isComicNotInBlacklist).toList() : _comics;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      TopBarFrame(
        left: <Widget>[
          TouchableIcon(
            Icons.arrow_back_ios,
            size: 28.0,
            color: Colors.white,
            onPressed: () { Navigator.pop(context); },
          ),
          FlatButton(
            onPressed: _switchOrder,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: const Icon(Icons.filter_list, color: Colors.yellow, size: 28.0),
                  margin: const EdgeInsets.only(right: 10.0),
                ),
                Text(_ORDER_MAP[_order], style: const TextStyle(color: Colors.yellow, fontSize: 16.0)),
              ],
            ),
          ),
        ],
        middle: Text('搜索：${parent.searchKey}', style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        )),
        right: <Widget>[
          BlacklistButton(_useBlacklist, _toggleBlacklist),
          TouchableIcon(
            Icons.edit,
            size: 28.0,
            color: Colors.white,
            onPressed: parent.onResearch,
          ),
        ],
        onPressed: _scrollToTop,
      ),
      Expanded(child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scroller,
          itemCount: _filteredComicList.length + 1,
          padding: const EdgeInsets.all(0.0),
          itemBuilder: (_, i) => i == _filteredComicList.length ?
            Progressing(visible: _indicator && _fetching) :
            ComicCoverRow(_filteredComicList[i], context, onPopComic: _updateHistory),
        ),
      )),
    ],
  );
}
