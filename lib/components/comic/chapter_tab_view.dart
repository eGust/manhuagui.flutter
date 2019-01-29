import 'package:flutter/material.dart';

import '../progressing.dart';
import '../../models.dart';

class ChapterTabView extends StatelessWidget {
  ChapterTabView(this.comic, {this.controller, this.onPressed});

  final ComicBook comic;
  final TabController controller;
  final PressedChapter onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          color: Colors.grey[200],
          child: comic.chapterGroups.isEmpty
              ? Progressing(size: 50.0, strokeWidth: 5.0)
              : Column(
                  children: [
                    Container(
                      color: Colors.yellow[800],
                      height: 36.0,
                      child: TabBar(
                        controller: controller,
                        indicatorColor: Colors.deepOrange[900],
                        labelStyle: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                        ),
                        labelColor: Colors.deepOrange[900],
                        unselectedLabelColor: Colors.white,
                        tabs: comic.chapterGroups
                            .map((grp) => Tab(text: grp))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: controller,
                        children: comic.chapterGroups
                            .map(
                              (grp) => GridView.count(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 4.0,
                                    childAspectRatio: 1.6,
                                    children: comic.groupedChapterIdListMap[grp]
                                        .map((chId) => ChapterButton(
                                              comic.chapterMap[chId],
                                              onPressed: onPressed,
                                            ))
                                        .toList(),
                                  ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
        ),
      );
}

typedef PressedChapter = void Function(Chapter);

class ChapterButton extends StatelessWidget {
  ChapterButton(this.chapter, {this.onPressed});

  final Chapter chapter;
  final PressedChapter onPressed;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(4.0, 3.0, 4.0, 3.0),
        child: RawMaterialButton(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.orange, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          fillColor: chapter.neverRead ? Colors.yellow[300] : Colors.red[700],
          splashColor: Colors.orange,
          padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
          child: Column(children: [
            Text(
              chapter.title.split(' ')[0],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    chapter.neverRead ? Colors.brown[900] : Colors.yellow[100],
                fontSize: 15.0,
              ),
            ),
            Text(
              '${chapter.pageCount} pics',
              style: TextStyle(
                color: chapter.neverRead ? Colors.grey[700] : Colors.grey[300],
                fontSize: 12.0,
              ),
            ),
          ]),
          onPressed: () {
            if (onPressed == null) return;
            onPressed(chapter);
          },
        ),
      );
}
