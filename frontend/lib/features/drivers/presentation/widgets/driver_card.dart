import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
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
  final ValueChanged<Driver> onEdit;
  final ValueChanged<Driver> onDelete;
  final bool canEdit;
  final bool canDelete;

  bool get _showActions => canEdit || canDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: driver.disponible
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.12),
                  child: Icon(
                    driver.disponible ? Icons.person : Icons.person_off,
                    color: driver.disponible
                        ? AppTheme.primary
                        : Theme.of(context).colorScheme.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textHighContrast,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        driver.dni,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424940),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (driver.disponible ? AppTheme.primary : Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    driver.disponible ? 'DISPONIBLE' : 'NO DISPONIBLE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: driver.disponible
                          ? AppTheme.primaryDark
                          : const Color(0xFF424940),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MetricRow(
              items: [
                _Metric(label: 'Licencia', value: driver.licencia),
                _Metric(label: 'Categoria', value: driver.categoria),
                _Metric(
                  label: 'Experiencia',
                  value:
                      '${Formatters.integer.format(driver.experiencia)} anios',
                ),
                _Metric(label: 'Contacto', value: driver.contacto ?? '-'),
              ],
            ),
            if (_showActions) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canEdit)
                    TextButton.icon(
                      onPressed: () => onEdit(driver),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  if (canDelete)
                    TextButton.icon(
                      onPressed: () => onDelete(driver),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'Eliminar',
                        style:
                            TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items});

  final List<_Metric> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[i].value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHighContrast,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  items[i].label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF727970),
                  ),
                ),
              ],
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Metric {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;
}
