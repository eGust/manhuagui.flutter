import 'dart:async';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'action_panel.dart';
import 'image_resolver.dart';
import '../../store.dart';

enum ImageType {
  normal,
  horizon,
  vertical,
}

class ImageDelegate {
  ImageDelegate._(
    this.image, {
    this.key,
    this.width,
    this.height,
    this.scaleWidth,
    this.scaleHeight,
    this.scaleFit,
  });

  static final _config = ImageConfiguration();

  static double get screenWidth => globals.screenSize.shortestSide;
  static double get screenHeight => globals.screenSize.longestSide;
  static double get screenRatio => screenWidth / screenHeight;

  double get limitX => (scaleWidth * scale - screenWidth) / 2.0;
  double get limitY => (scaleHeight * scale - screenHeight) / 2.0;

  static Future<ImageDelegate> from(Image image, String key) {
    final c = Completer<ImageDelegate>();
    image.image.resolve(_config).addListener(ImageStreamListener((info, _bool) {
      final img = info.image;
      final w = img.width.toDouble();
      final h = img.height.toDouble();
      final sw = screenWidth;
      final sh = screenHeight;
      double scaleWidth, scaleHeight, scaleFit;

      if (w / h > sw / sh) {
        scaleWidth = sw;
        scaleHeight = h / w * sw;
        scaleFit = w / h * sh / sw;
      } else {
        scaleWidth = w / h * sh;
        scaleHeight = sh;
        scaleFit = h / w * sw / sh;
      }

      c.complete(ImageDelegate._(
        image,
        key: key,
        width: w,
        height: h,
        scaleWidth: scaleWidth,
        scaleHeight: scaleHeight,
        scaleFit: scaleFit,
      ));
    }));
    return c.future;
  }

  final Image image;
  final String key;
  final double scaleWidth;
  final double scaleHeight;
  final double width;
  final double height;
  final double scaleFit;

  double scale = 1.0;
  double _originalScale;

  double posX = 0.0;
  double posY = 0.0;
  double _deltaX;
  double _deltaY;

  ImageThreshold threshold;
  var type = ImageType.normal;

  double get extraAdjustX =>
      threshold?.extraAdjustWidth ?? ImageThreshold.threshold.extraAdjustWidth;
  double get extraAdjustY =>
      threshold?.extraAdjustHeight ??
      ImageThreshold.threshold.extraAdjustHeight;

  void reset() {
    scale = 1.0;
    posX = 0.0;
    posY = 0.0;
  }

  void updateOffset({double x, double y}) {
    x ??= posX;
    y ??= posY;
    final maxX = max(limitX, 0.0) + extraAdjustX;
    final maxY = max(limitY, 0.0) + extraAdjustX;

    if (x < -maxX) {
      x = -maxX;
    } else if (x > maxX) {
      x = maxX;
    }

    if (y < -maxY) {
      y = -maxY;
    } else if (y > maxY) {
      y = maxY;
    }

    posX = x;
    posY = y;
  }

  gestureStart(Offset position) {
    _originalScale = scale;
    _deltaX = posX - position.dx;
    _deltaY = posY - position.dy;
  }

  gestureUpdate(Offset position, double scaleFactor) {
    if (scaleFactor == 1.0) {
      if (scale < 1.001) return;
      updateOffset(x: _deltaX + position.dx, y: _deltaY + position.dy);
    } else {
      scale = _originalScale * sqrt(scaleFactor);
      if (scale <= 1.0 && posX != 0.0 && posY != 0.0) {
        posX = 0.0;
        posY = 0.0;
      }
    }
  }

  void fitScaleLeft() {
    scale = scaleFit;
    posX = limitX;
    posY = 0;
  }

  void fitScaleRight() {
    scale = scaleFit;
    posX = -limitX;
    posY = 0;
  }

  void fitScaleTop() {
    scale = scaleFit;
    posX = 0;
    posY = limitY;
  }

  void fitScaleBottom() {
    scale = scaleFit;
    posX = 0;
    posY = -limitY;
  }

  void fitScaleHorizonPages() {
    final ratio = width / height;
    final pageCount = (ratio / screenRatio).floorToDouble();
    if (pageCount > 1) {
      scale = pageCount * 0.96;
      posX = -limitX;
    }
  }

  double get slideIgnoreX =>
      threshold?.ignoreSlideFactorWidth ??
      ImageThreshold.threshold.ignoreSlideFactorWidth;
  double get slideIgnoreY =>
      threshold?.ignoreSlideFactorHeight ??
      ImageThreshold.threshold.ignoreSlideFactorHeight;

  double getSlideToX(int direction) {
    if (scale < 1.01) return null;

    final curX = posX;
    updateOffset(x: direction < 0 ? posX + screenWidth : posX - scaleWidth);
    final toX = posX;
    posX = curX;
    final deltaX = direction < 0 ? toX - posX : posX - toX;
    return deltaX < screenWidth * slideIgnoreX ? null : toX;
  }

  double getSlideToY(int direction) {
    if (scale < 1.01) return null;

    final curY = posY;
    updateOffset(y: direction < 0 ? posY + screenHeight : posY - scaleHeight);
    final toY = posY;
    posY = curY;
    final deltaY = direction < 0 ? toY - posY : posY - toY;
    return deltaY < screenHeight * slideIgnoreY ? null : toY;
  }

  double getSlideRightX() => getSlideToX(-1);
  double getSlideLeftX() => getSlideToX(1);
  double getSlideDownY() => getSlideToY(1);
  double getSlideUpY() => getSlideToY(-1);

  ActionEventCenter eventCenter;
}
