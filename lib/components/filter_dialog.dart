import 'package:flutter/material.dart';

import './filter_group_list.dart';
import '../models.dart';

typedef _PinChanged = void Function(bool);

class DialogTopBar extends StatefulWidget {
  DialogTopBar(this.title, {this.pinned = true, this.onPinChanged});

  final String title;
  final bool pinned;
  final _PinChanged onPinChanged;

  @override
  _DialogTopBarState createState() =>
      _DialogTopBarState(title, pinned, onPinChanged);
}

class _DialogTopBarState extends State<DialogTopBar> {
  _DialogTopBarState(this._title, bool pinned, this._onPinChanged)
      : _pinned = pinned;
  final String _title;
  final _PinChanged _onPinChanged;
  bool _pinned;

  void onPressed() {
    setState(() {
      _pinned = !_pinned;
    });
    if (_onPinChanged != null) {
      _onPinChanged(_pinned);
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _onPinChanged == null
            ? [
                Text(_title),
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
                    color: _pinned ? Colors.white : Colors.grey[700],
                  ),
                  color: _pinned ? Colors.orange[900] : Colors.transparent,
                  onPressed: onPressed,
                ),
                Text(_title),
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
  _DialogBodyState createState() => _DialogBodyState(this);
}

class _DialogBodyState extends State<DialogBody> {
  _DialogBodyState(this.data);

  final DialogBody data;

  void _onSelectedFilter(FilterGroup group, String link) {
    final grp = group.key;
    setState(() {
      if (data.selected[grp] == link) {
        data.selected[grp] = null;
      } else {
        data.selected[grp] = link;
      }
    });

    if (data.onSelectedFilter != null) data.onSelectedFilter();
  }

  void _onSelectedOrder(Displayable order) {
    final newOrder = order.value;
    if (data.selected['order'] == newOrder) return;
    setState(() {
      data.selected['order'] = newOrder;
    });
  }

  List<Widget> buildFilters(columnCount) =>
      List.from(data.groups.map((fg) => FilterGroupList(
            fg,
            data.selected[fg.key],
            onSelectedFilter: _onSelectedFilter,
            blacklist: data.blacklist,
            columnCount: columnCount,
          )));

  List<Widget> buildFiltersWithOrder() {
    final list = buildFilters(7);
    list.add(OrderSelectGroup(
      selected: data.selected['order'],
      orders: data.orders,
      onSelected: _onSelectedOrder,
    ));
    return list;
  }

  @override
  Widget build(BuildContext context) => Column(
      children:
          data.orders == null ? buildFilters(5) : buildFiltersWithOrder());
}
