import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/driver.dart';

class DriverTable extends StatelessWidget {
  const DriverTable({
    super.key,
    required this.drivers,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });

  final List<Driver> drivers;
  final ValueChanged<Driver> onEdit;
  final ValueChanged<Driver> onDelete;
  final bool canEdit;
  final bool canDelete;

  bool get _showActions => canEdit || canDelete;

  @override
  Widget build(BuildContext context) {
    final headers = [
      'DNI',
      'Nombre',
      'Licencia',
      'Categoria',
      'Experiencia',
      'Disponible',
      'Contacto',
      if (_showActions) 'Acciones',
    ];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: drivers.map((driver) {
            return DataRow(
              cells: [
                DataCell(Text(driver.dni)),
                DataCell(Text(driver.nombre)),
                DataCell(Text(driver.licencia)),
                DataCell(Text(driver.categoria)),
                DataCell(Text(
                  '${Formatters.integer.format(driver.experiencia)} anios',
                )),
                DataCell(
                  Icon(
                    driver.disponible
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: driver.disponible
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                DataCell(Text(driver.contacto ?? '-')),
                if (_showActions)
                  DataCell(
                    Row(
                      children: [
                        if (canEdit)
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => onEdit(driver),
                          ),
                        if (canDelete)
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _confirmDelete(context, driver),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Driver driver) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar conductor'),
        content: Text(
          'Seguro que desea eliminar al conductor ${driver.nombre} (${driver.dni})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(driver);
    }
  }
}
