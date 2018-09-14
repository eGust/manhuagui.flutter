import 'dart:async';
import 'package:flutter/material.dart';

import './side_bar.dart';
import '../filter_dialog.dart';
import '../comic_list.dart';
import '../../store.dart';
import '../../models.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class HomeComicList extends ComicList {
  HomeComicList(SubRouter router): super(HomeComicListManager(router));
}

class HomeComicListManager extends ComicListManagerBase {
  HomeComicListManager(this.router) :
    this.filterSelector = globals.metaData.createComicSelector(
      order: pathOrderMap[router.path],
      blacklist: globals.blacklistSet
    );

  final SubRouter router;
  final FilterSelector filterSelector;
  bool _pinned = false;

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank':     'view',
    'comic_update':   'update',
  };

  @override
  void reset() {
    filterSelector.filters.clear();
    _pinned = false;
  }

  @override
  void onFinishedInitialization() {
    _pinned = true;
  }

  @override
  void resetPageIndex() {
    filterSelector.page = 1;
  }

  @override
  String get filtersTitle => filterSelector.meta
    .filterGroups
    .map((grp) => filterSelector.filters[grp.key])
    .where((s) => s != null)
    .map((link) => filterSelector.meta.linkTitleMap[link])
    .join(', ');

  @override
  bool notInBlacklist(ComicCover cover) =>
    cover.tagSet == null || filterSelector.blacklist.intersection(cover.tagSet).isEmpty;

  @override
  bool get isLastPage => filterSelector.page == filterSelector.pageCount;

  @override
  Future<Iterable<ComicCover>> fetchNextPage() async {
    final doc = await filterSelector.fetchDom();
    filterSelector.page += filterSelector.page;
    return ComicCover.parseDesktop(doc);
  }

  @override
  Future<bool> showDialogChanged(BuildContext context) async {
    final filters = Map<String, String>.from(filterSelector.filters);

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: DialogTopBar(
          router.label, _pinned,
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
    return oldFilterPath != filterSelector.filterPath;
  }
}
