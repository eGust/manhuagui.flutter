import 'package:flutter/material.dart';

import '../store.dart';
import '../components/search/search_form.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _inputing = true;

  void _onSearch(final String key) {
    //
  }

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Container(
        color: Colors.brown[900],
        height: globals.statusBarHeight,
      ),
      Expanded(child: _inputing ? SearchForm(_onSearch) : Container()),
    ],
  );
}
