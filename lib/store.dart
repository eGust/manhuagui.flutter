import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'api/remote_db.dart';
import './config.dart';

class Store {
  SharedPreferences storage;
  WebsiteMetaData metaData;
  User user;
  RemoteDb remoteDb;
  Database localDb;
  CacheManager cache;
  Set<int> favorateBookIdSet = Set();
  Set<String> blacklistSet = Set();
  static final DateFormat _df = DateFormat('yyyy-MM-dd');
  static final DateFormat _tf = DateFormat('HH:mm');
  Size screenSize;
  double prevThreshold, nextThreshold;

  String formatDate(DateTime date) => date == null ? '--' : _df.format(date);

  String formatTimeHM(DateTime time) => time == null ? '--' : _tf.format(time);

  static const _META_DATA_KEY = 'websiteMetaData';
  static const _USER_KEY = 'user';
  static const _FAVORATES_KEY = 'favorates';
  static const _BLACKLIST = 'blacklist';

  Future<void> refreshMetaData() async {
    metaData = await WebsiteMetaData().refresh();
  }

  void save() {
    storage.setString(_META_DATA_KEY, jsonEncode(metaData));
    storage.setString(_FAVORATES_KEY, jsonEncode(favorateBookIdSet.toList()));
    storage.setString(_BLACKLIST, jsonEncode(blacklistSet.toList()));
    storage.setString(_USER_KEY, jsonEncode(user));
  }

  Future<void> _loadStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  dynamic _loadStorageJson(String key) {
    final json = storage.getString(key);
    return json == null ? null : jsonDecode(json);
  }

  Future<void> _loadMetaData() async {
    final metaJson = _loadStorageJson(_META_DATA_KEY);
    if (metaJson != null) {
      metaData = WebsiteMetaData.fromJson(metaJson);
    } else {
      await refreshMetaData();
    }
  }

  Future<void> _loadUser() async {
    user = User.fromJson(_loadStorageJson(_USER_KEY) ?? {});
    await user.initialize();
  }

  Future<void> _openRemoteDb() async {
    remoteDb = await RemoteDb.create(uri: MONGO_DB_URL);
  }

  Future<void> _openLocalDb() async {
    localDb = await LocalDb.connect();
  }

  Future<void> _openCache() async {
    CacheManager.maxNrOfCacheObjects = 9999;
    CacheManager.inBetweenCleans = const Duration(minutes: 5);
    CacheManager.maxAgeCacheObject = const Duration(minutes: 10);
    cache = await CacheManager.getInstance();
  }

  Future<void> initialize() async {
    await _loadStorage();
    await Future.wait([
      _openRemoteDb(),
      _openLocalDb(),
      _openCache(),
      _loadMetaData(),
      _loadUser(),
    ]);

    // sets
    favorateBookIdSet = Set.from(_loadStorageJson(_FAVORATES_KEY) ?? []);
    // blacklistSet = Set.from(['danmei']);
    blacklistSet = Set.from(_loadStorageJson(_BLACKLIST) ?? []);
  }

  Future<void> updateCovers(List<ComicCover> covers) async {
    final updates = <Future>[
      // TODO: load cover history from local storage
    ];
    if (remoteDb != null) updates.add(remoteDb.updateCovers(covers));
    if (updates.isEmpty) return;
    await Future.wait(updates);
  }
}

final Store globals = Store();
