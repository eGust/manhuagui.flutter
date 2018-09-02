import 'package:flutter/material.dart';

import '../models.dart';
import './grid_list.dart';

typedef SelectedFilter = void Function(String filter);

class FilterGroupList extends StatelessWidget {
  FilterGroupList(this.filterGroup, this.onSelected);
  final FilterGroup filterGroup;
  final SelectedFilter onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
    child: GridList(
      columnCount: 6,
      children: filterGroup.filters.map((f) => FilterButton(onSelected, f)).toList(),
    ),
  );
}

class FilterButton extends StatelessWidget {
  FilterButton(this.onSelected, this.filter);
  final SelectedFilter onSelected;
  final Filter filter;
  static final _textStyle = TextStyle(
    fontSize: 19.0,
    color: Colors.white,
  );

  void onPressed() {
    if (onSelected == null) return;
    onSelected(filter.link);
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(6.0),
    child: FlatButton(
      child: Container(
        padding: const EdgeInsets.only(top: 11.0, bottom: 11.0),
        child: Text(filter.title, style: _textStyle),
      ),
      onPressed: onPressed,
      color: filter.link == null ? Colors.lightBlue[700] : Colors.amber[900],
    ),
  );
}
