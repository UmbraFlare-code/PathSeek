import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Distribuye los campos en fila (escritorio) o apilados (telefono).
class ResponsiveFieldRow extends StatelessWidget {
  const ResponsiveFieldRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (isNarrow(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
