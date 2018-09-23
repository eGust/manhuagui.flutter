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

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(2.0),
    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
    child: GestureDetector(
      onTap: () {},
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
