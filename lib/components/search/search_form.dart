import 'package:flutter/material.dart';

import '../../api.dart';
import '../../models.dart';
import '../../routes.dart';
import '../touchable_icon.dart';

typedef OnSearchCallback = void Function(String);

class SearchForm extends StatefulWidget {
  SearchForm(this.onSearch);
  final OnSearchCallback onSearch;
  @override
  _SearchFormState createState() => _SearchFormState(onSearch);
}

class _SearchFormState extends State<SearchForm> {
  _SearchFormState(this.onSearch);

  final OnSearchCallback onSearch;
  final _key = TextEditingController(text: '');

  @override
  void initState() {
    _key.addListener(_search);
    super.initState();
  }

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  bool _searching = false;
  int _actionId = 0;
  List<ComicCover> _covers = [];
  String _lastSearched = '';

  void _search() async {
    final key = _key.text;
    if (_lastSearched == key) return;

    _lastSearched = key;
    if (key.isEmpty) {
      setState(() {
        _searching = false;
        _covers = [];
      });
      return;
    }

    _actionId = (_actionId + 1) & 0x00FFFFFF;
    final currentAction = _actionId;
    setState(() {
      _searching = true;
      _covers = [];
    });
    final list = await searchPreview(_key.text);
    if (!mounted || currentAction != _actionId) return;

    setState(() {
      _searching = false;
      _covers = list.map((json) => ComicCover.fromSearchJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      // header
      Container(
        color: Colors.brown[900],
        child: Row(
          children: <Widget>[
            TouchableIcon(Icons.arrow_back_ios,
              color: Colors.white,
              onPressed: () { Navigator.pop(context); },
            ),
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: const Icon(Icons.search, size: 30.0, color: Colors.grey),
            ),
            Expanded(
              child: TextFormField(
                controller: _key,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '漫画名（支持拼音）',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: RaisedButton(
                color: Colors.red[900],
                textColor: Colors.white,
                child: const Text('搜索', style: const TextStyle(fontSize: 18.0)),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    ] + (_searching ? <Widget>[
      Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(30.0),
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(strokeWidth: 5.0),
        ),
      ),
    ] : List.from<Widget>(_covers.map((cover) => _SearchCover(cover)))),
  );
}

class _SearchCover extends StatelessWidget {
  _SearchCover(this.cover);
  final ComicCover cover;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      RouteHelper.replaceComic(context, cover);
    },
    child: Container(
      height: 53.0,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black)),
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 39.0,
            height: 52.0,
            child: Image.network(cover.getImageUrl(size: CoverSize.min)),
          ),
          Expanded(child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(cover.name, style: const TextStyle(fontSize: 16.0)),
                    Text(cover.finished ? '已完结' : '连载中', style: TextStyle(
                      color: cover.finished ? Colors.red[800] : Colors.green[800],
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(cover.lastUpdatedChapterTitle),
                    Text(cover.authors.map((a) => a.name).join(', ')),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    )
  );
}
