import 'package:flutter/material.dart';

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
        labelText: 'Buscar',
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: queryController,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    queryController.clear();
                    onQueryChanged();
                  },
                ),
        ),
        isDense: true,
      ),
    );

    final sort = DropdownButtonFormField<T>(
      initialValue: sortValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Ordenar por',
        prefixIcon: Icon(Icons.sort),
      ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650 ||
            MediaQuery.textScalerOf(context).scale(16) > 22) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 8), sort],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 16),
            SizedBox(width: 260, child: sort),
          ],
        );
      },
    );
  }
}
