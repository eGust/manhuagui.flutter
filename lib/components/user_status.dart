import 'dart:async';
import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';

class UserStatusButton extends StatefulWidget {
  const UserStatusButton();
  @override
  _UserStatusButtonState createState() => _UserStatusButtonState();
}

class _UserStatusButtonState extends State<UserStatusButton> {
  _UserStatusButtonState({
    this.iconSize = 28.0,
    this.fontSize = 18.0,
  })
    : this.user = globals.user
    ;
  final double iconSize, fontSize;
  final User user;

  Future<void> showLoginDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Center(child: const Text('用户登录')),
        children: [
          LoginForm(),
        ],
      ),
    );
    setState(() {});
  }

  Future<void> showLogoutDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Center(child: const Text('已登录')),
        children: [
          Container(
            height: 120.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 180.0,
                  height: 40.0,
                  child: RaisedButton(
                    color: Colors.red[900],
                    textColor: Colors.white,
                    child: const Text('退出登录', style: const TextStyle(fontSize: 18.0)),
                    onPressed: () {
                      user.logout();
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 180.0,
                  height: 40.0,
                  child: RaisedButton(
                    color: Colors.lightBlue[800],
                    textColor: Colors.white,
                    child: const Text('返 回', style: const TextStyle(fontSize: 18.0)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void showUserDialog() =>
    user.isLogin ? showLogoutDialog() : showLoginDialog();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(2.0),
    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
    child: GestureDetector(
      onTap: showUserDialog,
      child: Row(
        children: <Widget>[
          Icon(user.isLogin ? Icons.person : Icons.person_outline,
            size: iconSize,
            color: user.isLogin ? Colors.yellow[500] : Colors.red[200],
          ),
          Text(user.isLogin ? ' ${user.name}' : '（未登录）',
            style: TextStyle(
              fontSize: fontSize,
              color: user.isLogin ? Colors.white : Colors.red[200],
            ),
          ),
        ],
      ),
    )
  );
}

enum LoginStatus {
  initial, pending, success, failed
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  LoginStatus _status = LoginStatus.initial;
  // bool _remember = true;

  bool get anyEmtpy => _username.text.isEmpty || _password.text.isEmpty;

  @override
  void initState() {
    _username.addListener(_refresh);
    _password.addListener(_refresh);
    super.initState();
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _startLogin() async {
    setState(() {
      _status = LoginStatus.pending;
    });

    final c = await globals.user.login(user: _username.text, password: _password.text);
    setState(() {
      _status = c == null ? LoginStatus.failed : LoginStatus.success;
    });
    if (c != null) {
      globals.save();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 30.0, right: 30.0),
    width: 280.0,
    height: 240.0,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
        _status == LoginStatus.initial ? [
          TextFormField(
            controller: _username,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '用户名',
              labelStyle: TextStyle(color: Colors.red)
            ),
          ),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
              hintText: '密码',
            ),
          ),
          // SwitchListTile(
          //   title: const Text('记住密码',style: TextStyle(color: Colors.blue, fontSize: 18.0)),
          //   value: _remember,
          //   onChanged: (value) {
          //     setState(() {
          //       _remember = value;
          //     });
          //   },
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 120.0,
                height: 40.0,
                child: RaisedButton(
                  color: Colors.lightBlue[800],
                  textColor: Colors.white,
                  child: const Text('登录', style: const TextStyle(fontSize: 18.0)),
                  onPressed: anyEmtpy ? null : _startLogin,
                ),
              ),
              SizedBox(
                width: 120.0,
                height: 40.0,
                child: RaisedButton(
                  color: Colors.red[900],
                  textColor: Colors.white,
                  child: const Text('取消', style: const TextStyle(fontSize: 18.0)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ] :
        _status == LoginStatus.pending ? [
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: CircularProgressIndicator(),
          ),
          const Text('登录中...', style: TextStyle(
            color: Colors.blue,
            fontSize: 20.0,
          )),
        ] :
        _status == LoginStatus.success ? [
          const Text('登录成功！', style: TextStyle(
            color: Colors.green,
            fontSize: 30.0,
          )),
          SizedBox(
            width: 120.0,
            height: 40.0,
            child: RaisedButton(
              color: Colors.lightBlue[800],
              textColor: Colors.white,
              child: const Text('完成', style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ] : [
          // failed
          const Text('登录失败！', style: TextStyle(
            color: Colors.red,
            fontSize: 30.0,
          )),
          SizedBox(
            width: 120.0,
            height: 40.0,
            child: RaisedButton(
              color: Colors.lightBlue[800],
              textColor: Colors.white,
              child: const Text('重新输入', style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                setState(() {
                  _username.text = '';
                  _password.text = '';
                  _status = LoginStatus.initial;
                });
              },
            ),
          ),
          SizedBox(
            width: 120.0,
            height: 40.0,
            child: RaisedButton(
              color: Colors.red[800],
              textColor: Colors.white,
              child: const Text('关闭', style: const TextStyle(fontSize: 18.0)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ]
    )
  );
}
