import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:simple_auth/simple_auth.dart';
import 'package:sqflite/sqflite.dart';

import '../store.dart';
import '../api.dart';
import '../models.dart';
// import 'assets.dart';

class SyncData {
  SyncData._fromPath(String path, {this.preferences = const {}})
      : sqlDb = path == null ? null : File(path);

  final File sqlDb;
  Map<String, dynamic> preferences;

  bool get exists => sqlDb != null;

  Future<void> destroy() async {
    if (exists && await sqlDb.exists()) {
      await sqlDb.delete();
    }
  }
}

abstract class SyncManager {
  Future<SyncData> downloadRemoteData();
  Future<bool> uploadData(SyncData merged);

  static SyncData generateLocalData() =>
      SyncData._fromPath(LocalDb.filename, preferences: {
        Store.PREF_FAVORITES: globals.favoriteBookIdSet.toList(),
        Store.PREF_BLACKLIST: globals.blacklistSet.toList(),
        Store.PREF_USER: globals.user,
      });

  Future<bool> syncData() async {
    logd('downloadRemoteData');
    final remoteData = await downloadRemoteData();

    if (remoteData != null && remoteData.exists) {
      logd('mergeRemotePreferences');
      mergeRemotePreferences(remoteData);
      logd('globals.save and mergeSqlDb');
      await Future.wait([
        globals.save(),
        mergeSqlDb(remoteData),
      ]);
    }

    logd('uploadData and globals.reload');
    final result = await Future.wait([
      uploadData(generateLocalData()),
      globals.reload(),
    ]);

    remoteData?.destroy();
    return result[0];
  }

  static void mergeRemotePreferences(SyncData remoteData) {
    final remote = remoteData.preferences ?? {};
    final favorites = List<int>.from(remote[Store.PREF_FAVORITES] ?? []);
    globals.favoriteBookIdSet.addAll(favorites);
    final blacklist = List<String>.from(remote[Store.PREF_BLACKLIST] ?? []);
    globals.blacklistSet.addAll(blacklist);

    final Map<String, dynamic> user = remote[Store.PREF_USER] ?? {};
    if (user['password'] != null && !globals.user.isLogin) {
      globals.user = User.fromJson(user);
    }
  }

  static Future<void> mergeSqlDb(SyncData remoteData) async {
    if (!remoteData.exists) return;
    if (!await remoteData.sqlDb.exists()) return;
    if (await remoteData.sqlDb.length() < 512) return;

    final db = globals.localDb;
    final remoteDb = await openDatabase(remoteData.sqlDb.path);

    final books = Map.fromEntries((await db.rawQuery('SELECT * FROM books'))
        .map((b) => MapEntry<int, Map<String, dynamic>>(b['book_id'], b)));

    (await remoteDb.rawQuery('SELECT * FROM books')).forEach((rBook) async {
      final int bookId = rBook['book_id'];
      final q = 'SELECT chapter_id FROM chapters WHERE book_id = $bookId';
      final rChapters = await remoteDb.rawQuery(q);

      final book = books[bookId];
      // local book is missing
      if (book == null) {
        await db.insert('books', rBook);
        // insert all chapters
        await Future.wait(rChapters.map((ch) => db.insert('chapters', ch)));
        return;
      }

      // compare last_chapter_id and max_chapter_id
      final changes = <String, dynamic>{};
      final rChpMap = Map.fromEntries(rChapters
          .map((c) => MapEntry<int, Map<String, dynamic>>(c['chapter_id'], c)));
      final chpMap = Map.fromEntries((await db.rawQuery(q))
          .map((c) => MapEntry<int, Map<String, dynamic>>(c['chapter_id'], c)));

      final rLastChpId = rBook['last_chapter_id'];
      final lastChpId = book['last_chapter_id'];
      if (rLastChpId != null) {
        if (lastChpId == null) {
          changes['last_chapter_id'] = rLastChpId;
        } else if (rLastChpId != lastChpId) {
          final rChp = rChpMap[rLastChpId];
          final chp = chpMap[lastChpId];

          if (rChp['read_at'] ?? 0 > chp['read_at'] ?? 0) {
            changes['last_chapter_id'] = rLastChpId;
          }
        }
      }

      final rMaxChpId = rBook['max_chapter_id'];
      final maxChpId = book['max_chapter_id'];
      if (rMaxChpId != null) {
        if (maxChpId == null) {
          changes['max_chapter_id'] = rMaxChpId;
        } else if (rMaxChpId != maxChpId) {
          final rChp = rChpMap[rMaxChpId];
          final chp = chpMap[maxChpId];

          if (rChp['read_at'] ?? 0 > chp['read_at'] ?? 0) {
            changes['max_chapter_id'] = rMaxChpId;
          }
        }
      }

      // don't update if nothing changed
      if (changes.isNotEmpty) {
        await db.update('books', changes, where: 'book_id = $bookId');
      }

      // insert missing chapters
      await Future.wait(rChapters.map((rChp) async {
        final int chId = rChp['chapter_id'];
        if (!chpMap.containsKey(chId)) {
          await db.insert('chapters', rChp);
          return;
        }

        final ch = chpMap[chId];
        final int readAt = rChp['read_at'] ?? 0;
        if (ch['read_at'] ?? 0 >= readAt) return;

        final changes = {
          'read_at': readAt,
          'read_page': rChp['read_page'],
        };
        await db.update('chapters', changes, where: 'chapter_id = $chId');
      }));
    });
  }
}

class GoogleDriverSyncManager extends SyncManager {
  static const _SQL_DB = 'sqlite.db';
  static const _JSON = 'preferences.json';

  Future<SyncData> downloadRemoteData() async {
    try {
      final OAuthAccount account = await _api.authenticate();
      _token = account.token;

      logd('_ensureFolder');
      await _ensureFolder();
      logd('_fetchAllFiles');
      await _fetchAllFiles();

      final sqlFileId = _files[_SQL_DB];
      String sqlFilename;
      if (sqlFileId != null) {
        logd('downloading $_SQL_DB');
        final response = await _get('files/$sqlFileId?alt=media');
        sqlFilename = '${globals.tempPath}/google_drive/$_SQL_DB';

        final file = File(sqlFilename);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
      }
      final syncData = SyncData._fromPath(sqlFilename);

      final jsonFileId = _files[_JSON];
      if (jsonFileId != null) {
        logd('downloading $_JSON');
        syncData.preferences = await _getJson('files/$jsonFileId?alt=media');
      }
      return syncData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> uploadData(SyncData merged) async {
    final OAuthAccount account = await _api.authenticate();
    _token = account.token;
    logd('token = $_token');

    logd('_uploadFile $_SQL_DB');
    final db = await _uploadFile(_SQL_DB, localFile: merged.sqlDb);
    logd('$_SQL_DB: ${utf8.decode(db)}');

    logd('_uploadFile $_JSON');
    final json = await _uploadFile(_JSON, json: merged.preferences);
    logd('$_JSON: ${utf8.decode(json)}');
    return true;
  }

  static const _FOLDER_NAME = 'manhuagui-data';
  static const _FOLDER_MIME_TYPE = 'application/vnd.google-apps.folder';
  String _folderId;

  Future<void> _ensureFolder() async {
    if (_folderId != null) return;

    final json = await _getJson('files', queryParameters: {
      'q': [
        "name = '$_FOLDER_NAME'",
        "mimeType = '$_FOLDER_MIME_TYPE'",
        // "'appDataFolder' in parents",
      ].join(' and ')
    });

    final List files = json['files'];
    if (files.isNotEmpty) {
      _folderId = (files.first as Map<String, dynamic>)['id'];
      return;
    }

    final folder = await _postJson('files', body: {
      'name': _FOLDER_NAME,
      'mimeType': _FOLDER_MIME_TYPE,
      // 'contentHints.thumbnail.image': ICON_DATA_128_BASE64, // 128 * 128
      // 'contentHints.thumbnail.mimeType': 'image/png',
      'folderColorRgb': '#ffad46', // #ffa000
    });
    _folderId = folder['id'];
  }

  final Map<String, String> _files = {};

  Future<void> _fetchAllFiles() async {
    final qs = [
      "mimeType != '$_FOLDER_MIME_TYPE'",
      "'$_folderId' in parents",
    ].join(' and ');
    final jsonData = await _getJson('files', queryParameters: {'q': qs});

    (jsonData['files'] as List).forEach((file) {
      final Map<String, dynamic> item = file;
      _files[item['name']] = item['id'];
    });
  }

  Future<Uint8List> _uploadFile(String filename,
      {File localFile, Map<String, dynamic> json}) async {
    var fileId = _files[filename];
    if (fileId == null) {
      final json = await _postJson('files', body: {
        'name': filename,
        'parents': [_folderId],
      });
      fileId = json['id'];
      _files[filename] = fileId;
    }

    final uri = Uri.parse('$_API_UPLOAD_URL/$fileId?uploadType=media');
    final request = http.StreamedRequest('PATCH', uri);

    final bytes = localFile != null
        ? await localFile.readAsBytes()
        : utf8.encode(jsonEncode(json));

    request.headers['Authorization'] = _authToken;
    request.headers['Content-Type'] = 'application/octet-stream';
    request.headers['Content-Length'] = bytes.length.toString();
    request.sink.add(bytes);
    request.sink.close();

    final response = await request.send();
    return response.stream.toBytes();
  }

  String _token;
  String get _authToken => 'Bearer $_token';

  static const _API_BASE_URL = 'https://www.googleapis.com/drive/v3';
  static const _API_UPLOAD_URL =
      'https://www.googleapis.com/upload/drive/v3/files';
  static Uri apiUrl(String path) => Uri.parse('$_API_BASE_URL/$path');

  Future<http.Response> _get(
    String api, {
    Map<String, String> headers,
    Map<String, String> queryParameters,
  }) =>
      http.get(
        _buildQuery(api, queryParameters),
        headers: {'Authorization': _authToken}..addAll(headers ?? {}),
      );

  Future<Map<String, dynamic>> _getJson(
    String api, {
    Map<String, String> headers,
    Map<String, String> queryParameters,
  }) async {
    final res = await _get(
      api,
      headers: headers,
      queryParameters: queryParameters,
    );
    final json = res.body;
    return jsonDecode(json == null || json.isEmpty ? '{}' : json);
  }

  Future<http.Response> _post(
    String api, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) =>
      http.post(
        apiUrl('files'),
        headers: {
          'Authorization': _authToken,
          'Content-Type': 'application/json',
        }..addAll(headers ?? {}),
        body: body == null ? null : jsonEncode(body),
      );

  Future<Map<String, dynamic>> _postJson(
    String api, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) async {
    final res = await _post(
      api,
      headers: headers,
      body: body,
    );
    return jsonDecode(res.body);
  }

  Uri _buildQuery(String path, Map<String, String> queryParameters) {
    final url = apiUrl(path);
    if (queryParameters == null || queryParameters.isEmpty) return url;

    final qs = queryParameters.entries
        .map((p) =>
            '${Uri.encodeComponent(p.key)}=${Uri.encodeComponent(p.value)}')
        .join('&');
    return Uri.parse('$url?$qs');
  }

  static final _api = GoogleApi(
    'google',
    '1034436232619-3ufbs8bm18omn1nr9m4js92jqafpksom.apps.googleusercontent.com',
    'com.googleusercontent.apps.1034436232619-3ufbs8bm18omn1nr9m4js92jqafpksom:/redirct',
    clientSecret: 'TJDtk1ywT6KKs-0FO8ObVcx9',
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/drive.appdata',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );
  static GoogleApi get api => _api;
}
