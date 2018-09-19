import 'dart:async';
import 'dart:io';

import './comic_book.dart';
import './chapter.dart';
import '../store.dart';

class ReaderHelper {
  ReaderHelper(this.comic, this.current, { this.pageIndex });

  final ComicBook comic;
  Chapter current;
  int pageIndex;
  bool ready = false;

  static const IMAGE_HEADERS = const { 'Referer': 'https://m.manhuagui.com' };
  static const CACHE_SIBLINGS = [0-2, 0-1, 0+1, 0+2, 0+3, 0+4];
  Map<int, Set<int>> bookCaching = {};

  Set<int> getChapterCaching(Chapter ch) {
    var s = bookCaching[ch.chapterId];
    if (s == null) {
      s = Set();
      bookCaching[ch.chapterId] = s;
    }
    return s;
  }

  static Future<File> cacheImageFile(Chapter chapter, int pageIndex) =>
    globals.cache.getFile(chapter.getPageUrl(pageIndex), headers: IMAGE_HEADERS);

  void _cacheSibling(int index, Chapter chapter) {
    if (chapter == null) return;
    if (index < 0) {
      _cacheSync(index, comic.groupPrevOf(current));
      return;
    }
    if (index >= chapter.pageCount) {
      _cacheSync(index - chapter.pageCount, comic.groupNextOf(current));
      return;
    }

    final s = getChapterCaching(chapter);
    if (s.contains(index)) return;
    s.add(index);
    cacheImageFile(chapter, index);
  }

  Future<void> _cacheSync(int offset, Chapter chapter) async {
    if (chapter == null) return;
    await chapter.load();
    _cacheSibling(offset < 0 ? chapter.pageCount + offset : offset, chapter);
  }

  Future<File> fetchCurrentImageFile() {
    final r = cacheImageFile(current, pageIndex);
    getChapterCaching(current).add(pageIndex);
    current.updateHistory(pageIndex);
    CACHE_SIBLINGS.forEach((offset) => _cacheSibling(pageIndex + offset, current));
    return r;
  }

  Future<void> openChapter() async {
    ready = false;
    await Future.wait([
      current.load(),
      comic.updateHistory(lastChapterId: current.chapterId),
    ]);

    pageIndex ??= 0;
    if (pageIndex < 0) {
      pageIndex = current.pageCount + pageIndex;
    }
    ready = true;

    comic.groupPrevOf(current)?.load();
    comic.groupNextOf(current)?.load();
    comic.prevOf(current)?.load();
    comic.nextOf(current)?.load();
  }
}
