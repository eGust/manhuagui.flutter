import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/website_meta_data.dart';

class Store {
  SharedPreferences storage;
  WebsiteMetaData metaData;

  static const _META_DATA_KEY = 'websiteMetaData';

  Future<void> _refresh() async {
    metaData = await WebsiteMetaData().refresh();
    storage.setString(_META_DATA_KEY, jsonEncode(metaData));
  }

  Future<void> initialize() async {
    storage = await SharedPreferences.getInstance();
    // final metaJson = storage.getString(_META_DATA_KEY);
    await _refresh();
    // if (metaJson != null) {
    //   metaData = WebsiteMetaData.fromJson(jsonDecode(metaJson));
    // } else {
    //   await _refresh();
    // }
  }
}

final Store globals = Store();
