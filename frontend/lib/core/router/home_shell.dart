import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/routes/domain/repositories/route_repository.dart';
import '../constants/permissions.dart';
import '../di/injection.dart';
import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final size = MediaQuery.sizeOf(context);
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
    final sidebar = size.width >= 1100 && size.height >= 560 && !largeText;
    final destinations = _destinationsFor(user);
    final bottom =
        size.width < 600 &&
        size.height >= 500 &&
        !largeText &&
        destinations.length <= 5;
    final location = GoRouterState.of(context).uri.path;
    final selected = destinations.indexWhere(
      (d) => d.path == '/'
          ? location == '/'
          : location == d.path || location.startsWith('${d.path}/'),
    );
    final activeIndex = selected < 0 ? 0 : selected;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.route_outlined,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'PathSeek',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        actions: [
          if (user != null) const _NotificationsBell(),
          if (user != null && size.width >= 600)
            Tooltip(
              message: '${user.nombre} · ${_roleLabel(user.rol)}',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width >= 1100 ? 280 : 180,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        _roleLabel(user.rol),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: sidebar || bottom
          ? null
          : Drawer(
              child: SafeArea(
                child: _NavigationPanel(
                  user: user,
                  destinations: destinations,
                  selected: activeIndex,
                  drawer: true,
                ),
              ),
            ),
      body: Column(
        children: [
          const _ConnectivityBanner(),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: !bottom,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sidebar) ...[
                    SizedBox(
                      width: 240,
                      child: Material(
                        color: Colors.white,
                        child: _NavigationPanel(
                          user: user,
                          destinations: destinations,
                          selected: activeIndex,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1520),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottom && destinations.isNotEmpty
          ? destinations.length == 1
                ? SafeArea(
                    top: false,
                    child: Material(
                      color: Colors.white,
                      child: ListTile(
                        selected: true,
                        leading: Icon(destinations.first.outlined),
                        title: Text(destinations.first.label),
                        onTap: () => context.go(destinations.first.path),
                      ),
                    ),
                  )
                : NavigationBar(
                    selectedIndex: activeIndex,
                    onDestinationSelected: (index) =>
                        context.go(destinations[index].path),
                    destinations: destinations
                        .map(
                          (d) => NavigationDestination(
                            icon: Icon(d.outlined),
                            selectedIcon: Icon(d.filled),
                            label: d.label,
                          ),
                        )
                        .toList(),
                  )
          : null,
    );
  }
}

class _NotificationsBell extends StatefulWidget {
  const _NotificationsBell();

  @override
  State<_NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<_NotificationsBell> {
  NotificationsBloc? _bloc;
  StreamSubscription<NotificationsState>? _subscription;

  @override
  void initState() {
    super.initState();
    if (!locator.isRegistered<NotificationsBloc>()) return;
    _bloc = locator<NotificationsBloc>()..add(const NotificationsLoaded());
    _subscription = _bloc!.stream.listen((state) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return IconButton(
        tooltip: 'Avisos de rutas',
        onPressed: () => context.go('/notifications'),
        icon: const Icon(Icons.notifications_outlined),
      );
    }
    final unread = bloc.state.notifications
        .where((notification) => !notification.leida)
        .length;
    return IconButton(
      tooltip: 'Avisos de rutas',
      onPressed: () {
        bloc.add(const NotificationsLoaded());
        context.go('/notifications');
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _ConnectivityBanner extends StatefulWidget {
  const _ConnectivityBanner();

  @override
  State<_ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<_ConnectivityBanner> {
  StreamSubscription<bool>? _subscription;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    if (!locator.isRegistered<ConnectivityService>()) return;
    final service = locator<ConnectivityService>();
    service.isOnline().then((online) {
      if (mounted) setState(() => _offline = !online);
      if (online) {
        _flushQueue(showFeedback: false);
      }
    });
    _subscription = service.onlineStream.listen((online) {
      final wasOffline = _offline;
      if (mounted) setState(() => _offline = !online);
      if (online && wasOffline) {
        _flushQueue();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _flushQueue({bool showFeedback = true}) async {
    try {
      final synced = await locator<RouteRepository>().flushOfflineQueue();
      if (synced > 0 && showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conexión recuperada: $synced acción(es) sincronizada(s).',
            ),
          ),
        );
      }
    } catch (_) {
      // El reintento ocurre en el siguiente cambio de conectividad.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 18,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sin conexión: se muestran datos guardados y las acciones quedan en cola.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationPanel extends StatelessWidget {
  const _NavigationPanel({
    required this.user,
    required this.destinations,
    required this.selected,
    this.drawer = false,
  });
  final AppUser? user;
  final List<_Destination> destinations;
  final int selected;
  final bool drawer;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      if (drawer) ...[
        Text('PathSeek', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        if (user != null)
          Text(
            '${user!.nombre}\n${_roleLabel(user!.rol)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const Divider(height: 32),
      ],
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Text(
          'ESPACIO DE TRABAJO',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.mutedText),
        ),
      ),
      for (var i = 0; i < destinations.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            selected: i == selected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(
              i == selected ? destinations[i].filled : destinations[i].outlined,
            ),
            title: Text(
              destinations[i].label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            onTap: () {
              if (drawer) Navigator.of(context).pop();
              context.go(destinations[i].path);
            },
          ),
        ),
      const Divider(height: 32),
      TextButton.icon(
        onPressed: () async {
          final url = Uri.base.resolve('/downloads/pathseek.apk');
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              await launchUrl(url, mode: LaunchMode.platformDefault);
            }
          } catch (_) {
            await launchUrl(url, mode: LaunchMode.platformDefault);
          }
        },
        icon: const Icon(Icons.android_outlined),
        label: const Text('Descargar app móvil'),
      ),
    ],
  );
}

String _roleLabel(String role) => switch (role) {
  'ADMIN' => 'Administrador',
  'OPERADOR' => 'Operador',
  'AUDITOR' => 'Auditor',
  'CONDUCTOR' => 'Conductor',
  'CLIENTE' => 'Cliente',
  _ => role,
};

class _Destination {
  const _Destination(this.path, this.label, this.outlined, this.filled);
  final String path, label;
  final IconData outlined, filled;
}

List<_Destination> _destinationsFor(AppUser? user) => [
  if (AppPermissions.canView(user, AppModule.dashboard))
    const _Destination(
      '/',
      'Resumen',
      Icons.dashboard_outlined,
      Icons.dashboard,
    ),
  if (AppPermissions.canView(user, AppModule.fleet))
    const _Destination(
      '/fleet',
      'Flota',
      Icons.local_shipping_outlined,
      Icons.local_shipping,
    ),
  if (AppPermissions.canView(user, AppModule.drivers))
    const _Destination(
      '/drivers',
      'Conductores',
      Icons.badge_outlined,
      Icons.badge,
    ),
  if (AppPermissions.canView(user, AppModule.orders))
    const _Destination(
      '/orders',
      'Pedidos',
      Icons.inventory_2_outlined,
      Icons.inventory_2,
    ),
  if (AppPermissions.canView(user, AppModule.clients))
    _Destination(
      '/clients',
      user?.rol == 'CLIENTE' ? 'Mis preferencias' : 'Clientes',
      Icons.storefront_outlined,
      Icons.storefront,
    ),
  if (AppPermissions.canView(user, AppModule.routes))
    const _Destination('/routes', 'Rutas', Icons.route_outlined, Icons.route),
  if (user != null &&
      ['ADMIN', 'OPERADOR', 'AUDITOR'].contains(user.rol))
    const _Destination(
      '/reports',
      'Reportes',
      Icons.picture_as_pdf_outlined,
      Icons.picture_as_pdf,
    ),
  if (user != null &&
      ['ADMIN', 'OPERADOR', 'AUDITOR'].contains(user.rol))
    const _Destination(
      '/carbon',
      'Compensación',
      Icons.forest_outlined,
      Icons.forest,
    ),
  if (AppPermissions.canView(user, AppModule.settings))
    const _Destination(
      '/settings',
      'Configuración',
      Icons.settings_outlined,
      Icons.settings,
    ),
];
