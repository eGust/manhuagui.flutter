import 'package:flutter/material.dart';

import './side_bar.dart';
import '../filter_group_list.dart';
import '../../store.dart';
import '../../models.dart';
import '../../utils.dart';

typedef ComicFilterSelected = void Function(String filter, String order);

class ComicList extends StatefulWidget {
  ComicList(this.router) :
    this.filterSelector = globals.metaData.createComicSelector(
      order: pathOrderMap[router.path],
    );

  final SubRouter router;
  final FilterSelector filterSelector;

  static const Map<String, String> pathOrderMap = {
    'comic_category': 'index',
    'comic_rank':     'view',
    'comic_update':   'update',
  };

  @override
  _ComicListState createState() => _ComicListState(router.label, filterSelector);
}

class _ComicListState extends State<ComicList> {
  _ComicListState(this.title, this.filterSelector);

  final String title;
  final FilterSelector filterSelector;
  bool _pending = true;

  void _quickSelectFilter(Duration _) async {
    final link = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              FlatButton(
                child: Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
            ],
          ),
        ),
        children: [
          Container(
            child: Column(
              children: filterSelector.meta.filterGroups
              .map((fg) => FilterGroupList(fg, (link) {
                Navigator.pop(context, link);
              })).toList(),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() {
      filterSelector.selectFilter(link: link);
      _pending = false;
    });
  }

  @override
  void initState() {
    super.initState();
    filterSelector.filters.clear();
    WidgetsBinding.instance.addPostFrameCallback(_quickSelectFilter);
  }

  @override
  Widget build(BuildContext context) => _pending ? Container() : Container();
}
