import 'package:flutter/material.dart';

class TouchableIcon extends StatelessWidget {
  TouchableIcon(this.icon, {
    this.size,
    this.color,
    this.disabledColor,
    this.onPressed,
    this.disabled = false,
  });

  final IconData icon;
  final Color color, disabledColor;
  final bool disabled;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
    child: GestureDetector(
      child: Icon(
        icon,
        color: disabled ? disabledColor : color,
        size: size,
      ),
      onTap: disabled ? null : onPressed,
    ),
  );
}
