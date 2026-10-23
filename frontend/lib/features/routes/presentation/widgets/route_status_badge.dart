import 'package:flutter/material.dart';
import '../../../../core/widgets/status_badge.dart';

class RouteStatusBadge extends StatelessWidget {
  const RouteStatusBadge({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final (label, icon, tone) = switch (status) {
      'PLANIFICADA' => (
        'Planificada',
        Icons.event_note_outlined,
        StatusTone.info,
      ),
      'EN_PROGRESO' => (
        'En progreso',
        Icons.local_shipping_outlined,
        StatusTone.warning,
      ),
      'COMPLETADA' => (
        'Completada',
        Icons.check_circle_outline,
        StatusTone.success,
      ),
      'CANCELADA' => ('Cancelada', Icons.cancel_outlined, StatusTone.danger),
      _ => (status, Icons.info_outline, StatusTone.neutral),
    };
    return StatusBadge(label: label, icon: icon, tone: tone);
  }
}
