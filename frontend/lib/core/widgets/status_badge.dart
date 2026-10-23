import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusTone { neutral, info, success, warning, danger }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    this.tone = StatusTone.neutral,
  });
  final String label;
  final IconData icon;
  final StatusTone tone;
  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.info => (AppTheme.info, AppTheme.infoSurface),
      StatusTone.success => (AppTheme.success, AppTheme.successSurface),
      StatusTone.warning => (AppTheme.warning, AppTheme.warningSurface),
      StatusTone.danger => (AppTheme.danger, AppTheme.dangerSurface),
      StatusTone.neutral => (AppTheme.mutedText, AppTheme.mutedSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 16, color: foreground)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
