import 'package:flutter/material.dart';

import 'filter_group_list.dart';
import '../models.dart';

typedef _PinChanged = void Function(bool);

class DialogTopBar extends StatefulWidget {
  DialogTopBar(this.title, {this.pinned = true, this.onPinChanged});

  final String title;
  final bool pinned;
  final _PinChanged onPinChanged;

  @override
  _DialogTopBarState createState() => _DialogTopBarState(pinned);
}

class _DialogTopBarState extends State<DialogTopBar> {
  _DialogTopBarState(bool pinned) : _pinned = pinned;
  bool _pinned;

  void onPressed() {
    setState(() {
      _pinned = !_pinned;
    });
    if (widget.onPinChanged != null) {
      widget.onPinChanged(_pinned);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.onPinChanged == null
            ? [
                Text(widget.title),
                FlatButton(
                  child: Icon(Icons.check),
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                ),
              ]
            : [
                FlatButton(
                  child: Icon(
                    _pinned ? Icons.lock : Icons.lock_open,
                    color: Colors.grey[700],
                  ),
                  onPressed: onPressed,
                ),
                Text(widget.title),
                FlatButton(
                  child: Icon(Icons.check),
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                ),
              ],
      );
}

class DialogBody extends StatefulWidget {
  DialogBody(this.groups, this.selected,
      {this.onSelectedFilter, this.blacklist, this.orders});

  final Map<String, String> selected;
  final List<FilterGroup> groups;
  final VoidCallback onSelectedFilter;
  final Set<String> blacklist;
  final List<Order> orders;

  @override
  _DialogBodyState createState() => _DialogBodyState();
}

class _DialogBodyState extends State<DialogBody> {
  _DialogBodyState();

  void _onSelectedFilter(FilterGroup group, String link) {
    final grp = group.key;
    setState(() {
      if (widget.selected[grp] == link) {
        widget.selected[grp] = null;
      } else {
        widget.selected[grp] = link;
      }
    });

    if (widget.onSelectedFilter != null) widget.onSelectedFilter();
  }

  void _onSelectedOrder(Displayable order) {
    final newOrder = order.value;
    if (widget.selected['order'] == newOrder) return;
    setState(() {
      widget.selected['order'] = newOrder;
    });
  }

  List<Widget> buildFilters(columnCount) =>
      List.from(widget.groups.map((fg) => FilterGroupList(
            fg,
            widget.selected[fg.key],
            onSelectedFilter: _onSelectedFilter,
            blacklist: widget.blacklist,
            columnCount: columnCount,
          )));

  List<Widget> buildFiltersWithOrder() {
    final list = buildFilters(4);
    list.add(OrderSelectGroup(
      selected: widget.selected['order'],
      orders: widget.orders,
      onSelected: _onSelectedOrder,
    ));
    return list;
  }

  @override
  Widget build(BuildContext context) => Column(
      children:
          widget.orders == null ? buildFilters(4) : buildFiltersWithOrder());
}
