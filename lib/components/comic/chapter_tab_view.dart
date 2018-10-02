import 'package:flutter/material.dart';

import '../progressing.dart';
import '../../routes.dart';
import '../../models.dart';

class ChapterTabView extends StatelessWidget {
  ChapterTabView(this.comic, this.controller);

  final ComicBook comic;
  final TabController controller;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      color: Colors.white,
      child: comic.chapterGroups.isEmpty ? Progressing(size: 80.0, strokeWidth: 8.0) :
        Column(children: [
          Container(
            color: Colors.amber[800],
            height: 36.0,
            child: TabBar(
              controller: controller,
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
            controller: controller,
            children: comic.chapterGroups.map((grp) => SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(3.0, 1.0, 3.0, 15.0),
                child: Wrap(
                  children: comic.groupedChapterIdListMap[grp]
                    .map((chId) =>
                      ChapterButton(
                        comic.chapterMap[chId],
                        onPressed: (chapter) async {
                          RouteHelper.navigateReader(context, ReaderHelper(comic, chapter));
                        },
                      )
                    ).toList(),
                ),
              ),
            )).toList(),
          )),
        ]),
    ),
  );
}

typedef PressedChapter = void Function(Chapter);

class ChapterButton extends StatelessWidget {
  ChapterButton(this.chapter, { this.onPressed });

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
