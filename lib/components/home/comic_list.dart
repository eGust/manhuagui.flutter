import 'dart:math';
import 'package:flutter/material.dart';

import '../filter_group_list.dart';
import '../../store.dart';
import '../../models.dart';
import '../../utils.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class ComicList extends StatefulWidget {
  ComicList(this.filterSelector);

  final FilterSelector filterSelector;

  static ComicList fromPath(String path) => ComicList(
    globals.metaData.createComicSelector(
      order: pathOrderMap[path],
    )
  );

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank':     'view',
    'comic_update':   'update',
  };

  @override
  _ComicListState createState() => _ComicListState(filterSelector);
}

class _ComicListState extends State<ComicList> {
  _ComicListState(this.filterSelector);

  final FilterSelector filterSelector;
  bool _pending = true;

  void _quickSelectFilter(Duration _) async {
    final link = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('dialog'),
        children: List<Widget>.from(
          filterSelector.meta.filterGroups
            .map((fg) => FilterGroupList(fg, (link) {
              Navigator.pop(context, link);
            })),
          ),
      ),
    );

    if (!mounted) return;
    setState(() {
      filterSelector.selectFilter(link: link);
      _pending = false;
    });
  }

  @override
  void initState() {
    super.initState();
    filterSelector.filters.clear();
    WidgetsBinding.instance.addPostFrameCallback(_quickSelectFilter);
  }

  @override
  Widget build(BuildContext context) => _pending ? Container() : Container();
}
