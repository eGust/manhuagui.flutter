import 'package:flutter/material.dart';

import '../store.dart';
import '../models.dart';
import '../utils.dart';
import '../routes.dart';

class AuthorScreen extends StatefulWidget {
  AuthorScreen(this.author);

  final AuthorLink author;

  @override
  _AuthorScreenState createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  @override
  Widget build(BuildContext context) => Container(child: Text(''));
}
