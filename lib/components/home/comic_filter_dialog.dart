import 'dart:math';
import 'package:flutter/material.dart';

import '../filter_group_list.dart';
import '../../store.dart';
import '../../models.dart';
import '../../utils.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class ComicPageTitle extends StatelessWidget {
  static final _titleStyle = TextStyle(
    fontSize: 30.0,
    color: Colors.purple[900],
  );

  ComicPageTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 20.0),
    child: Text(title, style: _titleStyle),
  );
}

class ComicFilterList extends StatelessWidget {
  ComicFilterList(this.path, { this.onSelected }) {
    if (_filterGroups != null) return;
    final grps = List<FilterGroup>.from(globals.metaData.comicFilterGroupList);
    final minSize = grps.map((grp) => grp.filters.length).reduce(min);
    final minGroup = grps.firstWhere((grp) => grp.filters.length == minSize);
    final group = FilterGroup(
      key: minGroup.key,
      title: minGroup.title,
      filters: [FilterGroup.filterAll] + minGroup.filters,
    );
    _filterGroups = [group] + grps.where((grp) => grp.key != group.key).toList();
  }

  static List<FilterGroup> _filterGroups;
  final String path;
  final ComicFilterSelected onSelected;

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank':     'view',
    'comic_update':   'update',
  };

  void _filterSelected(String filter) {
    if (onSelected == null) {
      logd('Selected filter: $filter (path = $path)');
      return;
    }
    onSelected(filter, pathOrderMap[path]);
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: _filterGroups.map((g) => FilterGroupList(g, _filterSelected)).toList(),
  );
}

