import 'package:flutter/material.dart';

import '../models.dart';
import './grid_list.dart';

typedef SelectedFilter = void Function(FilterGroup group, String filter);

class FilterGroupList extends StatelessWidget {
  FilterGroupList(this.filterGroup, this.selected, { this.onSelectedFilter });
  final FilterGroup filterGroup;
  final String selected;
  final SelectedFilter onSelectedFilter;

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
            children: filterGroup.filters.map((f) => FilterButton(
              filter: f,
              onPressed: f.title == '耽美' ? null : () {
                if (onSelectedFilter == null) return;
                onSelectedFilter(filterGroup, f.link);
              },
              selected: f.link == selected,
            )).toList(),
          ),
        ),
      ],
    )
  );
}

class FilterButton extends StatelessWidget {
  FilterButton({ @required this.filter, this.onPressed, this.selected = false });
  final VoidCallback onPressed;
  final Filter filter;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(10.0, 1.0, 0.0, 1.0),
    child: FlatButton(
      color: selected ? Colors.deepOrange[800] : Colors.orange[700],
      disabledColor: Colors.grey[600],
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Text(
          filter.title,
          style: TextStyle(
            fontSize: 18.0,
            color: selected ? Colors.white : Colors.brown[700],
          ),
        ),
      ),
    ),
  );
}
