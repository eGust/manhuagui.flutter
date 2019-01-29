import 'package:flutter/material.dart';

import '../touchable_icon.dart';
import '../../routes.dart';

class ComicBanner extends StatelessWidget {
  ComicBanner(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Container(
        height: 40.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TouchableIcon(
              Icons.arrow_back_ios,
              size: 28.0,
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.white,
              ),
            ),
            TouchableIcon(
              Icons.search,
              size: 28.0,
              color: Colors.white,
              onPressed: () {
                RouteHelper.pushSearch(context);
              },
            ),
          ],
        ),
      );
}
