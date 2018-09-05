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
  bool _blacklist = true;

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
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() {
      filters.forEach((group, link) {
        filterSelector.selectFilter(link: link, group: group);
      });
    });
  }

  void _quickSelectFilter(Duration _) async {
    await _showFilterDialog();
    _pinned = true;
  }

  void _switchBlacklist() {
    setState(() {
      _blacklist = !_blacklist;
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
              child: _blacklist ?
                Icon(Icons.blur_off, color: Colors.red[200], size: 28.0) :
                const Icon(Icons.blur_on, color: Colors.white, size: 28.0) ,
              onPressed: _switchBlacklist,
            ),
          ],
        ),
      ),
      Expanded(
        child: Container(),
      ),
    ],
  );
}
