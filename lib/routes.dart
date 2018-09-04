import 'package:flutter/material.dart';

import 'routes/home.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (_) => Home(),
}.map((p, w) => MapEntry(p, (c) => Material(child: w(c))));
