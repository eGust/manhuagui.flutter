import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';

import 'models.dart';
import 'api.dart';
import 'config.dart';

class LRUCachePolicy extends LessRecentlyUsedPolicy {
  LRUCachePolicy(final int maxCount) : super(maxCount: maxCount);

  @override
  String generateFilename({final String key, final String url}) => key;
}

class Store {
  SharedPreferences storage;
  WebsiteMetaData metaData;
  User user;
  RemoteDb remoteDb;
  Database localDb;
  CacheStore cache;
  Set<int> favoriteBookIdSet = Set();
  Set<String> blacklistSet = Set();
  static final _df = DateFormat('yyyy-MM-dd');
  static final _tf = DateFormat('HH:mm');

  Size screenSize;
  double statusBarHeight;
  double prevThreshold;
  double nextThreshold;
  bool get smallScreen => screenSize.shortestSide < 700;

  String formatDate(DateTime date) => date == null ? '--' : _df.format(date);
  String formatTimeHM(DateTime time) => time == null ? '--' : _tf.format(time);

  String _tempPath;
  String get tempPath => _tempPath;

  static const PREF_META_DATA = 'websiteMetaData';
  static const PREF_USER = 'user';
  static const PREF_FAVORITES = 'favorites';
  static const PREF_BLACKLIST = 'blacklist';

  Future<void> refreshMetaData() async {
    metaData = await WebsiteMetaData().refresh();
  }

  Future<void> save() => Future.wait([
        storage.setString(PREF_META_DATA, jsonEncode(metaData)),
        storage.setString(
            PREF_FAVORITES, jsonEncode(favoriteBookIdSet.toList())),
        storage.setString(PREF_BLACKLIST, jsonEncode(blacklistSet.toList())),
        storage.setString(PREF_USER, jsonEncode(user)),
      ]);

  static bool get isDebug => Logger.isDebug;

  Future<void> _loadStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  dynamic _loadStorageJson(String key) {
    final json = storage.getString(key);
    return json == null ? null : jsonDecode(json);
  }

  Future<void> _loadMetaData() async {
    final metaJson = _loadStorageJson(PREF_META_DATA);
    if (metaJson != null) {
      metaData = WebsiteMetaData.fromJson(metaJson);
    } else {
      await refreshMetaData();
    }
  }

  Future<void> _loadUser() async {
    user = User.fromJson(_loadStorageJson(PREF_USER) ?? {});
    await user.initialize();
  }

  Future<void> _openRemoteDb() async {
    remoteDb = null;
    remoteDb = await RemoteDb.create(uri: MONGO_DB_URL);
  }

  Future<void> _openLocalDb() async {
    localDb = await LocalDb.connect();
  }

  Future<void> _openCache() async {
    CacheStore.setPolicy(LRUCachePolicy(2000));
    cache = await CacheStore.getInstance();
  }

  Future<void> _cleanLegacy() async {
    final dir = Directory('${_tempPath}cache');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> cleanCacheManager() async {
    return Future.wait([
      _cleanLegacy(),
      storage.remove('lib_cached_image_data'),
      storage.remove('lib_cached_image_data_last_clean'),
      cache.clearAll(),
    ]);
  }

  Future<void> initialize() async {
    StatusBar.init();
    _tempPath = (await getTemporaryDirectory()).path;
    logd('tmpPath = $_tempPath');

    await _loadStorage();
    await Future.wait([
      _openRemoteDb(),
      _openLocalDb(),
      _openCache(),
      _loadMetaData(),
    ]);
    await reload();
  }

  Future<bool> reload() async {
    await _loadUser();
    // sets
    favoriteBookIdSet = Set.from(_loadStorageJson(PREF_FAVORITES) ?? []);
    // blacklistSet = Set.from(['danmei']);
    blacklistSet = Set.from(_loadStorageJson(PREF_BLACKLIST) ?? ['danmei']);
    return true;
  }

  Future<void> updateCovers(final Map<int, ComicCover> coverMap) async {
    final books = await globals.localDb.rawQuery('''
    SELECT books.book_id
      , cover_json, last_chapter_id, max_chapter_id
      , last_chapter.title last_chapter_title, last_chapter.read_page last_chapter_page
      , max_chapter.title max_chapter_title, max_chapter.read_page max_chapter_page
    FROM books
    LEFT JOIN chapters last_chapter ON last_chapter.chapter_id = last_chapter_id
    LEFT JOIN chapters max_chapter ON max_chapter.chapter_id = max_chapter_id
    WHERE books.book_id IN (${coverMap.keys.join(',')})
    ''');
    books.forEach((book) {
      final cover = coverMap.remove(book['book_id']);
      cover.loadJson(jsonDecode(book['cover_json']));
      cover.lastChapterId = book['last_chapter_id'];
      cover.lastChapterPage = book['last_chapter_page'];
      cover.lastReadChapter = book['last_chapter_title'];
      cover.maxChapterId = book['max_chapter_id'];
      cover.maxChapterPage = book['max_chapter_page'];
      cover.maxReadChapter = book['max_chapter_title'];
    });

    if (remoteDb != null) {
      await remoteDb.updateCovers(coverMap.values.toList());
    }
  }

  Future<void> updateChapterProgresses(List<ComicCover> comics) async {
    if (comics.isEmpty) return;

    final coverMap = Map.fromEntries(comics.map((c) => MapEntry(c.bookId, c)));
    final rows = await globals.localDb.rawQuery('''
    SELECT books.book_id
      , last_chapter_id, max_chapter_id
      , last_chapter.title last_chapter_title, last_chapter.read_page last_chapter_page
      , max_chapter.title max_chapter_title, max_chapter.read_page max_chapter_page
    FROM books
    INNER JOIN chapters last_chapter ON last_chapter.chapter_id = last_chapter_id
    LEFT JOIN chapters max_chapter ON max_chapter.chapter_id = max_chapter_id
    WHERE books.book_id IN (${coverMap.keys.join(',')})
    ''');

    rows.forEach((row) {
      final cover = coverMap[row['book_id']];
      cover.lastChapterId = row['last_chapter_id'];
      cover.lastChapterPage = row['last_chapter_page'];
      cover.lastReadChapter = row['last_chapter_title'];
      cover.maxChapterId = row['max_chapter_id'];
      cover.maxChapterPage = row['max_chapter_page'];
      cover.maxReadChapter = row['max_chapter_title'];
    });
  }

  Future<void> syncFavorites() async {
    final remote = await user.getAllFavorites();
    final toSync = favoriteBookIdSet.difference(remote).toList();

    favoriteBookIdSet.addAll(remote);
    save();
    for (var bookId in toSync) {
      await Future.delayed(const Duration(milliseconds: 2500), () {});
      if (!user.isLogin) return;
      await user.addFavorite(bookId);
    }
  }

  Future<void> toggleFavorite(final ComicCover comic) async {
    final bookId = comic.bookId;
    if (comic.isFavorite) {
      favoriteBookIdSet.remove(bookId);
      await user.removeFavorite(bookId);
    } else {
      favoriteBookIdSet.add(bookId);
      await user.addFavorite(bookId);
    }
    save();
  }

  Future<void> pause() async {
    save();
  }

  Future<void> resume() async {
    _openRemoteDb();
    _openLocalDb();
  }
}

final Store globals = Store();
