import 'dart:async';

import 'package:flutter/widgets.dart';

import '../store.dart';
import 'chapter.dart';

class ImagePool {
  ImagePool({this.poolSize = 10, ComicPage page}) : _current = page;

  static ImagePool openChapter({
    @required Chapter chapter,
    int poolSize = 10,
    int startPage = 0,
  }) {
    final page = chapter.page(startPage);
    final pool = ImagePool(
      poolSize: poolSize,
      page: page is ComicPage ? page : null,
    );
    pool.currentPage = page;
    return pool;
  }

  FutureOr<ComicPage> _current;
  VoidCallback onPageChanged;

  ComicPage get currentPage => _current is ComicPage ? _current : null;
  void _setCurrentPage(FutureOr<ComicPage> page) {
    _current = page;
    if (page is Future<ComicPage>) {
      page.then(_setCurrentPage);
    } else {
      onPageChanged?.call();
    }
  }

  set currentPage(FutureOr<ComicPage> page) {
    _setCurrentPage(page);
  }

  void setCurrent({Chapter chapter, @required pageIndex}) {
    chapter ??= currentPage?.chapter;
    _setCurrentPage(chapter?.page(pageIndex));
  }

  void subscribe(VoidCallback onChange) {
    onPageChanged = onChange;
    if (currentPage != null) onChange?.call();
  }

  final int poolSize;
  final _pool = <String, _ImagePageCacheItem>{};

  FutureOr<Image> imageOf(ComicPage page) {
    page ??= currentPage;
    if (page == null) return null;

    final cached = _pool[page.key];
    if (cached != null) {
      cached.touch();
      return cached.image;
    }

    final imagePage = _ImagePageCacheItem._(page);
    final r = imagePage._load();

    _pool[imagePage.key] = imagePage;
    if (_pool.length > poolSize) {
      final images = _pool.values.toList();
      var min = images[0];
      images.skip(1).forEach((img) {
        if (img._timestamp < min._timestamp) min = img;
      });

      min = _pool.remove(min.key);
      min.image = null;
    }
    return r;
  }

  FutureOr<Image> get currentImage => imageOf(currentPage);

  FutureOr<ComicPage> siblingOf(ComicPage page, int offset) {
    if (offset == 0) return page;

    final neighbor = offset < 0 ? -1 : 1;
    final p = page.neighbor(neighbor);
    if (p is ComicPage) return siblingOf(p, offset - neighbor);
    if (p is Future<ComicPage>) {
      return p.then((page) => siblingOf(page, offset - neighbor));
    }
    return null;
  }

  FutureOr<ComicPage> siblingPage(int offset) => siblingOf(currentPage, offset);

  FutureOr<Image> siblingImage(int offset) {
    final page = siblingPage(offset);
    if (page is ComicPage) return imageOf(page);
    if (page is Future<ComicPage>) {
      return page.then((p) => imageOf(p));
    }
    return null;
  }
}

class ComicPage {
  ComicPage({
    @required this.chapter,
    this.pageIndex = 0,
  });

  final Chapter chapter;
  final int pageIndex;

  String get key => '${chapter.key}/p$pageIndex.webp';

  FutureOr<ComicPage> get prevPage => chapter.prevPageOf(pageIndex);
  FutureOr<ComicPage> get nextPage => chapter.nextPageOf(pageIndex);

  FutureOr<ComicPage> neighbor(int offset) {
    return offset < 0
        ? chapter.prevPageOf(pageIndex)
        : chapter.nextPageOf(pageIndex);
  }

  static const REFERER_BASE = 'https://m.manhuagui.com';

  Future<Image> _getCachedImage() async {
    final file = await globals.cache.getFile(
      chapter.getPageUrl(pageIndex),
      headers: {'Referer': '$REFERER_BASE/comic/${chapter.key}.html'},
      key: key,
    );
    return Image.file(file);
  }

  Future<Image> get image => _getCachedImage();

  @override
  String toString() =>
      '${chapter.title}  ${pageIndex + 1} / ${chapter.pageCount}';
}

class _ImagePageCacheItem {
  _ImagePageCacheItem._(this.page) {
    touch();
  }

  final ComicPage page;
  String get key => page.key;
  int _timestamp;
  FutureOr<Image> image;

  void touch() {
    _timestamp = DateTime.now().microsecondsSinceEpoch;
  }

  FutureOr<Image> _load() async {
    if (image != null) return image;

    image = page.image;
    image = await image;
    return image;
  }
}
