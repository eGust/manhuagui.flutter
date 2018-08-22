import 'package:flutter/material.dart';

import '../api/status_bar.dart';
import '../store.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  void initialize() async {
    StatusBar.hide();
    Navigator.of(context).popAndPushNamed('/home');
    StatusBar.show();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) =>
    Container(
      child:
        Text(
          'ManHuaGui',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 40.0
          ),
        ),
      alignment: Alignment.center,
      color: Colors.yellow.shade700,
    );
}

