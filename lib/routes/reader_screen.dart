import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../components/reader/animation_helper.dart';
import '../components/reader/fast_status.dart';
import '../components/reader/info_panel.dart';
import '../components/reader/read_action_panel.dart';

class ReaderScreen extends StatefulWidget {
  ReaderScreen(final this.helper);

  final ReaderHelper helper;

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  _ReaderScreenState() {
    StatusBar.hide();
    AnimationHelper.circleSize = globals.screenSize.width / 4;
    AnimationHelper.strokeWidth = 8.0;
    _animation = AnimationHelper(this, _onAnimationFinished);
  }

  ReaderHelper get helper => widget.helper;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    StatusBar.show();
    _animation.dispose();
    super.dispose();
  }

  AnimationHelper _animation;
  File _currentImage, _nextImage;
  ImageEntry _currEntry, _nextEntry;
  SlideDirection _direction;
  FocusNode _readNode = FocusNode();

  int _slideActionId = 0;
  static const _SLIDE_ACTION_RANGE = 0x00FFFFFF;

  bool _slidable(final int offset) {
    if (_currEntry == null) return false;
    final page = _currEntry.page + offset;
    final ch = _currEntry.chapter;
    if (page >= 0 && page < ch.pageCount) return true;
    return (page < 0 ? ch.prevChpId : ch.nextChpId) != null;
  }

  Future<void> _onReadModeAction({final int offset}) async {
    if (offset == null) {
      _toggleReadMode();
      return;
    }
    if (_direction != null || !_slidable(offset)) return;

    _slideActionId = (_slideActionId + 1) & _SLIDE_ACTION_RANGE;
    final actionId = _slideActionId;
    setState(() {
      _direction =
          offset > 0 ? SlideDirection.leftToRight : SlideDirection.rightToLeft;
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

  void _onAnimationFinished(final int actionId) async {
    if (!mounted || actionId != _slideActionId) return;
    var next = _nextEntry;
    final direction = _direction;

    if (next == null && direction != null) {
      next = await helper.getSiblingEntry(
          direction == SlideDirection.rightToLeft ? 0 - 1 : 0 + 1);
      if (!mounted || actionId != _slideActionId) return;
    }

    if (next != null) {
      helper.current = next.chapter;
      helper.pageIndex = next.page;
    }

    _reloadImages();
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

  bool _preventBack = true, _reading = true;
  void _toggleReadMode() {
    setState(() {
      _reading = !_reading;
      StatusBar.hidden = _reading;
    });
  }

  _buildChild() {
    FocusScope.of(context).requestFocus(_readNode);

    return Container(
      color: Colors.black,
      child: RawKeyboardListener(
          focusNode: _readNode,
          onKey: (key) {
            if (key.runtimeType.toString() == 'RawKeyDownEvent') {
              RawKeyEventDataAndroid data = key.data as RawKeyEventDataAndroid;
              switch (data.keyCode) {
                case 4:
                  // KEYCODE_BACK
                  break;
                case 24:
                  // KEYCODE_VOLUME_UP
                  _onReadModeAction(offset: -1);
                  break;
                case 25:
                  // KEYCODE_VOLUME_DOWN
                  _onReadModeAction(offset: 1);
                  break;
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: _animation.makeWidgets(
                current: _currentImage,
                next: _nextImage,
                direction: _direction,
                append: _reading
                    ? [
                        ReadActionPanel(onPressed: _onReadModeAction),
                        FastStatus('$status  $time'),
                      ]
                    : [
                        InfoPanel(
                          onGoBack: () {
                            _preventBack = false;
                            Navigator.pop(context);
                          },
                          onPageChanged: () {
                            _nextImage = null;
                            _reloadImages();
                          },
                          onDownload: () {},
                          onReadModeAction: _onReadModeAction,
                          onChapterChanged: ({final int offset}) {
                            helper.changeCurrent(offset < 0
                                ? helper.prevChapter
                                : helper.nextChapter);
                            helper.pageIndex = 0;
                            _open();
                          },
                          onPageChanging: ({final int offset}) {
                            setState(() {
                              helper.pageIndex = offset;
                            });
                          },
                          title: helper.comic.name,
                          subTitle: status,
                          invalidPrevPage: !_slidable(0 - 1),
                          invalidNextPage: !_slidable(0 + 1),
                          invalidPrevChapter: helper.prevChapter == null,
                          invalidNextChapter: helper.nextChapter == null,
                          pageIndex: helper.pageIndex,
                          pageCount: helper.current?.pageCount,
                        ),
                      ]),
          )),
    );
  }

  String get status => _currEntry == null ? '...' : _currEntry.toString();
  String get time => globals.formatTimeHM(DateTime.now());

  @override
  Widget build(BuildContext context) =>
      WillPopScope(onWillPop: () async => !_preventBack, child: _buildChild());
}
