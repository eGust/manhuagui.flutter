import 'dart:async';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

import '../config.dart';

class RemoteDb {
  RemoteDb(String url) {
    _db = Db(url);
  }

  Db _db;
  Db get db => _db;

  Future<void> initialize() async {
    await _db.open();
    dcComic = db.collection('comics');
  }

  Future<List<Map<String, dynamic>>> queryByIds(List<int> bookIds) async {
    final list = await dcComic.find(where.oneFrom('id', bookIds)).toList();
    return list.map((comic) {
      final Map<String, dynamic> attrs = jsonDecode(comic['data']);
      return {
        'bookId': comic['id'],
        'categories': attrs['cs'],
        'introduction': attrs['sm'],
        'authors': (attrs['as'] as List).map((author) => {
          'authorId': author['i'],
          'name': author['n'],
        }).toList(),
      };
    }).toList();
  }

  DbCollection dcComic;

  static Future<RemoteDb> create({ String url = MONGO_DB_URL }) async {
    final r = RemoteDb(url);
    await r.initialize();
    return r;
  }
}
