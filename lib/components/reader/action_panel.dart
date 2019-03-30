import 'package:flutter/widgets.dart';

typedef OffsetAction = void Function(Offset position);
typedef GestureAction = void Function(Offset position, double scale);
typedef GestureEndAction = void Function(Offset delta, Offset velocity);
typedef SlideAction = void Function(int direction);

class ActionEventCenter {
  const ActionEventCenter({
    this.onDoubleTap,
    this.onTap,
    this.onGestureStart,
    this.onGestureUpdate,
    this.onGestureEnd,
  });

  final OffsetAction onTap;
  final VoidCallback onDoubleTap;
  final OffsetAction onGestureStart;
  final GestureAction onGestureUpdate;
  final GestureEndAction onGestureEnd;
}

class ActionPanel extends StatefulWidget {
  ActionPanel({
    this.onDoubleTap,
    this.onGestureStart,
    this.onGestureUpdate,
    this.onGestureEnd,
    this.onTap,
  });
  final OffsetAction onTap;
  final VoidCallback onDoubleTap;
  final OffsetAction onGestureStart;
  final GestureAction onGestureUpdate;
  final GestureEndAction onGestureEnd;

  @override
  _ActionPanelState createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  Offset _start, _last;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onScaleStart: (details) {
          _start = details.focalPoint;
          widget.onGestureStart?.call(_start);
        },
        onScaleUpdate: (details) {
          _last = details.focalPoint;
          widget.onGestureUpdate?.call(_last, details.scale);
        },
        onScaleEnd: (details) {
          widget.onGestureEnd?.call(
            Offset(_last.dx - _start.dx, _last.dy - _start.dy),
            details.velocity.pixelsPerSecond,
          );
        },
        onTapUp: (details) {
          widget.onTap?.call(details.globalPosition);
        },
        onDoubleTap: widget.onDoubleTap,
      );
}
