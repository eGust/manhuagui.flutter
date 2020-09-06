import 'package:flutter/material.dart';

import 'action_panel.dart';
import '../touchable_icon.dart';

class InfoPanel extends StatefulWidget {
  InfoPanel({
    @required this.onGoBack,
    @required this.onPageChanged,
    @required this.onDownload,
    @required this.onReadModeAction,
    @required this.onChapterChanged,
    @required this.onSlidePage,
    @required this.title,
    @required this.subTitle,
    @required this.invalidPrevPage,
    @required this.invalidNextPage,
    @required this.invalidPrevChapter,
    @required this.invalidNextChapter,
    @required this.pageIndex,
    @required this.pageCount,
  });

  final VoidCallback onReadModeAction, onGoBack, onDownload;
  final SlideAction onChapterChanged, onSlidePage, onPageChanged;
  final String title, subTitle;
  final bool invalidPrevPage, invalidNextPage;
  final bool invalidPrevChapter, invalidNextChapter;
  final int pageIndex, pageCount;

  @override
  _InfoPanelState createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> {
  static final _disabledColor = Colors.grey[500];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentPage = widget.pageIndex;
  }

  int currentPage;

  String get pageText {
    if (currentPage == null) return '${widget.pageCount}';
    return currentPage == widget.pageIndex
        ? '${currentPage + 1} / ${widget.pageCount}'
        : '${widget.pageIndex + 1} -> ${currentPage + 1} / ${widget.pageCount}';
  }

  Future<void> syncCurrentPage(Future<void> asyncFunc) async {
    await asyncFunc;
    await Future.delayed(const Duration());
    setState(() {
      currentPage = widget.pageIndex;
    });
  }

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
                  onPressed: widget.onGoBack,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.subTitle,
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
                  onPressed: widget.onDownload,
                ),
              ],
            ),
          ),
          Expanded(child: GestureDetector(onTap: widget.onReadModeAction)),
          Container(
              color: Color.fromARGB(200, 40, 40, 40),
              height: 80.0,
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TouchableIcon(
                    Icons.fast_rewind,
                    color: Colors.white,
                    disabled: widget.invalidPrevChapter,
                    disabledColor: _disabledColor,
                    size: 32.0,
                    onPressed: () =>
                        syncCurrentPage(widget.onChapterChanged(-1)),
                  ),
                  TouchableIcon(
                    Icons.arrow_left,
                    color: Colors.white,
                    disabled: widget.invalidPrevPage,
                    disabledColor: _disabledColor,
                    size: 32.0,
                    onPressed: () => syncCurrentPage(widget.onSlidePage(1)),
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.all(5.0),
                        child: widget.pageCount == null
                            ? Container()
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                    Text(
                                      pageText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    Slider(
                                      divisions: widget.pageCount - 1,
                                      min: 1.0,
                                      max: widget.pageCount.toDouble(),
                                      value: (currentPage + 1).toDouble(),
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white,
                                      onChangeEnd: (value) => syncCurrentPage(
                                        widget.onPageChanged(value.toInt() - 1),
                                      ),
                                      onChanged: (value) => setState(() {
                                        currentPage = value.toInt() - 1;
                                      }),
                                    ),
                                  ])),
                  ),
                  TouchableIcon(
                    Icons.arrow_right,
                    color: Colors.white,
                    disabled: widget.invalidNextPage,
                    disabledColor: _disabledColor,
                    size: 32.0,
                    onPressed: () => syncCurrentPage(widget.onSlidePage(-1)),
                  ),
                  TouchableIcon(
                    Icons.fast_forward,
                    color: Colors.white,
                    disabled: widget.invalidNextChapter,
                    disabledColor: _disabledColor,
                    size: 32.0,
                    onPressed: () =>
                        syncCurrentPage(widget.onChapterChanged(1)),
                  ),
                ],
              )),
        ],
      );
}
