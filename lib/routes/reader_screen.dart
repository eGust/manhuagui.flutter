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

    helper.updateCurrentPage();
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
                logd('onHorizontalDragStart ${details.globalPosition}');
              },
              onHorizontalDragEnd: (details) {
                logd('onHorizontalDragEnd ${details.velocity} ${details.primaryVelocity}');
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
                  '$status $timestamp',
                  style: TextStyle(
                    color: Colors.white
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
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      TouchableIcon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 32.0,
                        onPressed: () {
                          _preventBack = false;
                          Navigator.pop(context);
                        },
                      ),
                      Container(),
                    ],
                  ),
                ),
                Expanded(child: GestureDetector(onTap: _toggleReadMode)),
                Container(
                  color: Color.fromARGB(200, 40, 40, 40),
                  height: 100.0,
                ),
              ],
            ),
          ]
        ),
      ),
    )
  );
}
