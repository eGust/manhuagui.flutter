import 'dart:async';
import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart';

import '../models/comic_cover.dart';
import '../models/author.dart';

class RemoteDb {
  RemoteDb(String uri) {
    _db = Db(uri);
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
        'authors': (attrs['as'] as List)
            .map((author) => {
                  'authorId': author['i'],
                  'name': author['n'],
                })
            .toList(),
      };
    }).toList();
  }

  Future<void> updateCovers(List<ComicCover> covers) async {
    final bookMap = Map.fromEntries(covers.map((c) => MapEntry(c.bookId, c)));
    final list =
        await dcComic.find(where.oneFrom('id', bookMap.keys.toList())).toList();
    list.forEach((comic) {
      final Map<String, dynamic> attrs = jsonDecode(comic['data']);
      final cover = bookMap[comic['id']];
      final tags = attrs['cs'] as Map;
      cover.tags = List.from(tags.values);
      cover.tagSet = Set.from(tags.keys);
      cover.shortIntro = attrs['sm'];
      cover.restricted = attrs['ad'] == 1;
      cover.authors = (attrs['as'] as List)
          .map((author) => AuthorLink(author['i'], author['n']))
          .toList();
    });
  }

  DbCollection dcComic;

  static Future<RemoteDb> create({String uri}) async {
    if (uri == null) return null;
    final r = RemoteDb(uri);
    await r.initialize();
    return r;
  }
}
