import 'dart:async';
import 'package:flutter/material.dart';

import 'side_bar.dart';
import '../filter_dialog.dart';
import '../comic_list.dart';
import '../../store.dart';
import '../../models.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class HomeComicList extends StatelessWidget {
  HomeComicList(this.router);
  final SubRouter router;

  @override
  Widget build(BuildContext context) => ComicList(HomeComicListManager(router));
}

class HomeComicListManager extends ComicListManagerBase {
  HomeComicListManager(this.router)
      : this.filterSelector =
            globals.metaData.createComicSelector(pathOrderMap[router.path]);

  final SubRouter router;
  final FilterSelector filterSelector;
  bool _pinned = false;

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank': 'view',
    'comic_update': 'update',
  };

  @override
  void reset() {
    super.reset();
    filterSelector.filters.clear();
    _pinned = false;
  }

  @override
  bool get popupFilterDialog => true;

  @override
  void onInitialized() {
    _pinned = true;
  }

  @override
  void resetPageIndex() {
    filterSelector.page = 0;
  }

  @override
  String get filtersTitle => filterSelector.meta.filterGroups
      .map((grp) => filterSelector.filters[grp.key])
      .where((s) => s != null)
      .map((link) => filterSelector.meta.linkTitleMap[link])
      .join(', ');

  @override
  bool notInBlacklist(ComicCover cover) =>
      cover.tagSet == null ||
      globals.blacklistSet.intersection(cover.tagSet).isEmpty;

  @override
  bool get isLastPage => filterSelector.page == filterSelector.pageCount;

  @override
  Future<Iterable<ComicCover>> fetchNextPage() async {
    filterSelector.page += 1;
    final doc = await filterSelector.fetchDom();
    return ComicCover.parseDesktop(doc);
  }

  @override
  Future<bool> showDialogChanged(BuildContext context) async {
    final filters = Map<String, String>.from(filterSelector.filters);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
            title: DialogTopBar(
              router.label,
              pinned: _pinned,
              onPinChanged: (bool pinned) {
                _pinned = pinned;
              },
            ),
            children: [
              DialogBody(
                filterSelector.meta.filterGroups,
                filters,
                blacklist: globals.blacklistSet,
                onSelectedFilter: () {
                  if (_pinned) return;
                  Navigator.pop(context);
                },
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
