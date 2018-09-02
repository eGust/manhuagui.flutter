import 'package:flutter/material.dart';

Widget _wrap(Widget w) => Expanded(
  child: w ?? Visibility(
    child: const Text(''),
    visible: false,
  ),
  flex: 1,
);

class GridList extends StatelessWidget {
  static List<List<Widget>> _buildRows(int count, List items) {
    final padding = count - (items.length % count);
    final widgets = ((List<Widget>.from(items) + List<Widget>.filled(padding, null))
      .map(_wrap)).toList();
    return List.generate(
      (items.length + padding) ~/ count,
      (i) => widgets.sublist(i * count, (i + 1) * count),
    );
  }

  GridList({
    @required int columnCount,
    @required List<Widget> children,
    this.axisAlignment = MainAxisAlignment.spaceBetween
  })
    : this.rows = _buildRows(columnCount, children)
    ;

  final List<List<Widget>> rows;
  final MainAxisAlignment axisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: rows.map((columns) => Row(
      mainAxisAlignment: axisAlignment,
      children: columns,
    )).toList(),
  );
}
