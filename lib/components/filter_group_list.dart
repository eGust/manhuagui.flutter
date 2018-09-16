import 'package:flutter/material.dart';

import '../models.dart';
import './grid_list.dart';

typedef SelectedFilter = void Function(FilterGroup group, String filter);

class FilterGroupList extends StatelessWidget {
  FilterGroupList(
    this.filterGroup,
    this.selected,
    { Set<String> blacklist, this.onSelectedFilter }
  ): this.blacklist = blacklist ?? Set()
  ;

  final FilterGroup filterGroup;
  final String selected;
  final SelectedFilter onSelectedFilter;
  final Set<String> blacklist;

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
              disabled: blacklist.contains(f.link),
              onPressed: () {
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
  FilterButton({
    @required this.filter,
    VoidCallback onPressed,
    bool selected = false,
    bool disabled = false,
  })
  : color = selected ? Colors.deepOrange[800] : Colors.orange[700]
  , textColor = disabled ? Colors.grey[500] : selected ? Colors.white : Colors.brown[700]
  , onPressed = disabled ? null : onPressed
  ;

  final VoidCallback onPressed;
  final Displayable filter;
  final Color color, textColor;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(10.0, 1.0, 0.0, 1.0),
    child: FlatButton(
      color: color,
      disabledColor: Colors.grey[600],
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Text(
          filter.display,
          style: TextStyle(
            fontSize: 18.0,
            color: textColor,
          ),
        ),
      ),
    ),
  );
}
