import 'dart:async';

import '../api.dart';
import '../models.dart';

enum AjaxAction { checkLogin, login, checkFavorate, addFavorate, removeFavorate }

final Map<AjaxAction, String> _actionMap = {
  AjaxAction.checkLogin: 'user_check_login', // GET
  AjaxAction.login: 'user_login', // POST
  AjaxAction.checkFavorate: 'user_book_shelf_check', // GET
  AjaxAction.addFavorate: 'user_book_shelf_add', // POST
  AjaxAction.removeFavorate: 'user_book_shelf_delete', // POST
};

class User {
  static const _BASE_AJAX_URL = 'https://www.manhuagui.com/tools/submit_ajax.ashx';
  static const _FAVORATE_URL = 'https://m.manhuagui.com/user/book/?ajax=1&order=1&page=';

  static String buildActionUrl(AjaxAction action, { Map<String, String> queryParams }) {
    final parts = <String>['$_BASE_AJAX_URL?action=${_actionMap[action]}'];
    if (queryParams != null) {
      parts.addAll(queryParams.entries.map((entry) => '${entry.key}=${entry.value}'));
    }
    return parts.join('&');
  }

  static final _reCookie = RegExp(r'(my=[^;]+)');

  User({ String user, String password, String cookie }) {
    _user = user;
    _password = password;
    _setCookie(cookie);
  }

  Future<bool> initialize() async {
    if (_cookie != null) {
      final res = await getJson(buildActionUrl(AjaxAction.checkLogin), headers: cookieHeaders);
      if (res['status'] == 1) return true;
      _setCookie(null);
    }

    if (_user == null || _password == null) return false;
    final succ = await login(user: _user, password: _password);
    return succ != null;
  }

  String _cookie, _user, _password;

  String get cookie => _cookie;
  void _setCookie(String value) {
    _cookie = value;
    if (_cookie == null) {
      cookieHeaders = {};
    } else {
      cookieHeaders = { 'cookie': value };
    }
  }

  bool get isLogin => _cookie != null;

  Map<String, String> cookieHeaders;

  Future<bool> checkLogin() async {
    if (_cookie == null) return false;
    final res = await getJson(buildActionUrl(AjaxAction.checkLogin), headers: cookieHeaders);
    final r = res['status'] == 1;
    if (!r) { _setCookie(null); }
    return r;
  }

  Future<String> login({ String user, String password, bool remember }) async {
    final data = await postJsonRaw(
      buildActionUrl(AjaxAction.login),
      body: { 'txtUserName': user, 'txtPassword': password },
    );

    String c;
    if (data['body']['status'] == 1) {
      final String rawCookie = data['headers']['set-cookie'];
      c = _reCookie.firstMatch(rawCookie)[1];
      _setCookie(c);
      if (remember) {
        _user = user;
        _password = password;
      }
    }
    return c;
  }

  Future<bool> _favorate(int bookId, AjaxAction action) async {
    if (!isLogin) return null;

    Map<String, dynamic> res;
    if (action == AjaxAction.checkFavorate) {
      final url = buildActionUrl(AjaxAction.checkFavorate, queryParams: { 'book_id': '$bookId' });
      res = await getJson(url, headers: cookieHeaders);
    } else {
      final url = buildActionUrl(action);
      res = await postJson(url, headers: cookieHeaders, body: { 'book_id': '$bookId' });
    }
    return res['status'] == 1;
  }

  Future<bool> isFavorate(int bookId) => _favorate(bookId, AjaxAction.checkFavorate);

  Future<bool> addFavorate(int bookId) => _favorate(bookId, AjaxAction.addFavorate);

  Future<bool> removeFavorate(int bookId) => _favorate(bookId, AjaxAction.removeFavorate);

  Future<List<ComicCover>> getFavorates({ int pageNo = 1 }) async {
    if (!isLogin) return <ComicCover>[];
    final doc = await fetchDom('$_FAVORATE_URL$pageNo', headers: cookieHeaders);
    return ComicCover.parseFavorate(doc);
  }

  Map<String, dynamic> toJson() => {
    'cookie': _cookie,
    'user': _user,
    'password': _password,
  };

  User.fromJson(Map<String, dynamic> json) {
    _setCookie(json['cookie']);
    _user = (json['user']);
    _password = (json['password']);
  }
}
