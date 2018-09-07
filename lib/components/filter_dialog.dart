import 'package:flutter/material.dart';

import './filter_group_list.dart';
import '../models.dart';

typedef _PinChanged = void Function(bool);

class DialogTopBar extends StatefulWidget {
  DialogTopBar(this.title, this.pinned, { this.onPinChanged });

  final String title;
  final bool pinned;
  final _PinChanged onPinChanged;

  @override
  _DialogTopBarState createState() => _DialogTopBarState(title, pinned, onPinChanged);
}

class _DialogTopBarState extends State<DialogTopBar> {
  _DialogTopBarState(this._title, bool pinned, this._onPinChanged): _pinned = pinned;
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
    children: [
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
  DialogBody(this.groups, this.selected, { this.onSelectedFilter, this.blacklist });

  final Map<String, String> selected;
  final List<FilterGroup> groups;
  final VoidCallback onSelectedFilter;
  final Set<String> blacklist;

  @override
  _DialogBodyState createState() => _DialogBodyState(this);
}

class _DialogBodyState extends State<DialogBody> {
  _DialogBodyState(this.data);
  final DialogBody data;

  void selectedFilter(FilterGroup group, String link) {
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

  @override
  Widget build(BuildContext context) => Column(
    children: data.groups.map((fg) => FilterGroupList(
      fg,
      data.selected[fg.key],
      onSelectedFilter: selectedFilter,
      blacklist: data.blacklist,
    )).toList(),
  );
}
