import 'dart:async';
import 'package:flutter/material.dart';

import './side_bar.dart';
import '../filter_dialog.dart';
import '../../store.dart';
import '../../models.dart';
import '../../utils.dart';

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
  bool _pinned = false;
  bool _blacklistEnabled = true;
  bool _fetching = false;
  List<ComicCover> comics = [];

  Future<void> _showFilterDialog() async {
    final filters = Map<String, String>.from(filterSelector.filters);

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: DialogTopBar(
          title, _pinned,
          onPinChanged: (bool pinned) {
            _pinned = pinned;
            logd('pinned = $_pinned');
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
    if (oldFilterPath == filterSelector.filterPath) return;

    if (!mounted) return;
    setState(() {
      filterSelector.page = 1;
      comics = [];
      _fetching = true;
    });
    _fetchNextPage();
  }

  bool _notInBlacklist(ComicCover cover) =>
    filterSelector.blacklist.intersection(cover.tagSet).isEmpty;

  void _fetchNextPage() async {
    final doc = await filterSelector.fetchDom();

    if (!mounted) return;
    filterSelector.page += filterSelector.page;
    final covers = ComicCover.parseDesktop(doc).toList();
    await globals.db.updateCovers(covers);

    if (!mounted) return;
    setState(() {
      _fetching = false;
      comics.addAll(_blacklistEnabled ? covers.where(_notInBlacklist) : covers);
    });
  }

  void _quickSelectFilter(Duration _) async {
    await _showFilterDialog();
    _pinned = true;
  }

  void _switchBlacklist() {
    setState(() {
      _blacklistEnabled = !_blacklistEnabled;
    });
  }

  @override
  void initState() {
    super.initState();
    filterSelector.filters.clear();
    WidgetsBinding.instance.addPostFrameCallback(_quickSelectFilter);
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
    children: <Widget>[
      Container(
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
            FlatButton(
              child: _blacklistEnabled ?
                Icon(Icons.blur_off, color: Colors.red[200], size: 28.0) :
                const Icon(Icons.blur_on, color: Colors.white, size: 28.0) ,
              onPressed: _switchBlacklist,
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          controller: ScrollController(),
          itemCount: comics.length + 1,
          padding: const EdgeInsets.all(1.0),
          itemBuilder: (_, index) => index == comics.length ?
            _ProgressIndicator(visible: _fetching) :
            _Cover(comics[index]),
        ),
      ),
    ],
  );
}

class _ProgressIndicator extends StatelessWidget {
  _ProgressIndicator({ this.visible = false });
  final bool visible;
  @override
  Widget build(BuildContext context) => visible ?
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(30.0),
      child: CircularProgressIndicator(),
    ) :
    Visibility(visible: false, child: const Text(''))
    ;
}

class _Cover extends StatelessWidget {
  _Cover(this._cover);

  final ComicCover _cover;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2.0),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.only(right: 5.0),
        child: Image.network(
          _cover.getImageUrl(),
          headers: { 'Referer': 'https://m.manhuagui.com' },
        ),
      ),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(_cover.name),
          Row(
            children: [
              const Text('作者: '),
              Text(_cover.authors.map((a) => a.name).join(',')),
            ],
          ),
          Row(
            children: [
              const Text('类型: '),
              Text(_cover.tags.join(',')),
            ],
          ),
          Row(
            children: [
              const Text('评分: '),
              Text(_cover.score),
            ],
          ),
          Row(
            children: [
              const Text('最后更新: '),
              Text('${_cover.lastChpTitle} (${globals.formatDate(_cover.updatedAt)})'),
            ],
          ),
          Text(_cover.shortIntro),
        ],
      )),
    ])
  );
}
