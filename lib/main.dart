import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'utils.dart';
import 'store.dart';
import 'routes.dart';

void main() async {
  log('main started');
  // await globals.cleanInitialize();
  await globals.initialize();
  log('ready to start app');
  runApp(App());
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
