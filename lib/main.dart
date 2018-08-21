import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final val = prefs.getInt('foo') ?? 0;
  print(val);
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => CupertinoApp(
    home: Home(),
    // routes: {
    //   '/foo': (context) => Home(),
    // },
  );
}
