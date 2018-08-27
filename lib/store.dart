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
  Set<int> favorates = Set();

  static const _META_DATA_KEY = 'websiteMetaData';
  static const _COOKIES_KEY = 'cookies';
  static const _FAVORATES_KEY = 'favorates';

  Future<void> _refresh() async {
    metaData = await WebsiteMetaData().refresh();
  }

  void save() {
    storage.setString(_META_DATA_KEY, jsonEncode(metaData));
    storage.setString(_FAVORATES_KEY, jsonEncode(favorates.toList()));
    storage.setString(_COOKIES_KEY, user.cookie);
  }

  Future<void> _loadStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  Future<void> _loadMetaData() async {
    final metaJson = storage.getString(_META_DATA_KEY);
    if (metaJson != null) {
      metaData = WebsiteMetaData.fromJson(jsonDecode(metaJson));
    } else {
      await _refresh();
    }
  }

  Future<void> _loadUser() async {
    user = await User.initialize(cookie: storage.getString(_COOKIES_KEY));
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
    final favorateIds = jsonDecode(storage.getString(_FAVORATES_KEY));
    favorates = Set.from(List<int>.from(favorateIds));
  }
}

final Store globals = Store();
