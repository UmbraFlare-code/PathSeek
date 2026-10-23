import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/record_details.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/driver.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({
    super.key,
    required this.driver,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
  });
  final Driver driver;
  final ValueChanged<Driver> onEdit, onDelete;
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
                Icons.person_outline,
                color: AppTheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'DNI: ${driver.dni}',
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
            label: driver.disponible ? 'Disponible' : 'No disponible',
            icon: driver.disponible
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline,
            tone: driver.disponible ? StatusTone.success : StatusTone.neutral,
          ),
          const SizedBox(height: 20),
          RecordDetails(
            items: {
              'Licencia': driver.licencia,
              'Categoría': driver.categoria,
              'Experiencia':
                  '${Formatters.integer.format(driver.experiencia)} años',
              'Contacto': driver.contacto ?? 'Sin contacto',
            },
          ),
          RecordActions(
            onEdit: canEdit ? () => onEdit(driver) : null,
            onDelete: canDelete ? () => onDelete(driver) : null,
          ),
        ],
      ),
    ),
  );
}
