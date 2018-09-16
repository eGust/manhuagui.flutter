import 'package:flutter/material.dart';

import '../../models.dart';

class ActionSection extends StatelessWidget {
  ActionSection(this.comic);

  final ComicBook comic;

  @override
  Widget build(BuildContext context) => Container(
    height: 48.0,
    color: Colors.grey[200],
  );
}
