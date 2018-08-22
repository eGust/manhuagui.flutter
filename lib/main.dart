import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'store.dart';
import 'routes/home.dart';

void main() async {
  await globals.initialize();
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
