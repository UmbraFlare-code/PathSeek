import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../constants/permissions.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final narrow = isNarrow(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: narrow ? 12 : 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.route, color: AppTheme.primaryDark, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'PATHSEEK',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (user != null && !narrow)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined,
                      size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '${user.nombre} (${user.rol})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
          SizedBox(width: narrow ? 4 : 12),
        ],
      ),
      body: narrow
          ? Column(
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F7F4),
                    child: child,
                  ),
                ),
                _BottomNav(user: user),
              ],
            )
          : Row(
              children: [
                _SideRail(user: user),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF4F7F4),
                    child: child,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final destinations = _destinationsFor(user, isMobile: false);

    return NavigationRail(
      selectedIndex: _selectedIndex(location, destinations),
      onDestinationSelected: (index) {
        final destination = destinations[index];
        context.go(destination.path);
      },
      labelType: NavigationRailLabelType.all,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Tooltip(
              message: 'Descargar App Móvil (APK Conductor)',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final absoluteUrl = Uri.base.resolve('/downloads/pathseek.apk');
                  try {
                    if (await canLaunchUrl(absoluteUrl)) {
                      await launchUrl(absoluteUrl,
                          mode: LaunchMode.externalApplication);
                    } else {
                      await launchUrl(absoluteUrl,
                          mode: LaunchMode.platformDefault);
                    }
                  } catch (_) {
                    await launchUrl(absoluteUrl,
                        mode: LaunchMode.platformDefault);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.android, color: AppTheme.primary, size: 26),
                      SizedBox(height: 4),
                      Text(
                        'APK',
                        style: TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      destinations: destinations
          .map(
            (destination) => NavigationRailDestination(
              icon: Icon(destination.iconOutlined),
              selectedIcon: Icon(destination.iconFilled),
              label: Text(destination.label),
            ),
          )
          .toList(),
    );
  }

  int _selectedIndex(String location, List<_Destination> destinations) {
    for (var i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].path)) return i;
    }
    return 0;
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final destinations = _destinationsFor(user, isMobile: true);

    return NavigationBar(
      selectedIndex: _selectedIndex(location, destinations),
      onDestinationSelected: (index) =>
          context.go(destinations[index].path),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: Icon(destination.iconOutlined),
              selectedIcon: Icon(destination.iconFilled),
              label: destination.label,
            ),
          )
          .toList(),
    );
  }

  int _selectedIndex(String location, List<_Destination> destinations) {
    for (var i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].path)) return i;
    }
    return 0;
  }
}

class _Destination {
  const _Destination({
    required this.path,
    required this.label,
    required this.iconOutlined,
    required this.iconFilled,
  });

  final String path;
  final String label;
  final IconData iconOutlined;
  final IconData iconFilled;
}

List<_Destination> _destinationsFor(AppUser? user, {required bool isMobile}) {
  final destinations = <_Destination>[
    if (AppPermissions.canView(user, AppModule.dashboard))
      const _Destination(
        path: '/',
        label: 'Inicio',
        iconOutlined: Icons.dashboard_outlined,
        iconFilled: Icons.dashboard,
      ),
    if (AppPermissions.canView(user, AppModule.fleet))
      const _Destination(
        path: '/fleet',
        label: 'Flota',
        iconOutlined: Icons.local_shipping_outlined,
        iconFilled: Icons.local_shipping,
      ),
    if (AppPermissions.canView(user, AppModule.drivers))
      const _Destination(
        path: '/drivers',
        label: 'Conductores',
        iconOutlined: Icons.badge_outlined,
        iconFilled: Icons.badge,
      ),
    if (AppPermissions.canView(user, AppModule.orders))
      const _Destination(
        path: '/orders',
        label: 'Pedidos',
        iconOutlined: Icons.inventory_2_outlined,
        iconFilled: Icons.inventory_2,
      ),
    if (AppPermissions.canView(user, AppModule.routes))
      const _Destination(
        path: '/routes',
        label: 'Rutas',
        iconOutlined: Icons.route_outlined,
        iconFilled: Icons.route,
      ),
  ];
  return destinations;
}
