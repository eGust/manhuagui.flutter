import 'package:flutter/material.dart';

import '../models.dart';

typedef SelectedFilter = void Function(FilterGroup group, String filter);

class FilterGroupList extends StatelessWidget {
  FilterGroupList(
    this.filterGroup,
    this.selected,
    { Set<String> blacklist, this.onSelectedFilter, this.columnCount = 5 }
  )
    : this.blacklist = blacklist ?? Set()
    , this.buttonFontSize = columnCount > 5 ? 16.0 : 18.0
    ;

  final FilterGroup filterGroup;
  final String selected;
  final SelectedFilter onSelectedFilter;
  final Set<String> blacklist;
  final int columnCount;
  final double buttonFontSize;

  @override
  Widget build(BuildContext context) => DisplayableGroupList(
    filterGroup.title,
    columnCount: columnCount,
    children: filterGroup.filters.map((f) =>
      DisplayableButton(
        item: f,
        fontSize: buttonFontSize,
        disabled: blacklist.contains(f.link),
        onPressed: () {
          if (onSelectedFilter == null) return;
          onSelectedFilter(filterGroup, f.link);
        },
        selected: f.link == selected,
      )).toList(),
  );
}

class OrderSelectGroup extends StatelessWidget {
  OrderSelectGroup({ this.selected, this.orders, this.onSelected });
  final String selected;
  final List<Order> orders;
  final SelectedDisplayable onSelected;

  @override
  Widget build(BuildContext context) => DisplayableGroupList(
    '排序',
    columnCount: orders.length,
    children: orders.map((order) =>
      DisplayableButton(
        item: order,
        onPressed: () {
          if (onSelected == null) return;
          onSelected(order);
        },
        selected: order.linkBase == selected,
      )).toList(),
  );
}

class DisplayableGroupList extends StatelessWidget {
  DisplayableGroupList(this.title, { this.columnCount, this.children });

  final String title;
  final int columnCount;
  final List<Widget> children;

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
          child: Text(title, style: const TextStyle(fontSize: 18.0)),
        ),
        Container(
          width: 600.0,
          child: _GridList(
            columnCount: columnCount,
            children: children,
          ),
        ),
      ],
    )
  );
}

class DisplayableButton extends StatelessWidget {
  DisplayableButton({
    @required this.item,
    VoidCallback onPressed,
    bool selected = false,
    bool disabled = false,
    this.fontSize = 18.0,
  })
  : color = selected ? Colors.deepOrange[800] : Colors.orange[700]
  , textColor = disabled ? Colors.grey[500] : selected ? Colors.white : Colors.brown[700]
  , onPressed = disabled ? null : onPressed
  ;

  final VoidCallback onPressed;
  final Displayable item;
  final Color color, textColor;
  final double fontSize;

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
          item.display,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      ),
    ),
  );
}

Widget _wrap(Widget w) => Expanded(
  child: w ?? Visibility(
    child: const Text(''),
    visible: false,
  ),
  flex: 1,
);

class _GridList extends StatelessWidget {
  static List<List<Widget>> _buildRows(int count, List items) {
    final padding = count - (items.length % count);
    final widgets = ((List<Widget>.from(items) + List<Widget>.filled(padding, null))
      .map(_wrap)).toList();
    return List.generate(
      (items.length + padding) ~/ count,
      (i) => widgets.sublist(i * count, (i + 1) * count),
    );
  }

  _GridList({
    @required int columnCount,
    @required List<Widget> children,
    this.axisAlignment = MainAxisAlignment.spaceBetween
  })
    : this.rows = _buildRows(columnCount, children)
    ;

  final List<List<Widget>> rows;
  final MainAxisAlignment axisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: rows.map((columns) => Row(
      mainAxisAlignment: axisAlignment,
      children: columns,
    )).toList(),
  );
}
