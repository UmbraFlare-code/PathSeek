import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pathseek/core/constants/app_roles.dart';
import 'package:pathseek/core/constants/permissions.dart';
import 'package:pathseek/core/di/injection.dart';
import 'package:pathseek/core/widgets/catalog_layout.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';
import 'package:pathseek/features/clients/presentation/bloc/clients_bloc.dart';

class ClientsListPage extends StatelessWidget {
  const ClientsListPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider<ClientsBloc>(
        create: (_) => locator<ClientsBloc>()..add(const ClientsLoaded()),
        child: const ClientsListView(),
      );
}

class ClientsListView extends StatelessWidget {
  const ClientsListView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ClientsBloc, ClientsState>(
    builder: (context, state) {
      final user = context.watch<AuthBloc>().state.user;
      final canCreate = AppPermissions.canCreate(user, AppModule.clients);
      final canDelete = AppPermissions.canDelete(user, AppModule.clients);
      return CatalogLayout(
        title: 'Clientes',
        description: user?.rol == AppRoles.cliente
            ? 'Tu perfil y preferencias de entrega.'
            : 'Preferencias de entrega de los clientes de UGEL Huancayo.',
        icon: Icons.storefront_outlined,
        actions: [
          if (canCreate)
            FilledButton.icon(
              onPressed: () => context.push('/clients/new'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo cliente'),
            ),
        ],
        isLoading: state.isLoading,
        loadingMessage: 'Cargando clientes…',
        emptyMessage: user?.rol == AppRoles.cliente
            ? 'Aún no tienes un perfil de cliente. Crea el tuyo para registrar tus preferencias.'
            : 'No hay clientes registrados.',
        errorMessage: state.errorMessage,
        onRetry: () =>
            context.read<ClientsBloc>().add(const ClientsLoaded()),
        itemCount: state.clients.length,
        totalCount: state.clients.length,
        itemBuilder: (context, index) {
          final client = state.clients[index];
          return _ClientCard(
            client: client,
            canEdit: user?.rol == AppRoles.cliente ||
                AppPermissions.canUpdate(user, AppModule.clients),
            canDelete: canDelete,
          );
        },
      );
    },
  );
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.client,
    required this.canEdit,
    required this.canDelete,
  });

  final ClientProfile client;
  final bool canEdit;
  final bool canDelete;

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
                Icon(Icons.storefront, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(client.nombre, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (client.direccion != null) Text('Dirección: ${client.direccion}'),
            if (client.puntoReferencia != null)
              Text('Referencia: ${client.puntoReferencia}'),
            if (client.telefono != null) Text('Teléfono: ${client.telefono}'),
            const SizedBox(height: 4),
            Text(
              'Atención: ${client.horarioLabel}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            if (client.restriccionesAcceso != null) ...[
              const SizedBox(height: 8),
              Text(
                'Restricciones: ${client.restriccionesAcceso}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (canEdit || canDelete) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canEdit)
                    TextButton.icon(
                      onPressed: () => context.push(
                        '/clients/${client.id}/edit',
                        extra: client,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  if (canDelete) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, client),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ClientProfile client,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Eliminar el perfil de "${client.nombre}"? Los pedidos históricos no se modifican.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ClientsBloc>().add(ClientDeleted(client.id));
    }
  }
}
