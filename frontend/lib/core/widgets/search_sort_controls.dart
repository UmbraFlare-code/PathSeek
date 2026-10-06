import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Campo de busqueda + selector de ordenamiento (responsive).
class SearchSortControls<T> extends StatelessWidget {
  const SearchSortControls({
    super.key,
    required this.queryController,
    required this.hint,
    required this.sortItems,
    required this.sortValue,
    required this.onQueryChanged,
    required this.onSortChanged,
  });

  final TextEditingController queryController;
  final String hint;
  final Map<T, String> sortItems;
  final T sortValue;
  final VoidCallback onQueryChanged;
  final ValueChanged<T> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: queryController,
      onChanged: (_) => onQueryChanged(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: queryController,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Limpiar busqueda',
                  icon: const Icon(Icons.clear),
                  onPressed: queryController.clear,
                ),
        ),
        isDense: true,
      ),
    );

    final sort = DropdownButton<T>(
      value: sortValue,
      items: sortItems.entries
          .map(
            (entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onSortChanged(value);
      },
    );

    if (isNarrow(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [search, const SizedBox(height: 8), sort],
      );
    }

    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: 16),
        sort,
      ],
    );
  }
}
