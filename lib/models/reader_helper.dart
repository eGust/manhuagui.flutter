import 'dart:async';
import 'dart:io';

import './comic_book.dart';
import './chapter.dart';
import '../store.dart';

class ImageEntry {
  ImageEntry(final this.chapter, final this.page);
  final Chapter chapter;
  final int page;

  @override
  String toString() => '${chapter.title}  ${page+1} / ${chapter.pageCount}';

  Future<File> loadFile() => ReaderHelper.getCachedImageFile(chapter, page);
}

class ReaderHelper {
  ReaderHelper(final this.comic, final this._current, { final this.pageIndex });

  final ComicBook comic;
  Chapter _current;
  int pageIndex;
  bool ready = false;

  Chapter get current => _current;
  set current(final Chapter val) {
    final diff = val.chapterId != val.chapterId;
    _current = val;
    if (diff) {
      updateCurrentChapter();
    }
  }

  Chapter get prevChapter => comic.groupPrevOf(current);
  Chapter get nextChapter => comic.groupNextOf(current);

  Future<void> updateCurrentChapter({ bool updateCover = false }) async {
    final loading = current.load();
    comic.updateHistory(lastChapterId: current.chapterId, updateCover: updateCover);
    await loading;
    prevChapter?.load();
    nextChapter?.load();
  }

  void changeCurrent(final Chapter chapter) {
    _current = chapter;
  }

  static const IMAGE_HEADERS = const { 'Referer': 'https://m.manhuagui.com' };
  static const CACHE_SIBLINGS = [0-2, 0-1, 0+1, 0+2, 0+3, 0+4];
  Map<int, Map<int, ImageEntry>> imageCache = {};

  ImageEntry getCachedEntry(final Chapter chapter, final int page) {
    if (!ready) return null;

    var cache = imageCache[chapter.chapterId];
    if (cache == null) {
      cache = {};
      imageCache[chapter.chapterId] = cache;
    }

    var r = cache[page];
    if (r == null) {
      r = ImageEntry(chapter, page);
      cache[page] = r;
    }
    return r;
  }

  static Future<File> getCachedImageFile(final Chapter chapter, final int page) =>
    globals.cache.getFile(chapter.getPageUrl(page), headers: IMAGE_HEADERS);

  Future<ImageEntry> _findImageEntry(final Chapter chapter, final int index) async {
    if (chapter == null) return null;
    if (index >= 0 && index < chapter.pageCount) return getCachedEntry(chapter, index);

    final next = index < 0 ? comic.groupPrevOf(chapter) : comic.groupNextOf(chapter);
    if (next == null) return null;
    await next.load();
    return _findImageEntry(next, index < 0 ? index + next.pageCount : index - chapter.pageCount);
  }

  ImageEntry get currentEntry
    => ready ? getCachedEntry(current, pageIndex) : null;

  Future<ImageEntry> getSiblingEntry(final int offset)
    => ready ? _findImageEntry(current, pageIndex + offset) : null;

  void updateCurrentPageAndCacheSiblings() {
    current.updateHistory(pageIndex);
    CACHE_SIBLINGS.forEach(_cacheSiblingImageFile);
  }

  void _cacheSiblingImageFile(final int offset) async {
    (await getSiblingEntry(offset))?.loadFile();
  }

  Future<void> openChapter() async {
    ready = false;
    await updateCurrentChapter(updateCover: !comic.isFavorite);

    pageIndex ??= 0;
    if (pageIndex < 0) {
      pageIndex = current.pageCount + pageIndex;
    }
    ready = true;
  }
}
