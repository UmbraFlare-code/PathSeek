import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/record_details.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/vehicle.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });
  final Vehicle vehicle;
  final ValueChanged<Vehicle> onEdit, onDelete;
  final bool canEdit, canDelete;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.placa,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      vehicle.tipo,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatusBadge(
            label: vehicle.anio?.toString() ?? 'Sin año',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 20),
          RecordDetails(
            items: {
              'Capacidad de peso':
                  '${vehicle.capacidadKg.toStringAsFixed(0)} kg',
              'Capacidad de volumen':
                  '${vehicle.capacidadM3.toStringAsFixed(1)} m³',
              'Consumo':
                  '${Formatters.decimal.format(vehicle.consumoKmL)} km/L',
              'Factor de emisión':
                  '${Formatters.decimal.format(vehicle.factorEmision)} kg CO2/km',
            },
          ),
          RecordActions(
            onEdit: canEdit ? () => onEdit(vehicle) : null,
            onDelete: canDelete ? () => onDelete(vehicle) : null,
          ),
        ],
      ),
    ),
  );
}
