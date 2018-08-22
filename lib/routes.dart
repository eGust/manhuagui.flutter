import 'package:flutter/material.dart';

import 'routes/splash.dart';
import 'routes/home.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (_) => Splash(),
  '/home': (_) => Home(),
};

// class SplashRoute<T> extends MaterialPageRoute<T> {
//   SplashRoute({WidgetBuilder builder, RouteSettings settings})
//       : super(builder: builder, settings: settings);

//   @override
//   Widget buildTransitions(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation, Widget child) {
//     if (settings.isInitialRoute) return child;
//     return super.buildTransitions(context, animation, secondaryAnimation, child);
//   }
// }

// final router = (RouteSettings settings) =>
//   SplashRoute(
//     builder: routes[settings.name],
//     settings: settings,
//   );

final router = (RouteSettings settings) =>
  MaterialPageRoute(
    builder: routes[settings.name],
    settings: settings,
  );
