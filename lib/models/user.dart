import 'dart:async';

import '../api.dart';
import '../models.dart';

enum AjaxAction {
  checkLogin,
  login,
  checkFavorite,
  addFavorite,
  removeFavorite
}

final Map<AjaxAction, String> _actionMap = {
  AjaxAction.checkLogin: 'user_check_login', // GET
  AjaxAction.login: 'user_login', // POST
  AjaxAction.checkFavorite: 'user_book_shelf_check', // GET
  AjaxAction.addFavorite: 'user_book_shelf_add', // POST
  AjaxAction.removeFavorite: 'user_book_shelf_delete', // POST
};

class User {
  static const _BASE_AJAX_URL =
      'https://www.manhuagui.com/tools/submit_ajax.ashx';
  static const _PAGE_FAVORITE_URL =
      'https://m.manhuagui.com/user/book/?ajax=1&page=';
  static const _SHELF_URL = 'https://www.manhuagui.com/user/book/shelf';

  static String buildActionUrl(AjaxAction action,
      {Map<String, String> queryParams}) {
    final parts = <String>['$_BASE_AJAX_URL?action=${_actionMap[action]}'];
    if (queryParams != null) {
      parts.addAll(
          queryParams.entries.map((entry) => '${entry.key}=${entry.value}'));
    }
    return parts.join('&');
  }

  static final _reCookie = RegExp(r'(my=[^;]+)');

  User({String username, String password, String cookie}) {
    _username = username;
    _password = password;
    _setCookie(cookie);
  }

  Future<bool> initialize() async {
    if (_cookie != null) {
      final res = await getJson(buildActionUrl(AjaxAction.checkLogin),
          headers: cookieHeaders);
      if (res['status'] == 1) return true;
      _setCookie(null);
    }

    if (_username == null || _password == null) return false;
    final succ = await login(username: _username, password: _password);
    return succ != null;
  }

  String _cookie, _username, _nickname, _password;

  String get nickname => _nickname;
  String get username => _username;
  String get password => _password;

  String get cookie => _cookie;
  void _setCookie(String value) {
    _cookie = value;
    if (_cookie == null) {
      cookieHeaders = {};
    } else {
      cookieHeaders = {'cookie': value};
    }
  }

  bool get isLogin => _cookie != null;

  Map<String, String> cookieHeaders;

  Future<bool> checkLogin() async {
    if (_cookie == null) return false;
    final res = await getJson(buildActionUrl(AjaxAction.checkLogin),
        headers: cookieHeaders);
    final r = res['status'] == 1;
    if (!r) {
      _setCookie(null);
    }
    return r;
  }

  Future<String> login(
      {String username, String password, bool remember = true}) async {
    final data = await postJsonRaw(
      buildActionUrl(AjaxAction.login),
      body: {'txtUserName': username, 'txtPassword': password},
    );

    String c;
    if (data['body']['status'] == 1) {
      final String rawCookie = data['headers']['set-cookie'];
      c = _reCookie.firstMatch(rawCookie)[1];
      _setCookie(c);
      _username = username;
      _nickname = _username;
      if (remember) {
        _password = password;
      }
    }
    return c;
  }

  void logout() {
    _cookie = null;
  }

  Future<bool> _favorite(int bookId, AjaxAction action) async {
    if (!isLogin) return null;

    Map<String, dynamic> res;
    if (action == AjaxAction.checkFavorite) {
      final url = buildActionUrl(AjaxAction.checkFavorite,
          queryParams: {'book_id': '$bookId'});
      res = await getJson(url, headers: cookieHeaders);
    } else {
      final url = buildActionUrl(action);
      res = await postJson(url,
          headers: cookieHeaders, body: {'book_id': '$bookId'});
    }
    return res['status'] == 1;
  }

  Future<bool> isFavorite(int bookId) =>
      _favorite(bookId, AjaxAction.checkFavorite);

  Future<bool> addFavorite(int bookId) =>
      _favorite(bookId, AjaxAction.addFavorite);

  Future<bool> removeFavorite(int bookId) =>
      _favorite(bookId, AjaxAction.removeFavorite);

  Future<List<ComicCover>> getFavorites({int pageNo = 1}) async {
    if (!isLogin) return [];
    final doc = await fetchAjaxDom('$_PAGE_FAVORITE_URL$pageNo',
        headers: cookieHeaders);
    return ComicCover.parseFavorite(doc).toList();
  }

  static const _COVER_LINK = '.dy_content_li h3 > a';

  Future<Set<int>> getAllFavorites() async {
    final r = Set<int>();
    if (!isLogin) return r;

    final shelf = await fetchDom(_SHELF_URL, headers: cookieHeaders);
    _nickname = shelf.querySelector('.avatar-box > h3').text.trim();
    shelf.querySelectorAll(_COVER_LINK).forEach((link) {
      final cover = ComicCover.fromLink(link);
      r.add(cover.bookId);
    });

    final pageCount =
        shelf.querySelectorAll('.page-foot > .flickr > a[href]').length;
    for (var pageNo = 2; pageNo <= pageCount; pageNo += 1) {
      await Future.delayed(const Duration(milliseconds: 2500), () {});
      if (!isLogin) return r;
      final doc = await fetchDom('$_SHELF_URL/$pageNo', headers: cookieHeaders);
      doc.querySelectorAll(_COVER_LINK).forEach((link) {
        final cover = ComicCover.fromLink(link);
        r.add(cover.bookId);
      });
    }
    return r;
  }

  Map<String, dynamic> toJson() => {
        'cookie': _cookie,
        'username': _username,
        'nickname': _nickname,
        'password': _password,
      };

  User.fromJson(Map<String, dynamic> json) {
    _setCookie(json['cookie']);
    _username = (json['username']);
    _nickname = (json['nickname']);
    _password = (json['password']);
  }
}
