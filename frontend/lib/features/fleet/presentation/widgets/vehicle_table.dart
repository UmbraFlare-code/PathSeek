import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/vehicle.dart';

class VehicleTable extends StatelessWidget {
  const VehicleTable({
    super.key,
    required this.vehicles,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle> onEdit;
  final ValueChanged<Vehicle> onDelete;

  static const List<String> _headers = [
    'Placa',
    'Tipo',
    'Cap. (kg)',
    'Cap. (m3)',
    'Consumo (km/L)',
    'CO2 (kg/km)',
    'Anio',
    'Acciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _headers
              .map((header) => DataColumn(label: Text(header)))
              .toList(),
          rows: vehicles.map((vehicle) {
            return DataRow(
              cells: [
                DataCell(Text(vehicle.placa)),
                DataCell(Text(vehicle.tipo)),
                DataCell(Text(Formatters.decimal.format(vehicle.capacidadKg))),
                DataCell(Text(Formatters.decimal.format(vehicle.capacidadM3))),
                DataCell(Text(Formatters.decimal.format(vehicle.consumoKmL))),
                DataCell(
                  Text(Formatters.decimal.format(vehicle.factorEmision)),
                ),
                DataCell(Text('${vehicle.anio}')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => onEdit(vehicle),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _confirmDelete(context, vehicle),
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

  Future<void> _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar vehiculo'),
        content: Text(
          'Seguro que desea eliminar el vehiculo con placa ${vehicle.placa}?',
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
      onDelete(vehicle);
    }
  }
}
