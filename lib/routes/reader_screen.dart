import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../utils.dart';
import '../components/touchable_icon.dart';

class ReaderScreen extends StatefulWidget {
  ReaderScreen(this.helper);

  final ReaderHelper helper;

  @override
  _ReaderScreenState createState() => _ReaderScreenState(helper);
}

class _ReaderScreenState extends State<ReaderScreen> {
  _ReaderScreenState(this.helper) {
    StatusBar.hide();
  }

  @override
  void dispose() {
    StatusBar.show();
    super.dispose();
  }

  final ReaderHelper helper;

  bool _preventBack = true, _reading = true;

  void _toggleReadMode() {
    setState(() {
      _reading = !_reading;
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => !_preventBack,
    child: Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(), // images
          _reading ? // touchable
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TransparentButton(
                    flex: 2,
                    onPressed: () {
                      // previous page
                      logd('previous page');
                    },
                  ),
                  TransparentButton(
                    flex: 3,
                    onPressed: _toggleReadMode,
                  ),
                  TransparentButton(
                    flex: 2,
                    onPressed: () {
                      // next page
                      logd('next page');
                    },
                  ),
                ],
              ),
            ) : // - goback, go
            Column(
              children: <Widget>[
                Container(
                  color: Colors.grey[600],
                  height: 100.0,
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      TouchableIcon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 32.0,
                        onPressed: () {
                          _preventBack = false;
                          Navigator.pop(context);
                        },
                      ),
                      Container(),
                    ],
                  ),
                ),
                TransparentButton(
                  onPressed: _toggleReadMode,
                ),
                Container(
                  color: Colors.grey[600],
                  height: 100.0,
                ),
              ],
            ),
        ],
      ),
    )
  );
}

class TransparentButton extends StatelessWidget {
  TransparentButton({ this.onPressed, this.flex = 1 });

  final VoidCallback onPressed;
  final int flex;

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: GestureDetector(
      onTap: onPressed,
    ),
  );
}
