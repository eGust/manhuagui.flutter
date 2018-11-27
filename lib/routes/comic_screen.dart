import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../routes.dart';
import '../components/comic/comic_banner.dart';
import '../components/comic/cover_header.dart';
import '../components/comic/chapter_tab_view.dart';

class ComicScreen extends StatefulWidget {
  ComicScreen(this.cover);

  final ComicCover cover;

  @override
  _ComicScreenState createState() =>
      _ComicScreenState(ComicBook.fromCover(cover));
}

class _ComicScreenState extends State<ComicScreen>
    with SingleTickerProviderStateMixin {
  _ComicScreenState(this.comic);

  ComicBook comic;

  void _refresh() async {
    final book = ComicBook.fromCover(comic);
    await book.update();
    book.updateFavorite();
    if (!mounted) return;

    setState(() {
      comic = book;
      _tabController =
          TabController(vsync: this, length: comic.chapterGroups.length);
      _tabController.addListener(_onTabChanging);
    });
  }

  TabController _tabController;
  int _favorite;

  @override
  void initState() {
    super.initState();
    _favorite = comic.isFavorite ? 1 : 0;
    _refresh();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    setState(() {
      _favorite = -1;
    });
    await globals.toggleFavorite(comic);
    if (!mounted) return;

    setState(() {
      _favorite = comic.isFavorite ? 1 : 0;
    });
  }

  void _onChapterPressed(final Chapter chapter, {final int startPage}) async {
    final helper = ReaderHelper(comic, chapter, pageIndex: startPage);
    await RouteHelper.pushReader(context, helper);
    if (!mounted) return;
    setState(() {});
  }

  int _tabIndex = 0;

  void _onTabChanging() {
    if (!_tabController.indexIsChanging) return;
    setState(() {
      _tabIndex = _tabController.index;
    });
  }

  static const _FAV_SYNC =
      SizedBox(height: 30.0, child: CircularProgressIndicator());
  static const _FAV_YES = Icon(Icons.favorite, color: Colors.red, size: 36.0);
  static const _FAV_NO =
      Icon(Icons.favorite_border, color: Colors.orange, size: 36.0);
  static const _FAV_PADDING = EdgeInsets.only(left: 10.0, right: 10.0);

  List<Widget> _buildReadButtons() {
    final buttons = <Widget>[];
    if (_tabController == null) return buttons;

    final chLast = comic.chapterMap[comic.lastChapterId ?? 0];
    if (chLast != null) {
      buttons.add(
        _ReadButton(
          '上次：${chLast.title}',
          color: Colors.purple,
          onPressed: () {
            _onChapterPressed(chLast, startPage: comic.lastChapterPage);
          },
        ),
      );
    }

    final chapterIds = comic.chapterIdsOfGroup(_tabIndex);
    final chMax = chapterIds
        .map((chId) => comic.chapterMap[chId])
        .firstWhere((ch) => !ch.neverRead, orElse: () => null);
    if (chMax != null && chMax != chLast) {
      buttons.add(
        _ReadButton(
          '续读：${chMax.title}',
          color: Colors.red,
          onPressed: () {
            _onChapterPressed(chMax, startPage: chMax.maxPage);
          },
        ),
      );
    }

    final chFirst = comic.chapterMap[chapterIds.last];
    buttons.add(
      _ReadButton(
        '开始阅读：${chFirst.title}',
        flex: buttons.isEmpty ? 1 : 0,
        onPressed: () {
          _onChapterPressed(chFirst);
        },
      ),
    );

    return buttons;
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(top: globals.statusBarHeight),
        color: comic.finished ? Colors.pink[900] : Colors.lightBlue[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ComicBanner(comic.name),
            CoverHeader(comic),
            Container(
              height: 44.0,
              padding: const EdgeInsets.only(left: 6.0, right: 5.0),
              color: Colors.grey[200],
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 50.0,
                      padding: _favorite == -1 ? _FAV_PADDING : null,
                      child: _favorite == -1
                          ? _FAV_SYNC
                          : _favorite == 1 ? _FAV_YES : _FAV_NO,
                    ),
                  ),
                  Expanded(
                      child: Row(
                    children: _buildReadButtons(),
                  )),
                ],
              ),
            ),
            ChapterTabView(
              comic,
              controller: _tabController,
              onPressed: _onChapterPressed,
            ),
          ],
        ),
      );
}

class _ReadButton extends StatelessWidget {
  _ReadButton(
    this.title, {
    @required this.onPressed,
    Color color,
    this.flex = 1,
  }) : this._color = color ?? Colors.orange[900];

  final String title;
  final Color _color;
  final VoidCallback onPressed;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Container(
          margin: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: RawMaterialButton(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0),
            fillColor: _color,
            splashColor: Colors.brown,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 17.0),
            ),
            onPressed: onPressed,
          ),
        ),
      );
}
