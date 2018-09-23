import 'dart:async';
import 'package:flutter/material.dart';

import './sub_router.dart';
import '../list_top_bar.dart';
import '../filter_dialog.dart';
import '../../store.dart';
import '../../models.dart';
import '../../routes.dart';

class RouteAuthor extends StatefulWidget {
  static final router = SubRouter(
    'author',
    Icons.people,
    () => RouteAuthor(),
    label: '漫画家',
  );

  @override
  _RouteAuthorState createState() => _RouteAuthorState();
}

class _RouteAuthorState extends State<RouteAuthor> {
  _RouteAuthorState()
    : this.filterSelector = globals.metaData.createAuthorSelector()
    ;

  final FilterSelector filterSelector;

  Future<bool> showDialogChanged(BuildContext context) async {
    final filters = Map<String, String>.from(filterSelector.filters);
    filters['order'] = filterSelector.order;

    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: DialogTopBar('查找作者'),
        children: [
          DialogBody(
            filterSelector.meta.filterGroups,
            filters,
            orders: filterSelector.meta.orders,
          ),
        ],
      ),
    );

    final oldFilterPath = filterSelector.fullPath;
    filterSelector.order = filters.remove('order');
    filters.forEach((group, link) {
      filterSelector.selectFilter(link: link, group: group);
    });
    return oldFilterPath != filterSelector.fullPath;
  }

  bool _fetching = false;
  List<AuthorCover> authors = [];
  Set<int> authorIds = Set();

  Future<void> _refresh({ bool indicator = true }) async {
    if (!mounted || _fetching) return;
    setState(() {
      authors.clear();
      authorIds.clear();
      _fetching = true;
    });
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (filterSelector.isLastPage) return;
    setState(() {
      _fetching = true;
    });

    final doc = await filterSelector.fetchDom();
    final covers = AuthorCover.parseDesktop(doc)
      .where((auth) => !authorIds.contains(auth.updatedAt))
      .toList()
      ;
    filterSelector.page += 1;

    if (!mounted) return;
    setState(() {
      _fetching = false;
      authors.addAll(covers);
      authorIds.addAll(covers.map((c) => c.authorId));
    });
  }

  void _initialized(Duration _) async {
    await showDialogChanged(context);
    _refresh();
  }

  static const _NEXT_THRESHOLD = 1500.0;

  @override
  void initState() {
    super.initState();
    _scroller.addListener(() {
      if (_scroller.position.pixels + _NEXT_THRESHOLD > _scroller.position.maxScrollExtent) {
        if (_fetching || !mounted) return;
        _fetchNextPage();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(_initialized);
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  String filtersTitle() {
    final s = filterSelector.meta
      .filterGroups
      .map((grp) => filterSelector.filters[grp.key])
      .where((s) => s != null)
      .map((link) => filterSelector.meta.linkTitleMap[link])
      .join(', ');
    return s.isEmpty ? '全部' : s;
  }

  ScrollController _scroller = ScrollController();

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ListTopBar(
        blacklistEnabled: false,
        filtersTitle: '${filtersTitle()} (${filterSelector.currentOrder.title})',
        onPressedScrollTop: () {
          _scroller.animateTo(
            0.1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
          );
        },
        onPressedRefresh: _refresh,
        onPressedFilters: () async {
          if (_fetching) return;
          if (await showDialogChanged(context)) {
            _refresh();
          }
        },
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () => _refresh(indicator: false),
          child: GridView.builder(
            controller: _scroller,
            // gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.0,
            ),
            itemCount: authors.length,
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (_, i) => AuthorCard(authors[i]),
          ),
        ),
      ),
    ],
  );
}

class AuthorCard extends StatelessWidget {
  AuthorCard(this.author);
  final AuthorCover author;

  @override
  Widget build(BuildContext context) => Card(
    child: GestureDetector(
      onTap: () {
        RouteHelper.navigateAuthor(context, author);
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(author.name,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(author.region),
                Row(
                  children: <Widget>[
                    const Text('共 '),
                    Text(' ${author.comicCount} ', style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                    )),
                    const Text(' 部作品'),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('更新: ${author.updatedAt}'),
                Text(author.score),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
