import 'package:flutter/material.dart';

import '../../models.dart';

class ActionSection extends StatelessWidget {
  ActionSection(this.comic, {
    @required this.onToggleFavorite,
    @required this.favorite,
  });

  final ComicBook comic;
  final VoidCallback onToggleFavorite;
  final int favorite;

  @override
  Widget build(BuildContext context) => Container(
    height: 44.0,
    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
    color: Colors.grey[200],
    child: Row(
      children: <Widget>[
        GestureDetector(
          onTap: onToggleFavorite,
          child: Container(
            width: 50.0,
            padding: favorite == -1 ? const EdgeInsets.only(left: 10.0, right: 10.0) : null,
            child: favorite == -1 ?
              const SizedBox(height: 30.0, child: const CircularProgressIndicator()) : favorite == 1 ?
              const Icon(Icons.favorite, color: Colors.red, size: 36.0) :
              const Icon(Icons.favorite_border, color: Colors.orange, size: 36.0),
          ),
        ),
        Container(width: 12.0),
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
