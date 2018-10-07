import 'package:flutter/material.dart';

import './read_action_panel.dart';
import '../touchable_icon.dart';

class InfoPanel extends StatelessWidget {
  InfoPanel({
    @required this.onGoBack, @required this.onPageChanged, @required this.onDownload,
    @required this.onReadModeAction, @required this.onChapterChanged, @required this.onPageChanging,
    @required this.title, @required this.subTitle,
    @required this.invalidPrevPage, @required this.invalidNextPage,
    @required this.invalidPrevChapter, @required this.invalidNextChapter,
    @required this.pageIndex, @required this.pageCount,
  });

  final VoidCallback onGoBack, onPageChanged, onDownload;
  final ReadAction onReadModeAction, onChapterChanged, onPageChanging;
  final String title, subTitle;
  final bool invalidPrevPage, invalidNextPage;
  final bool invalidPrevChapter, invalidNextChapter;
  final int pageIndex, pageCount;

  static final _disabledColor = Colors.grey[500];

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Container(
        color: Color.fromARGB(200, 40, 40, 40),
        height: 100.0,
        padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TouchableIcon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 32.0,
              onPressed: onGoBack,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                Text(subTitle,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            TouchableIcon(
              Icons.file_download,
              color: Colors.white,
              disabled: true,
              disabledColor: _disabledColor,
              size: 32.0,
              onPressed: onDownload,
            ),
          ],
        ),
      ),
      Expanded(child: GestureDetector(onTap: onReadModeAction)),
      Container(
        color: Color.fromARGB(200, 40, 40, 40),
        height: 72.0,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TouchableIcon(
              Icons.fast_rewind,
              color: Colors.white,
              disabled: invalidPrevChapter,
              disabledColor: _disabledColor,
              size: 32.0,
              onPressed: () {
                onChapterChanged(offset: 0 - 1);
              },
            ),
            TouchableIcon(
              Icons.arrow_left,
              color: Colors.white,
              disabled: invalidPrevPage,
              disabledColor: _disabledColor,
              size: 32.0,
              onPressed: () {
                onReadModeAction(offset: 0 - 1);
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: pageCount == null ? Container() :
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        '${pageIndex == null ? '' : pageIndex + 1} / $pageCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                      Slider(
                        divisions: pageCount - 1,
                        min: 1.0,
                        max: pageCount.toDouble(),
                        value: ((pageIndex ?? 0) + 1).toDouble(),
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                        onChangeEnd: (value) {
                          onPageChanged();
                        },
                        onChanged: (value) {
                          onPageChanging(offset: value.toInt() - 1);
                        },
                      ),
                    ]
                  )
              ),
            ),
            TouchableIcon(
              Icons.arrow_right,
              color: Colors.white,
              disabled: invalidNextPage,
              disabledColor: _disabledColor,
              size: 32.0,
              onPressed: () {
                onReadModeAction(offset: 0 + 1);
              },
            ),
            TouchableIcon(
              Icons.fast_forward,
              color: Colors.white,
              disabled: invalidNextChapter,
              disabledColor: _disabledColor,
              size: 32.0,
              onPressed: () {
                onChapterChanged(offset: 0 - 1);
              },
            ),
          ],
        )
      ),
    ],
  );
}
