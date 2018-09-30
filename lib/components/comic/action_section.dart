import 'package:flutter/material.dart';

import '../../models.dart';

class ActionSection extends StatelessWidget {
  ActionSection(this.comic);

  final ComicBook comic;

  @override
  Widget build(BuildContext context) => Container(
    height: 44.0,
    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
    color: Colors.grey[200],
    child: Row(
      children: <Widget>[
        GestureDetector(
          child: Container(
            width: 50.0,
            child: comic.isFavorite ?
              const Icon(Icons.favorite, color: Colors.red, size: 36.0) :
              const Icon(Icons.favorite_border, color: Colors.orange, size: 36.0),
          ),
        ),
        Container(width: 20.0),
        Expanded(
          child: RawMaterialButton(
            fillColor: Colors.orange[900],
            splashColor: Colors.brown[900],
            child: const Text('开始阅读', style: const TextStyle(color: Colors.white, fontSize: 17.0)),
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}
