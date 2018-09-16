import 'package:flutter/material.dart';

import '../store.dart';
import '../models.dart';
import '../routes.dart';
import '../components/touchable_icon.dart';
import '../components/progressing.dart';

class ComicScreen extends StatefulWidget {
  ComicScreen(this.cover);

  final ComicCover cover;

  @override
  _ComicScreenState createState() => _ComicScreenState(cover);
}

class _ComicScreenState extends State<ComicScreen> {
  _ComicScreenState(ComicCover cover): this.comic = ComicBook.fromCover(cover);

  ComicBook comic;

  void goBack() {
    Navigator.pop(context);
  }

  void _refresh() async {
    final book = ComicBook.fromCover(comic);
    await book.update();
    if (!mounted) return;

    setState(() {
      comic = book;
    });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _onPressedChapter(Chapter ch) {
    //
  }

  Widget _titleBar() => Container(
    height: 36.0,
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TouchableIcon(
          Icons.arrow_back,
          size: 28.0,
          color: Colors.white,
          onPressed: goBack,
        ),
        Text(
          comic.name,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        TouchableIcon(
          Icons.search,
          size: 28.0,
          color: Colors.white,
        ),
      ],
    ),
  );

  Widget _cover() => Container(
    height: 360.0,
    color: comic.restricted ? Colors.pink[50] : Colors.yellow[50],
    child: Row(
      children: [
        Container(
          width: 240.0,
          child: Image.network(
            comic.getImageUrl(size: CoverSize.xl),
            headers: { 'Referer': 'https://m.manhuagui.com' },
          ),
        ),
        Expanded(child: Container(
          padding: const EdgeInsets.fromLTRB(6.0, 3.0, 15.0, 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '[${comic.finished ? '完结' : '连载'}] ${comic.lastChpTitle}',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: comic.finished ? Colors.red[800] : Colors.green[800],
                    ),
                  ),
                  Text(
                    '更新 ${globals.formatDate(comic.updatedAt)}',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: comic.authors == null ? [
                  Text(
                    '[无作者数据]',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.red[600],
                    ),
                  ),
                ] : comic.authors.map((author) => Container(
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
                      Routes.navigateAuthor(context, author);
                    },
                  )
                )).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    (comic.tags ?? ['[无类型数据]']).join(' '),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    '${comic.restricted ? '[R] ' : ''}${comic.score ?? '??'}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    '${comic.rank ?? '...'}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  )
                ],
              ),
              Container(
                height: 220.0,
                child: SingleChildScrollView(
                  child: Text(
                    comic.introduction.join('\n'),
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          )),
        ),
      ],
    ),
  );

  Widget _chapterTabs() => Expanded(
    child: Container(
      color: Colors.white,
      child: comic.chapterGroups.isEmpty ? Progressing(size: 80.0, strokeWidth: 8.0) :
        DefaultTabController(
          length: comic.chapterGroups.length,
          child: Column(children: [
            Container(
              color: Colors.amber[800],
              height: 36.0,
              child: TabBar(
                indicatorColor: Colors.yellow,
                labelStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                unselectedLabelColor: Colors.grey[800],
                tabs: comic.chapterGroups.map((grp) => Tab(text: grp)).toList(),
              ),
            ),
            Expanded(child: TabBarView(
              children: comic.chapterGroups.map((grp) => SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(3.0, 1.0, 3.0, 15.0),
                  child: Wrap(
                    children: comic.groupedChapterIdListMap[grp]
                      .map((chId) =>
                        _ChapterButton(
                          comic.chapterMap[chId],
                          onPressed: _onPressedChapter,
                        )
                      ).toList(),
                  ),
                ),
              )).toList(),
            )),
          ]),
        ),
    ),
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 20.0),
    color: comic.finished ? Colors.pink[900] : Colors.lightBlue[900],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _titleBar(),
        _cover(),
        _chapterTabs(),
      ],
    ),
  );
}

typedef PressedChapter = void Function(Chapter);

class _ChapterButton extends StatelessWidget {
  _ChapterButton(this.chapter, { this.onPressed });

  final Chapter chapter;
  final PressedChapter onPressed;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
    child: RawMaterialButton(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.orange, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      fillColor: Colors.amber[400],
      splashColor: Colors.orange[400],
      padding: const EdgeInsets.fromLTRB(16.0, 5.0, 14.0, 4.0),
      child: Column(
        children: [
          Text(
            chapter.title,
            style: TextStyle(
              color: Colors.brown[900],
              fontSize: 15.0,
            ),
          ),
          Text(
            '${chapter.pageCount} pics',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12.0,
            ),
          ),
        ]
      ),
      onPressed: () {
        if (onPressed == null) return;
        onPressed(chapter);
      },
    ),
  );
}
