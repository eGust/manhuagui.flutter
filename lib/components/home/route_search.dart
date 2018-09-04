import 'package:flutter/material.dart';

import './sub_router.dart';

class RouteSearch extends StatelessWidget {
  static final router = SubRouter(
    'search',
    Icons.search,
    () => RouteSearch(),
  );

  @override
  Widget build(BuildContext context) =>
    Text(
      'search',
      textDirection: TextDirection.ltr,
      style: TextStyle(
        color: Colors.blueAccent.shade700,
        fontSize: 20.0
      ),
    );
}
