import 'dart:async';
import 'package:flutter/material.dart';

import './progressing.dart';
import './list_top_bar.dart';
import './comic_cover_row.dart';
import '../models.dart';
import '../store.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

abstract class ComicListManagerBase {
  void reset() {
    resetPageIndex();
  }

  bool get popupFilterDialog;
  void onInitialized() {}
  void resetPageIndex();
  String get listTitle => null;
  String get filtersTitle;
  bool get isLastPage;
  bool get isScreen => false;
  bool get useBlacklist => true;
  bool notInBlacklist(ComicCover comic) {
    return true;
  }

  Future<Iterable<ComicCover>> fetchNextPage();
  Future<bool> showDialogChanged(BuildContext context);
}

class ComicList extends StatefulWidget {
  ComicList(this.stateManager);
  final ComicListManagerBase stateManager;
  @override
  _ComicListState createState() => _ComicListState(this.stateManager);
}

class _ComicListState extends State<ComicList> {
  _ComicListState(this.stateManager);

  final ComicListManagerBase stateManager;
  final _comics = <ComicCover>[];
  final _bookIds = Set<int>();
  final _scroller = ScrollController();

  bool _blacklistEnabled = true, _fetching = false, _indicator = false;

  Future<void> _showFilterDialog({bool isInitial = false}) async {
    final changed = await stateManager.showDialogChanged(context);
    if (!mounted) return;
    if (changed || isInitial) _refresh();
    if (isInitial) stateManager.onInitialized();
  }

  Future<void> _refresh({bool indicator = true}) async {
    if (!mounted || _fetching) return;
    setState(() {
      _indicator = indicator;
      stateManager.resetPageIndex();
      _comics.clear();
      _bookIds.clear();
      _fetching = true;
    });
    await _fetchNextPage();
  }

  void _scrollToTop() {
    _scroller.animateTo(
      0.1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _updateHistory() async {
    await globals.updateChapterProgresses(_comics);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _fetchNextPage() async {
    if (stateManager.isLastPage) return;
    setState(() {
      _fetching = true;
    });

    final rawCovers = await stateManager.fetchNextPage();
    final covers =
        rawCovers.where((c) => !_bookIds.contains(c.bookId)).toList();
    final coverMap = Map.fromEntries(covers.map((c) => MapEntry(c.bookId, c)));
    await globals.updateCovers(coverMap);

    if (!mounted) return;
    setState(() {
      _fetching = false;
      _comics.addAll(covers);
      _bookIds.addAll(covers.map((c) => c.bookId));
    });
  }

  Widget _buildCoverList() {
    final covers = stateManager.useBlacklist && _blacklistEnabled
        ? _comics.where(stateManager.notInBlacklist).toList()
        : _comics;
    final count = covers.length;
    return ListView.builder(
      controller: _scroller,
      itemCount: count + 1,
      padding: const EdgeInsets.all(0.0),
      itemBuilder: (_, i) => i == count
          ? Progressing(visible: _indicator && _fetching)
          : ComicCoverRow(covers[i], context, onPopComic: _updateHistory),
    );
  }

  void _initialized(Duration _) {
    if (stateManager.popupFilterDialog) {
      _showFilterDialog(isInitial: true);
    } else {
      _refresh();
    }
  }

  void _switchBlacklist() {
    setState(() {
      _blacklistEnabled = !_blacklistEnabled;
    });
  }

  static const _NEXT_THRESHOLD = 2500.0; // > 10 items

  @override
  void initState() {
    super.initState();
    _scroller.addListener(() {
      if (_scroller.position.pixels + _NEXT_THRESHOLD >
          _scroller.position.maxScrollExtent) {
        if (_fetching || !mounted) return;
        _fetchNextPage();
      }
    });
    stateManager.reset();
    WidgetsBinding.instance.addPostFrameCallback(_initialized);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          ListTopBar(
            isScreen: stateManager.isScreen,
            blacklistEnabled: _blacklistEnabled,
            listTitle: stateManager.listTitle,
            filtersTitle: stateManager.filtersTitle,
            onPressedScrollTop: _scrollToTop,
            onPressedFilters: _showFilterDialog,
            onPressedBlacklist: _switchBlacklist,
            onPressedRefresh: _refresh,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(indicator: false),
              child: _buildCoverList(),
            ),
          ),
        ],
      );
}
