import 'package:flutter/material.dart';

class Progressing extends StatelessWidget {
  Progressing({
    this.visible = true,
    this.size = 50.0,
    this.strokeWidth = 5.0,
  });
  final bool visible;
  final double size, strokeWidth;
  @override
  Widget build(BuildContext context) => visible
      ? Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(strokeWidth: strokeWidth),
          ),
        )
      : Visibility(visible: false, child: const Text(''));
}
