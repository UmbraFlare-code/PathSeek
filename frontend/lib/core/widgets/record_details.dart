import 'package:flutter/material.dart';

/// Readable catalog metadata; values remain available with enlarged text.
class RecordDetails extends StatelessWidget {
  const RecordDetails({super.key, required this.items});
  final Map<String, String> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth < 240 ||
              MediaQuery.textScalerOf(context).scale(16) > 22
          ? 1
          : 2;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: items.entries
            .map(
              (entry) => SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 16) / columns,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class RecordActions extends StatelessWidget {
  const RecordActions({super.key, this.onEdit, this.onDelete});
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (onEdit != null)
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Editar'),
              ),
            if (onDelete != null)
              TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Eliminar'),
              ),
          ],
        ),
      ],
    );
  }
}
