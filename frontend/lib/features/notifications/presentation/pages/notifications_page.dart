import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pathseek/core/widgets/catalog_layout.dart';
import 'package:pathseek/core/widgets/status_badge.dart';
import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';
import 'package:pathseek/features/notifications/presentation/bloc/notifications_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.isConductor,
  });

  final bool isConductor;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return CatalogLayout(
          title: 'Avisos de rutas',
          description: widget.isConductor
              ? 'Incidentes y cambios de tu ruta asignada. Marca como leído lo que ya revisaste.'
              : 'Avisos generados por la reoptimización de rutas.',
          icon: Icons.notifications_outlined,
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              onPressed: () => context
                  .read<NotificationsBloc>()
                  .add(const NotificationsLoaded()),
              icon: const Icon(Icons.refresh),
            ),
          ],
          isLoading: state.isLoading,
          loadingMessage: 'Cargando avisos…',
          emptyMessage: 'No hay avisos registrados.',
          errorMessage: state.errorMessage,
          onRetry: () =>
              context.read<NotificationsBloc>().add(const NotificationsLoaded()),
          itemCount: state.notifications.length,
          totalCount: state.notifications.length,
          itemBuilder: (context, index) {
            final notification = state.notifications[index];
            return _NotificationCard(
              notification: notification,
              canMarkRead: widget.isConductor,
            );
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.canMarkRead,
  });

  final RouteNotification notification;
  final bool canMarkRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.mensaje,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: notification.leida
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: notification.leida ? 'Leído' : 'Nuevo',
                  icon: notification.leida
                      ? Icons.done_outlined
                      : Icons.fiber_new_outlined,
                  tone: notification.leida
                      ? StatusTone.neutral
                      : StatusTone.info,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.createdAt != null
                  ? DateFormat.yMMMd('es').add_Hm().format(
                        notification.createdAt!.toLocal(),
                      )
                  : 'Fecha no disponible',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (canMarkRead && !notification.leida) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.read<NotificationsBloc>().add(
                        NotificationMarkedRead(notification.id),
                      ),
                  icon: const Icon(Icons.done_outlined, size: 18),
                  label: const Text('Marcar como leído'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
