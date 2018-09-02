import 'package:flutter/cupertino.dart';
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
  Widget build(BuildContext context) => CupertinoApp(
      home: Home(),
      // routes: {
      //   '/foo': (context) => Home(),
      // },
      // initialRoute: '/',
      // onGenerateRoute: router,
    );
}
