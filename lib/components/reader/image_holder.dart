import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' show Quaternion, Vector3;

import 'image_resolver.dart';
import 'image_delegate.dart';
import 'action_panel.dart';
import 'fast_status.dart';
import '../../store.dart';

class ImageHolder extends StatefulWidget {
  ImageHolder({
    @required this.resolver,
    this.onSlide,
  });
  final ImageResolver resolver;
  final SlideAction onSlide;
  @override
  _ImageHolderState createState() => _ImageHolderState();
}

class _ImageHolderState extends State<ImageHolder>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _animationPosition;
  CurvedAnimation _curve;
  ImageDelegate _imageDelegate;
  ActionEventCenter _eventCenter;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0),
    );

    _eventCenter = ActionEventCenter(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onGestureUpdate: onGestureUpdate,
      onGestureEnd: onGestureEnd,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.resolver != null) {
      updateDelegate();
    } else {
      busyUpdateResolver();
    }
  }

  Future<void> busyUpdateResolver() async {
    for (;;) {
      await Future.delayed(const Duration(milliseconds: 33));
      if (widget.resolver != null) break;
    }
    setState(() {
      updateDelegate();
    });
  }

  void updateDelegate() {
    _imageDelegate = widget.resolver.imageDelegate;
    if (widget.resolver.isResolved) {
      _imageDelegate.eventCenter = _eventCenter;
      return;
    }

    widget.resolver.resolve().then((delegate) {
      if (delegate == null ||
          widget.resolver == null ||
          widget.resolver.key != delegate.key ||
          !mounted) return;

      setState(() {
        _imageDelegate = delegate;
        _imageDelegate.eventCenter = _eventCenter;
      });
    });
  }

  bool get isPending => image == null;
  Image get image => _imageDelegate?.image;
  double get scale => _imageDelegate?.scale;
  double get posX => _imageDelegate?.posX;
  double get posY => _imageDelegate?.posY;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _child) => isPending
            ? LoadingCircle()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.compose(
                  (_animationPosition == null
                      ? Vector3(posX, posY, 0.0)
                      : Vector3(_animationPosition.value, posY, 0.0)),
                  Quaternion.identity(),
                  Vector3(scale, scale, 0.0),
                ),
                child: image,
              ),
      );

  void _playAnimation(double toPosX) {
    _animationPosition = Tween(begin: posX, end: toPosX).animate(_curve);
    _controller
      ..reset()
      ..forward().whenComplete(() {
        _imageDelegate?.posX = toPosX;
        _animationPosition = null;
      });
  }

  void _slide(int direction) {
    if (mounted || _imageDelegate != null) {
      final toX = _imageDelegate.getSlideToX(direction);

      if (toX != null) {
        _playAnimation(toX);
        return;
      }
    }
    widget.onSlide?.call(direction);
  }

  void onTap(Offset position) {
    if (position.dx < globals.prevThreshold) {
      _slide(0 + 1);
    } else if (position.dx > globals.nextThreshold) {
      _slide(0 - 1);
    }
  }

  void onDoubleTap() {
    if (!mounted || _imageDelegate == null) return;

    setState(() {
      if (_imageDelegate.scale == 1.0) {
        _imageDelegate.fitScaleRight();
      } else {
        _imageDelegate.reset();
      }
    });
  }

  void onGestureUpdate(Offset position, double scale) {
    if (!mounted || _imageDelegate == null) return;

    setState(() {
      _imageDelegate.gestureUpdate(position, scale);
      if (_imageDelegate.scale < 0.2) {
        _imageDelegate.scale = 0.2;
      } else if (_imageDelegate.scale > _imageDelegate.scaleFit * 5) {
        _imageDelegate.scale = _imageDelegate.scaleFit * 5;
      }
    });
  }

  void onGestureEnd(Offset delta, Offset _velocity) {
    if (!mounted || _imageDelegate == null) return;

    setState(() {
      if (_imageDelegate.scale > 1.01) {
        _imageDelegate.updateOffset();
        return;
      }

      final x = delta.dx.abs();
      if (x > 50.0 && x > delta.dy.abs() * 3) {
        _slide(delta.dx.sign.floor());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
