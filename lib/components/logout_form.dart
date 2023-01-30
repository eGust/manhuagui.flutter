import 'package:flutter/material.dart';

import '../store.dart';

class LogoutForm extends StatefulWidget {
  @override
  _LogoutFormState createState() => _LogoutFormState();
}

class _LogoutFormState extends State<LogoutForm> {
  bool _loggedOut = false;

  @override
  Widget build(BuildContext context) => Container(
        height: 120.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _loggedOut
                ? const Text('已退出！',
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 20.0,
                    ))
                : SizedBox(
                    width: 180.0,
                    height: 40.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red[900]),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('退出登录',
                          style: const TextStyle(fontSize: 18.0)),
                      onPressed: () {
                        setState(() {
                          globals.user.logout();
                          _loggedOut = true;
                        });
                      },
                    ),
                  ),
            SizedBox(
              width: 180.0,
              height: 40.0,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.lightBlue[800]),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                child:
                    const Text('返 回', style: const TextStyle(fontSize: 18.0)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
}
