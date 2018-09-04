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
    margin: const EdgeInsets.only(left: 8.0, right: 8.0),
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.white)),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: 50.0,
          alignment: Alignment.center,
          child: Text(filterGroup.title, style: TextStyle(
            fontSize: 18.0,
          )),
        ),
        Container(
          width: 600.0,
          child: GridList(
            columnCount: 5,
            children: filterGroup.filters.map((f) => FilterButton(onSelected, f)).toList(),
          ),
        ),
      ],
    )
  );
}

class FilterButton extends StatelessWidget {
  FilterButton(this.onSelected, this.filter);
  final SelectedFilter onSelected;
  final Filter filter;

  void onPressed() {
    if (onSelected == null) return;
    onSelected(filter.link);
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(10.0, 1.0, 0.0, 1.0),
    child: FlatButton(
      color: Colors.amber[700],
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Text(
          filter.title,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.brown[900],
          ),
        ),
      ),
      onPressed: onPressed,
    ),
  );
}
