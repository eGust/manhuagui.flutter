import 'dart:async';
import 'package:flutter/material.dart';

export 'routes/home_screen.dart';
export 'routes/comic_screen.dart';
export 'routes/author_screen.dart';

import 'routes/comic_screen.dart';
import 'routes/author_screen.dart';
import 'routes/reader_screen.dart';

import './models.dart';

class RouteHelper {
  static Route<Widget> buildRoute(Widget screen) =>
    MaterialPageRoute(builder: (_) => Material(child: screen));

  static Future<Widget> navigateComic(BuildContext context, ComicCover cover) {
    return Navigator.push(
      context,
      buildRoute(ComicScreen(cover)),
    );
  }

  static Future<Widget> navigateAuthor(BuildContext context, AuthorLink author) {
    return Navigator.push(
      context,
      buildRoute(AuthorScreen(author)),
    );
  }

  static Future<Widget> navigateReader(BuildContext context, ReaderHelper helper) {
    return Navigator.push(
      context,
      buildRoute(ReaderScreen(helper)),
    );
  }
}
