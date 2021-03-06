import 'package:flutter/material.dart';

import '../store.dart';
import '../components/search/search_form.dart';
import '../components/search/result_list.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _inputting = true;
  String _searchKey = '';

  void _onSearch(final String key) {
    setState(() {
      _searchKey = key;
      _inputting = false;
    });
  }

  void _onResearch() {
    setState(() {
      _inputting = true;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
            color: Colors.brown[900],
            height: globals.statusBarHeight,
          ),
          Expanded(
            child: _inputting
                ? SearchForm(_searchKey, onSearch: _onSearch)
                : ResultList(_searchKey, onResearch: _onResearch),
          ),
        ],
      );
}
