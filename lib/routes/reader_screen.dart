import 'dart:io';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../utils.dart';
import '../store.dart';
import '../components/touchable_icon.dart';
import '../components/reader/animation_helper.dart';

class ReaderScreen extends StatefulWidget {
  ReaderScreen(final this.helper);

  final ReaderHelper helper;

  @override
  _ReaderScreenState createState() => _ReaderScreenState(helper);
}

class _ReaderScreenState extends State<ReaderScreen> with TickerProviderStateMixin {
  _ReaderScreenState(final this.helper) {
    StatusBar.hide();
    AnimationHelper.circleSize = globals.screenSize.width / 3;
    AnimationHelper.strokeWidth = AnimationHelper.circleSize / 15;
    _animation = AnimationHelper(this, _onAnimationFinished);
  }

  AnimationHelper _animation;

  void _onAnimationFinished(final int actionId) async {
    print("AnimationFinished $actionId == $_slideActionId");
    if (!mounted || actionId != _slideActionId) return;
    var next = _nextEntry;
    final direction = _direction;

    if (next == null && direction != null) {
      next = await helper.getSiblingEntry(direction == SlideDirection.rightToLeft ? 0 - 1 : 0 + 1);
      if (!mounted || actionId != _slideActionId) return;
    }

    if (next != null) {
      helper.current = next.chapter;
      helper.pageIndex = next.page;
    }

    _reloadImages();
  }

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    await helper.openChapter();
    _reloadImages();
  }

  void _reloadImages() async {
    if (!mounted) return;
    setState(() {
      _currEntry = helper.currentEntry;
      _currentImage = _nextImage;
      _nextImage = null;
      _nextEntry = null;
      _direction = null;
    });

    final file = await _currEntry.loadFile();
    if (!mounted) return;

    setState(() {
      _currentImage = file;
    });
    helper.updateCurrentPageAndCacheSiblings();
  }

  @override
  void dispose() {
    StatusBar.show();
    _animation.dispose();
    super.dispose();
  }

  final ReaderHelper helper;
  bool _preventBack = true, _reading = true;

  bool _slidable(final int offset) {
    if (_currEntry == null) return false;
    final page = _currEntry.page + offset;
    final ch = _currEntry.chapter;
    if (page >= 0 && page < ch.pageCount) return true;
    return (page < 0 ? ch.prevChpId : ch.nextChpId) != null;
  }

  void _toggleReadMode() {
    setState(() {
      _reading = !_reading;
      StatusBar.hidden = _reading;
    });
  }

  int _slideActionId = 0;
  static const _SLIDE_ACTION_RANGE = 0x00FFFFFF;

  Future<void> slidePage(final int offset) async {
    if (_direction != null || !_slidable(offset)) return;

    _slideActionId = (_slideActionId + 1) & _SLIDE_ACTION_RANGE;
    final actionId = _slideActionId;
    setState(() {
      _direction = offset > 0 ? SlideDirection.leftToRight : SlideDirection.rightToLeft;
      _nextImage = null;
      _animation.play(actionId);
    });

    _nextEntry = await helper.getSiblingEntry(offset);
    final nextImage = await _nextEntry.loadFile();
    if (!mounted) return;
    if (_direction == null || actionId != _slideActionId) return;
    setState(() {
      _nextImage = nextImage;
    });
  }

  File _currentImage, _nextImage;
  ImageEntry _currEntry, _nextEntry;
  SlideDirection _direction;

  String get status => _currEntry == null ? '...' : _currEntry.toString();
  String get timestamp => globals.formatTimeHM(DateTime.now());

  Offset _dragFrom, _dragTo;

  static final disabledColor = Colors.grey[500];

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => !_preventBack,
    child: Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: _animation.makeWidgets(
          current: _currentImage,
          next: _nextImage,
          direction: _direction,
          append: _reading ?
          [
            GestureDetector(
              onHorizontalDragStart: (details) {
                _dragFrom = details.globalPosition;
              },
              onHorizontalDragUpdate: (details) {
                _dragTo = details.globalPosition;
              },
              onHorizontalDragEnd: (_) {
                final dx = _dragTo.dx - _dragFrom.dx;
                final dy = _dragTo.dy - _dragFrom.dy;

                if (dx.abs() < dy.abs() * 3 || dx.abs() < 40.0) return;
                slidePage(dx > 0 ? 0 - 1 : 0 + 1);
              },
              onScaleStart: (details) {
                logd('onScaleStart $details');
              },
              onScaleUpdate: (details) {
                logd('onScaleUpdate $details');
              },
              onTapUp: (details) {
                final x = details.globalPosition.dx;
                if (x > globals.prevThreshold && x < globals.nextThreshold) {
                  _toggleReadMode();
                  return;
                }

                slidePage(x < globals.prevThreshold ? 0 - 1 : 0 + 1);
              },
            ),
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                color: Color.fromARGB(200, 40, 40, 40),
                child: Text(
                  '$status  $timestamp',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ] : [
            Column(
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
                        onPressed: () {
                          _preventBack = false;
                          Navigator.pop(context);
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(helper.comic.name,
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(status,
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
                        size: 32.0,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(child: GestureDetector(onTap: _toggleReadMode)),
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
                        disabled: helper.prevChapter == null,
                        disabledColor: disabledColor,
                        size: 32.0,
                        onPressed: () {
                          helper.changeCurrent(helper.prevChapter);
                          helper.pageIndex = 0;
                          _open();
                        },
                      ),
                      TouchableIcon(
                        Icons.arrow_left,
                        color: Colors.white,
                        disabled: !_slidable(0 - 1),
                        disabledColor: disabledColor,
                        size: 32.0,
                        onPressed: () {
                          slidePage(0 - 1);
                        },
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(5.0),
                          child: helper.current == null ? Container() :
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  '${helper.pageIndex + 1} / ${helper.current.pageCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                                Slider(
                                  divisions: helper.current.pageCount - 1,
                                  min: 1.0,
                                  max: (helper.current.pageCount).toDouble(),
                                  value: (helper.pageIndex + 1).toDouble(),
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white,
                                  onChangeEnd: (value) {
                                    _nextImage = null;
                                    _reloadImages();
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      helper.pageIndex = value.toInt() - 1;
                                    });
                                  },
                                ),
                              ]
                            )
                        ),
                      ),
                      TouchableIcon(
                        Icons.arrow_right,
                        color: Colors.white,
                        disabled: !_slidable(0 + 1),
                        disabledColor: disabledColor,
                        size: 32.0,
                        onPressed: () {
                          slidePage(0 + 1);
                        },
                      ),
                      TouchableIcon(
                        Icons.fast_forward,
                        color: Colors.white,
                        disabled: helper.nextChapter == null,
                        disabledColor: disabledColor,
                        size: 32.0,
                        onPressed: () {
                          helper.changeCurrent(helper.nextChapter);
                          helper.pageIndex = 0;
                          _open();
                        },
                      ),
                    ],
                  )
                ),
              ],
            ),
          ]
        ),
      ),
    )
  );
}
