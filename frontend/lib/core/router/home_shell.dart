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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppTheme.border, width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: narrow ? 16 : 24,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.alt_route_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Path',
                      style: TextStyle(
                        color: AppTheme.textHighContrast,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      'Seek',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (user != null && !narrow)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5F1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD6E3D8), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle_outlined,
                        size: 17,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.nombre,
                        style: const TextStyle(
                          color: AppTheme.textHighContrast,
                          fontWeight: FontWeight.w400,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${user.rol})',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w300,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.textSecondary),
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
              SizedBox(width: narrow ? 8 : 16),
            ],
          ),
        ),
      ),
      body: narrow
          ? Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppTheme.surface,
                    child: child,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppTheme.border, width: 1.0),
                    ),
                  ),
                  child: _BottomNav(user: user),
                ),
              ],
            )
          : Row(
              children: [
                _SideRail(user: user),
                const VerticalDivider(thickness: 1, width: 1, color: AppTheme.border),
                Expanded(
                  child: Container(
                    color: AppTheme.surface,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5F1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD6E3D8),
                      width: 1.0,
                    ),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.android_rounded, color: AppTheme.primary, size: 22),
                      SizedBox(height: 3),
                      Text(
                        'APK',
                        style: TextStyle(
                          color: AppTheme.textHighContrast,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
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
      final path = destinations[i].path;
      if (path == '/' && (location == '/' || location.isEmpty)) {
        return i;
      }
      if (path != '/' && (location == path || location.startsWith('$path/'))) {
        return i;
      }
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
      final path = destinations[i].path;
      if (path == '/' && (location == '/' || location.isEmpty)) {
        return i;
      }
      if (path != '/' && (location == path || location.startsWith('$path/'))) {
        return i;
      }
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
