import 'dart:async';
import 'package:flutter/material.dart';

export 'routes/home_screen.dart';
export 'routes/comic_screen.dart';
export 'routes/author_screen.dart';

import 'routes/comic_screen.dart';
import 'routes/author_screen.dart';
import 'routes/reader_screen.dart';
import 'routes/search_screen.dart';

import './models.dart';

class RouteHelper {
  static Route<Widget> buildRoute(Widget screen) =>
      MaterialPageRoute(builder: (_) => Material(child: screen));

  static Future<Widget> pushComic(BuildContext context, ComicCover cover) {
    return Navigator.push(
      context,
      buildRoute(ComicScreen(cover)),
    );
  }

  static Future<Widget> replaceComic(BuildContext context, ComicCover cover) {
    return Navigator.pushReplacement(
      context,
      buildRoute(ComicScreen(cover)),
    );
  }

  static Future<Widget> pushAuthor(BuildContext context, AuthorLink author) {
    return Navigator.push(
      context,
      buildRoute(AuthorScreen(author)),
    );
  }

  static Future<Widget> pushReader(BuildContext context, ReaderHelper helper) {
    return Navigator.push(
      context,
      buildRoute(ReaderScreen(helper)),
    );
  }

  static Future<Widget> pushSearch(BuildContext context) {
    return Navigator.push(
      context,
      buildRoute(SearchScreen()),
    );
  }
}
