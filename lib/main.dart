import 'dart:ui';

import 'package:flutter/material.dart';

import 'store.dart';
import 'routes.dart';
import 'api.dart';

void main() async {
  log('main started');
  await globals.initialize();
  // updateSettings();

  final size = MediaQueryData.fromWindow(window).size;
  print("window.devicePixelRatio = ${window.devicePixelRatio}");
  print("width = ${size.shortestSide} x ${size.longestSide}");

  log('ready to start app');
  runApp(App());
}

void updateSettings() async {
  await globals.refreshMetaData();
  globals.save();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          dialogBackgroundColor: Colors.yellow[200].withAlpha(0xCC),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[900]),
              borderRadius: BorderRadius.circular(32.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[600], width: 2.0),
              borderRadius: BorderRadius.circular(32.0),
            ),
            hintStyle: TextStyle(color: Colors.lightBlue[300]),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          ),
        ),
        home: Material(child: HomeScreen()),
      );
}
