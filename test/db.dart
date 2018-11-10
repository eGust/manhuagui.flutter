// import 'dart:async';
import 'dart:convert';

import '../lib/api.dart';
import '../lib/models.dart';
import '../lib/config.dart';

void main() async {
  final user = User();
  final cookies = await user.login(
      username: loginInfo['user'], password: loginInfo['password']);
  print('cookies = $cookies, isLogin = ${user.isLogin}');
  final favorates = await user.getFavorites();
  final fids = favorates.map((c) => c.bookId).toList();
  print(fids);
  final rdb = await RemoteDb.create();
  final comics = await rdb.queryByIds(fids);
  print('favorates: ${jsonEncode(comics)}');
}
