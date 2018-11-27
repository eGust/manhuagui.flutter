import 'package:flutter/material.dart';

import '../../store.dart';

typedef ReadAction = void Function({int offset});

class ReadActionPanel extends StatefulWidget {
  ReadActionPanel({@required this.onPressed});
  final ReadAction onPressed;
  @override
  _ReadActionPanelState createState() => _ReadActionPanelState();
}

class _ReadActionPanelState extends State<ReadActionPanel> {
  _ReadActionPanelState();

  Offset _dragFrom, _dragTo;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onHorizontalDragStart: (details) {
          _dragFrom = details.globalPosition;
        },
        onHorizontalDragUpdate: (details) {
          _dragTo = details.globalPosition;
        },
        onHorizontalDragEnd: (_) {
          final dx = _dragTo.dx - _dragFrom.dx;
          final dy = _dragTo.dy - _dragFrom.dy;

          if (dx.abs() < dy.abs() * 3 || dx.abs() < 40.0) return;
          widget.onPressed(offset: dx > 0 ? 0 - 1 : 0 + 1);
        },
        // onScaleStart: (details) {
        //   logd('onScaleStart $details');
        // },
        // onScaleUpdate: (details) {
        //   logd('onScaleUpdate $details');
        // },
        onTapUp: (details) {
          final x = details.globalPosition.dx;
          if (x > globals.prevThreshold && x < globals.nextThreshold) {
            widget.onPressed();
            return;
          }

          widget.onPressed(offset: x < globals.prevThreshold ? 0 - 1 : 0 + 1);
        },
      );
}
