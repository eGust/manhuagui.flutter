import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/website_meta_data.dart';
import 'models/user.dart';
import 'api/remote_db.dart';

class Store {
  SharedPreferences storage;
  WebsiteMetaData metaData;
  User user;
  RemoteDb db;
  Set<int> favorateBookIdSet = Set();

  static const _META_DATA_KEY = 'websiteMetaData';
  static const _USER_KEY = 'user';
  static const _FAVORATES_KEY = 'favorates';

  Future<void> _refresh() async {
    metaData = await WebsiteMetaData().refresh();
  }

  void save() {
    storage.setString(_META_DATA_KEY, jsonEncode(metaData));
    storage.setString(_FAVORATES_KEY, jsonEncode(favorateBookIdSet.toList()));
    storage.setString(_USER_KEY, jsonEncode(user));
  }

  Future<void> _loadStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  Map<String, dynamic> _loadStorageJson(String key) {
    final json = storage.getString(key);
    return json == null ? null : jsonDecode(json);
  }

  Future<void> _loadMetaData() async {
    final metaJson = _loadStorageJson(_META_DATA_KEY);
    if (metaJson != null) {
      metaData = WebsiteMetaData.fromJson(metaJson);
    } else {
      await _refresh();
    }
  }

  Future<void> _loadUser() async {
    user = User.fromJson(_loadStorageJson(_USER_KEY) ?? {});
    await user.initialize();
  }

  Future<void> _loadDb() async {
    db = await RemoteDb.create();
  }

  Future<void> initialize() async {
    await _loadStorage();
    await Future.wait([
      _loadDb(),
      _loadMetaData(),
      _loadUser(),
    ]);

    // favorates
    favorateBookIdSet = Set.from(_loadStorageJson(_FAVORATES_KEY) ?? []);
  }
}

final Store globals = Store();
