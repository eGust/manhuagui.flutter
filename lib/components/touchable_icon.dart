import 'package:flutter/material.dart';

class TouchableIcon extends StatelessWidget {
  TouchableIcon(this.icon, {
    this.size,
    this.color,
    this.onPressed,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => GestureDetector(
    child: Icon(icon, color: color, size: size),
    onTap: onPressed,
  );
}
