import 'package:flutter/material.dart';

class FastStatus extends StatelessWidget {
  FastStatus(this.text);

  final String text;
  @override
  Widget build(BuildContext context) => Positioned(
    right: 0.0,
    bottom: 0.0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
      color: Color.fromARGB(200, 40, 40, 40),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
    ),
  );
}
