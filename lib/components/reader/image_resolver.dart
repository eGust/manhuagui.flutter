import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'image_delegate.dart';

class ImageThreshold {
  const ImageThreshold({
    this.extraAdjustWidth = 8.0,
    this.extraAdjustHeight = 8.0,
    this.ignoreSlideFactorWidth = 0.08,
    this.ignoreSlideFactorHeight = 0.08,
  });
  final double extraAdjustWidth;
  final double extraAdjustHeight;
  final double ignoreSlideFactorWidth;
  final double ignoreSlideFactorHeight;

  static const threshold = ImageThreshold();
}

class ImageResolver {
  ImageResolver(this.key, FutureOr<Image> image) {
    this._setImage(image);
  }
  Future<Image> _future;
  Image _image;
  String key;
  ImageThreshold threshold;

  Image get image => _image;
  Future<void> _setImage(FutureOr<Image> value) async {
    if (value is Future<Image>) {
      _image = null;
      _delegate = null;
      if (_future == value) return;

      _future = value;
      final img = await _future;
      if (_future == value) _setImage(img);
    } else if (value is Image) {
      _future = null;
      if (_image == value) return;

      _image = value;
      _delegate = null;
    } else {
      _future = null;
      _image = null;
      _delegate = null;
    }
  }

  bool get isResolved => _delegate != null;
  ImageDelegate _delegate;
  ImageDelegate get imageDelegate => _delegate;

  Future<ImageDelegate> _resolvingTask;
  String _resolvingKey;

  void _resolve(Completer<ImageDelegate> c, Image img) {
    ImageDelegate.from(img, key).then((delegate) {
      _delegate = delegate;
      c.complete(_resolvingKey == key ? delegate : null);
    });
  }

  Future<void> update(String key, FutureOr<Image> image) {
    this.key = key;
    return this._setImage(image);
  }

  Future<ImageDelegate> resolve() {
    if (isResolved) return Future.value(_delegate);
    if (_resolvingTask != null && _resolvingKey == key) return _resolvingTask;

    final c = Completer<ImageDelegate>();
    _resolvingKey = key;
    _resolvingTask = c.future;
    _delegate = null;
    if (_future == null) {
      _resolve(c, image);
    } else {
      final k = key;
      _future.then((img) {
        if (k == key) {
          _resolve(c, img);
        } else {
          c.complete(null);
        }
      });
    }
    return _resolvingTask;
  }
}
