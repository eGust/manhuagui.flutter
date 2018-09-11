import 'dart:async';
import 'package:flutter/material.dart';

import './side_bar.dart';
import '../progressing.dart';
import '../filter_dialog.dart';
import '../../store.dart';
import '../../models.dart';
import '../../routes.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class ComicList extends StatefulWidget {
  ComicList(this.router) :
    this.filterSelector = globals.metaData.createComicSelector(
      order: pathOrderMap[router.path],
      blacklist: globals.blacklistSet
    );

  final SubRouter router;
  final FilterSelector filterSelector;

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank':     'view',
    'comic_update':   'update',
  };

  @override
  _ComicListState createState() => _ComicListState(router.label, filterSelector);
}

class _ComicListState extends State<ComicList> {
  _ComicListState(this.title, this.filterSelector);

  final String title;
  final FilterSelector filterSelector;
  bool _pinned = false, _blacklistEnabled = true, _fetching = false, _indicator = false;
  List<ComicCover> comics = [];
  Set<int> bookIds = Set();
  ScrollController _scroller = ScrollController();

  Future<void> _showFilterDialog({ bool forceRefresh = false }) async {
    final filters = Map<String, String>.from(filterSelector.filters);

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: DialogTopBar(
          title, _pinned,
          onPinChanged: (bool pinned) {
            _pinned = pinned;
          },
        ),
        children: [
          DialogBody(
            filterSelector.meta.filterGroups,
            filters,
            onSelectedFilter: () {
              if (_pinned) return;
              Navigator.pop(context, null);
            },
            blacklist: filterSelector.blacklist,
          ),
        ],
      ),
    );

    final oldFilterPath = filterSelector.filterPath;
    filters.forEach((group, link) {
      filterSelector.selectFilter(link: link, group: group);
    });
    if (oldFilterPath == filterSelector.filterPath && !forceRefresh) return;

    _refresh();
  }

  Future<void> _refresh({ bool indicator = true }) async {
    if (_fetching || !mounted) return;
    setState(() {
      _indicator = indicator;
      filterSelector.page = 1;
      comics.clear();
      bookIds.clear();
      _fetching = true;
    });
    await _fetchNextPage();
  }

  void _nextPage() async {
    if (_fetching || !mounted) return;
    setState(() {
      _fetching = true;
    });
    _fetchNextPage();
  }

  void _scrollToTop() {
    _scroller.animateTo(
      0.1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  bool _notInBlacklist(ComicCover cover) =>
    cover.tagSet == null || filterSelector.blacklist.intersection(cover.tagSet).isEmpty;

  Future<void> _fetchNextPage() async {
    final doc = await filterSelector.fetchDom();

    if (!mounted) return;
    filterSelector.page += filterSelector.page;
    final covers = ComicCover.parseDesktop(doc)
      .where((c) => !bookIds.contains(c.bookId)).toList();
    await globals.db?.updateCovers(covers);

    if (!mounted) return;
    setState(() {
      _fetching = false;
      comics.addAll(covers);
      bookIds.addAll(covers.map((c) => c.bookId));
    });
  }

  Widget _buildCover(ComicCover cover) =>
    _Cover(
      cover,
      onComicPressed: () {
        Routes.navigateComic(context, cover);
      },
      onAuthorPressed: (authorLink) {
        Routes.navigateAuthor(context, authorLink);
      },
    );

  Widget _buildCoverList() {
    final covers = _blacklistEnabled ? comics.where(_notInBlacklist).toList() : comics;
    final count = covers.length;
    return ListView.builder(
      controller: _scroller,
      itemCount: count + 1,
      padding: const EdgeInsets.all(0.0),
      itemBuilder: (_, i) => i == count ?
        Progressing(visible: _indicator && _fetching) :
        _buildCover(covers[i],),
    );
  }

  void _quickSelectFilter(Duration _) async {
    await _showFilterDialog(forceRefresh: true);
    _pinned = true;
  }

  void _switchBlacklist() {
    setState(() {
      _blacklistEnabled = !_blacklistEnabled;
    });
  }

  static const _NEXT_THRESH_HOLD = 2500.0; // > 10 items

  @override
  void initState() {
    super.initState();
    _scroller.addListener(() {
      if (_scroller.position.pixels + _NEXT_THRESH_HOLD > _scroller.position.maxScrollExtent) {
        _nextPage();
      }
    });
    filterSelector.filters.clear();
    WidgetsBinding.instance.addPostFrameCallback(_quickSelectFilter);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  Text _selectedFiltersText() {
    final filters = filterSelector.meta.filterGroups
      .map((grp) => filterSelector.filters[grp.key])
      .where((s) => s != null).toList();
    return filters.isEmpty ?
      Text(
        '全部',
        style: TextStyle(color: Colors.grey[100], fontSize: 18.0),
      ) :
      Text(
        filters.map((link) => filterSelector.meta.linkTitleMap[link]).join(', '),
        style: TextStyle(color: Colors.amber[300], fontSize: 17.0),
      );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        height: 36.0,
        color: Colors.brown[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: const Icon(Icons.filter_list, color: Colors.white, size: 28.0),
                    margin: const EdgeInsets.only(right: 10.0),
                  ),
                  _selectedFiltersText(),
                ],
              ),
              onPressed: _showFilterDialog,
            ),
            Container(
              width: 150.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    child: _blacklistEnabled ?
                      Icon(Icons.blur_off, color: Colors.red[200], size: 28.0) :
                      const Icon(Icons.blur_on, color: Colors.white, size: 28.0) ,
                    onTap: _switchBlacklist,
                  ),
                  GestureDetector(
                    child: const Icon(Icons.refresh, color: Colors.white, size: 28.0) ,
                    onTap: _refresh,
                  ),
                  GestureDetector(
                    child: const Icon(Icons.vertical_align_top, color: Colors.white, size: 28.0) ,
                    onTap: _scrollToTop,
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => _refresh(indicator: false),
          child: _buildCoverList(),
        ),
      ),
    ],
  );
}

class _Cover extends StatelessWidget {
  _Cover(this._cover, { this.onComicPressed, this.onAuthorPressed });

  final VoidCallback onComicPressed;
  final AuthorLinkCallback onAuthorPressed;

  Widget _wrapTouch(Widget w) => GestureDetector(
    child: w,
    onTap: onComicPressed,
  );

  final ComicCover _cover;
  @override
  Widget build(BuildContext context) => _wrapTouch(Container(
    height: 242.0,
    padding: const EdgeInsets.only(right: 6.0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.orange[300])),
      color: _cover.restricted ? Colors.pink[50] : Colors.transparent,
    ),
    child: Row(children: [
      Container(
        width: 180.0,
        height: 240.0,
        child: Image.network(
          _cover.getImageUrl(),
          headers: { 'Referer': 'https://m.manhuagui.com' },
        ),
      ),
      Expanded(child: Container(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _cover.name,
              style: TextStyle(
                fontSize: 20.0,
                color: _cover.restricted ? Colors.pink[600] : Colors.deepPurple[900],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '[${_cover.finished ? '完结' : '连载'}] ${_cover.lastChpTitle}',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: _cover.finished ? Colors.red[800] : Colors.green[800],
                  ),
                ),
                Text(
                  '更新 ${globals.formatDate(_cover.updatedAt)}',
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            Row(
              children: _cover.authors == null ? [
                Text(
                  '[无作者数据]',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red[600],
                  ),
                ),
              ] : _cover.authors.map((author) => Container(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: GestureDetector(
                  child: Text(
                    author.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.lightBlue[900],
                    ),
                  ),
                  onTap: () {
                    if (onAuthorPressed == null) return;
                    onAuthorPressed(author);
                  },
                )
              )).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  (_cover.tags ?? ['[无类型数据]']).join(' '),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  '${_cover.restricted ? '*' : ''}${_cover.score}',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Container(
              height: 100.0,
              padding: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.orange[100])),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _cover.shortIntro ?? '无简介数据',
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    ]),
  ));
}
