import 'dart:async';
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../components/reader/fast_status.dart';
import '../components/reader/info_panel.dart';
import '../components/reader/action_panel.dart';
import '../components/reader/image_resolver.dart';
import '../components/reader/image_delegate.dart';
import '../components/reader/image_holder.dart';

class ReaderScreen extends StatefulWidget {
  ReaderScreen(final this._pool);

  final ImagePool _pool;

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  ImagePool get pool => widget._pool;

  ComicPage get currentPage => pool.currentPage;
  Chapter get currentChapter => currentPage?.chapter;
  ComicBook get currentBook => currentChapter?.book;

  @override
  void initState() {
    super.initState();
    StatusBar.hide();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0),
    );
    pool.subscribe(onCurrentChanged);
  }

  ImageResolver _current;
  ImageDelegate get _delegate => _current?.imageDelegate;
  ActionEventCenter get _events => _delegate?.eventCenter;

  void onCurrentChanged() {
    if (currentPage == null) return;

    final key = currentPage.key;
    if (_current?.key == key) return;

    _current = ImageResolver(key, pool.currentImage);
    subscribeUpdate(_current);
  }

  void onSlide(int direction) async {
    _imgOld = _current;
    final page = direction < 0 ? currentPage.nextPage : currentPage.prevPage;
    if (page == null || !mounted) return;

    final ComicPage p = page is Future<ComicPage> ? await page : page;
    _imgNew = ImageResolver(p.key, pool.imageOf(page));
    subscribeUpdate(_imgNew);

    Offset oldTo, newFrom;
    if (direction < 0) {
      oldTo = const Offset(-1.0, 0.0);
      newFrom = const Offset(1.0, 0.0);
    } else {
      oldTo = const Offset(1.0, 0.0);
      newFrom = const Offset(-1.0, 0.0);
    }

    _oldOut = Tween(begin: Offset.zero, end: oldTo).animate(_curve);
    _newIn = Tween(begin: newFrom, end: Offset.zero).animate(_curve);

    setState(() {
      _sliding = true;
    });

    _controller
      ..reset()
      ..forward().whenComplete(() {
        setState(() {
          _imgOld = null;
          _imgNew = null;
          _sliding = false;
          pool.currentPage = p;
        });
      });
  }

  bool isSlidable(final int offset) {
    final page = pool.currentPage;
    if (page == null) return false;
    final p = offset < 0 ? page.nextPage : page.prevPage;
    return p != null;
  }

  static const SIBLING_INDEXES = [1, -1, 2, 3, -2, 4, 5];

  void cacheSiblings(String key, int siblingIndex) async {
    if (siblingIndex >= SIBLING_INDEXES.length) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || currentPage?.key != key) return;

    for (var i = siblingIndex; i < SIBLING_INDEXES.length; i += 1) {
      final nextImage = pool.siblingImage(SIBLING_INDEXES[i]);
      if (nextImage is Image) continue;

      await nextImage;
      cacheSiblings(key, i + 1);
      break;
    }
  }

  void subscribeUpdate(ImageResolver resolver) {
    if (resolver.isResolved) {
      final delegate = resolver.imageDelegate;
      if (delegate == null || !mounted) return;

      setState(() {
        final w = delegate.scaleWidth;
        final h = delegate.scaleHeight;
        if (w > h) {
          delegate.fitScaleRight();
          delegate.type = ImageType.horizon;
        } else if (h > w * 2) {
          delegate.fitScaleTop();
          delegate.type = ImageType.vertical;
        } else {
          delegate.type = ImageType.normal;
        }
      });

      final key = resolver.key;
      if (!mounted || currentPage.key != key) return;

      currentChapter.nextByGroup?.load();
      cacheSiblings(key, 0);
      updateHistory();
      return;
    }

    resolver.resolve().then((_) {
      subscribeUpdate(resolver);
    });
  }

  void updateHistory() {
    final book = currentBook;
    if (book == null) return;
    final chapter = currentChapter;
    final page = currentPage.pageIndex;

    book.lastChapterId = chapter.chapterId;
    book.lastChapterPage = page;
    book.lastReadChapter = chapter.title;

    if (chapter.chapterId >= (book.maxChapterId ?? 0)) {
      book.maxChapterId = chapter.chapterId;
      book.maxChapterPage = page;
      book.maxReadChapter = chapter.title;
    }

    book.updateHistory();
    chapter.updateHistory(page);
  }

  AnimationController _controller;
  CurvedAnimation _curve;
  Animation _oldOut, _newIn;

  ImageResolver _imgOld, _imgNew;
  bool _sliding = false, _preventBack = true, _reading = true;

  void _toggleReadMode() {
    setState(() {
      _reading = !_reading;
      StatusBar.hidden = _reading;
    });
  }

  String get status => _delegate == null ? '...' : pool.currentPage.toString();
  String get time => globals.formatTimeHM(DateTime.now());

  void _onTap(Offset position) {
    final x = position.dx;
    if (x > globals.prevThreshold && x < globals.nextThreshold) {
      _toggleReadMode();
      return;
    }

    if (_events?.onTap != null) {
      _events.onTap(position);
      return;
    }

    onSlide(x < globals.prevThreshold ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async => !_preventBack,
      child: Container(
        color: Colors.black,
        child: Stack(
            fit: StackFit.expand,
            children: (_sliding
                ? [
                    SlideTransition(
                      position: _oldOut,
                      child: ImageHolder(resolver: _imgOld),
                    ),
                    SlideTransition(
                      position: _newIn,
                      child: ImageHolder(resolver: _imgNew),
                    ),
                  ]
                : [
                    ImageHolder(
                      resolver: _current,
                      onSlide: onSlide,
                    ),
                  ])
              ..addAll(_reading
                  ? [
                      ActionPanel(
                        onGestureStart: (position) {
                          _delegate?.gestureStart(position);
                        },
                        onGestureUpdate: (position, scale) {
                          _events?.onGestureUpdate?.call(position, scale);
                        },
                        onGestureEnd: (delta, velocity) {
                          _events?.onGestureEnd?.call(delta, velocity);
                        },
                        onDoubleTap: () {
                          _events?.onDoubleTap?.call();
                        },
                        onTap: _onTap,
                      ),
                      FastStatus('$status  $time'),
                    ]
                  : [
                      InfoPanel(
                        onGoBack: () {
                          _preventBack = false;
                          Navigator.pop(context);
                        },
                        onPageChanged: (final int pageIndex) {
                          pool.setCurrent(pageIndex: pageIndex);
                        },
                        onDownload: () {},
                        onReadModeAction: _toggleReadMode,
                        onChapterChanged: (final int direction) {
                          pool.currentPage = direction < 0
                              ? currentChapter.prevByGroup?.page(0)
                              : currentChapter.nextByGroup?.page(0);
                        },
                        title: pool.currentPage.chapter.book.name,
                        subTitle: status,
                        invalidPrevPage: !isSlidable(0 - 1),
                        invalidNextPage: !isSlidable(0 + 1),
                        invalidPrevChapter:
                            pool.currentPage.chapter.prevByGroup == null,
                        invalidNextChapter:
                            pool.currentPage.chapter.nextByGroup == null,
                        pageIndex: currentPage?.pageIndex,
                        pageCount: currentChapter?.pageCount,
                        onSlidePage: onSlide,
                      )
                    ])),
      ));

  @override
  void dispose() {
    StatusBar.show();
    _controller.dispose();
    super.dispose();
  }
}
