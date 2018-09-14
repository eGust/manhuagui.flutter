import 'dart:async';
import 'package:flutter/material.dart';

import './progressing.dart';
import './comic_list_top_bar.dart';
import './comic_cover_row.dart';
import '../models.dart';
import '../routes.dart';
import '../store.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

abstract class ComicListManagerBase {
  void reset();
  void onFinishedInitialization() {}
  void resetPageIndex();
  String get filtersTitle;
  bool get isLastPage;
  bool notInBlacklist(ComicCover comic);
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
  bool _blacklistEnabled = true, _fetching = false, _indicator = false;
  List<ComicCover> comics = [];
  Set<int> bookIds = Set();
  ScrollController _scroller = ScrollController();

  Future<void> _showFilterDialog({ bool isInitial = false }) async {
    final changed = await stateManager.showDialogChanged(context);
    if (changed || isInitial) _refresh();
    if (isInitial) stateManager.onFinishedInitialization();
  }

  Future<void> _refresh({ bool indicator = true }) async {
    if (_fetching || !mounted) return;
    setState(() {
      _indicator = indicator;
      stateManager.resetPageIndex();
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

  Future<void> _fetchNextPage() async {
    if (stateManager.isLastPage) return;

    final rawCovers = await stateManager.fetchNextPage();
    final covers = rawCovers.where((c) => !bookIds.contains(c.bookId)).toList();
    await globals.db?.updateCovers(covers);

    if (!mounted) return;
    setState(() {
      _fetching = false;
      comics.addAll(covers);
      bookIds.addAll(covers.map((c) => c.bookId));
    });
  }

  Widget _buildCoverList() {
    final covers = _blacklistEnabled ? comics.where(stateManager.notInBlacklist).toList() : comics;
    final count = covers.length;
    return ListView.builder(
      controller: _scroller,
      itemCount: count + 1,
      padding: const EdgeInsets.all(0.0),
      itemBuilder: (_, i) => i == count ?
        Progressing(visible: _indicator && _fetching) :
        ((cover) =>
          ComicCoverRow(
            cover,
            onComicPressed: () {
              Routes.navigateComic(context, cover);
            },
            onAuthorPressed: (authorLink) {
              Routes.navigateAuthor(context, authorLink);
            },
          )
        )(covers[i]),
    );
  }

  void _quickSelectFilter(Duration _) async {
    await _showFilterDialog(isInitial: true);
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
    stateManager.reset();
    WidgetsBinding.instance.addPostFrameCallback(_quickSelectFilter);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ComicListTopBar(
        enabledBlacklist: _blacklistEnabled,
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
