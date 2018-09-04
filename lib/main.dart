import 'package:flutter/material.dart';

import 'utils.dart';
import 'store.dart';
import 'routes.dart';
import 'api.dart';

void main() async {
  log('main started');
  StatusBar.init();
  await globals.initialize();
  // updateSettings();
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
    ),
    initialRoute: '/',
    routes: routes,
  );
}
