import 'package:flutter/material.dart';

class Progressing extends StatelessWidget {
  Progressing({ this.visible = false });
  final bool visible;
  @override
  Widget build(BuildContext context) => visible ?
    Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(30.0),
      child: CircularProgressIndicator(),
    ) :
    Visibility(visible: false, child: const Text(''))
    ;
}
