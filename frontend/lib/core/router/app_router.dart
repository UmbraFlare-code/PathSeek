import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/carbon/presentation/pages/carbon_page.dart';
import '../../features/clients/domain/entities/client_profile.dart';
import '../../features/clients/presentation/pages/client_form_page.dart';
import '../../features/clients/presentation/pages/clients_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/drivers/domain/entities/driver.dart';
import '../../features/drivers/presentation/pages/driver_form_page.dart';
import '../../features/drivers/presentation/pages/driver_list_page.dart';
import '../../features/fleet/domain/entities/vehicle.dart';
import '../../features/fleet/presentation/pages/fleet_list_page.dart';
import '../../features/fleet/presentation/pages/vehicle_form_page.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/presentation/pages/order_form_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/routes/presentation/pages/route_detail_page.dart';
import '../../features/routes/presentation/pages/route_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../constants/app_roles.dart';
import '../constants/permissions.dart';
import '../di/injection.dart';
import 'home_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshListenable(_authBloc),
    redirect: (context, state) => _redirect(state),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              final user = _authBloc.state.user;
              return user == null
                  ? const LoginPage()
                  : SettingsPage(
                      key: ValueKey('${user.id}-${user.rol}'),
                      user: user,
                    );
            },
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/fleet',
            builder: (context, state) => const FleetListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const VehicleFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                redirect: (context, state) =>
                    state.extra is Vehicle &&
                        (state.extra as Vehicle).id ==
                            state.pathParameters['id']
                    ? null
                    : '/fleet',
                builder: (context, state) =>
                    VehicleFormPage(vehicle: state.extra as Vehicle?),
              ),
            ],
          ),
          GoRoute(
            path: '/drivers',
            builder: (context, state) => const DriverListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const DriverFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                redirect: (context, state) =>
                    state.extra is Driver &&
                        (state.extra as Driver).id == state.pathParameters['id']
                    ? null
                    : '/drivers',
                builder: (context, state) =>
                    DriverFormPage(driver: state.extra as Driver?),
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrderListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const OrderFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                redirect: (context, state) =>
                    state.extra is Order &&
                        (state.extra as Order).id == state.pathParameters['id']
                    ? null
                    : '/orders',
                builder: (context, state) =>
                    OrderFormPage(order: state.extra as Order?),
              ),
            ],
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientsListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ClientFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                redirect: (context, state) =>
                    state.extra is ClientProfile &&
                        (state.extra as ClientProfile).id ==
                            state.pathParameters['id']
                    ? null
                    : '/clients',
                builder: (context, state) =>
                    ClientFormPage(client: state.extra as ClientProfile?),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) {
              final user = _authBloc.state.user;
              return BlocProvider<NotificationsBloc>(
                create: (_) => locator<NotificationsBloc>(),
                child: NotificationsPage(
                  isConductor: user?.rol == AppRoles.conductor,
                ),
              );
            },
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/carbon',
            builder: (context, state) => const CarbonPage(),
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RouteListPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    RouteDetailPage(routeId: state.pathParameters['id'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? _redirect(GoRouterState state) {
    final AppUser? user = _authBloc.state.user;
    final bool isLoggedIn = user != null;
    final bool isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn) {
      return isLoginRoute ? null : '/login';
    }

    if (isLoginRoute) return '/';

    // Roles sin dashboard (CLIENTE segun DOC-008) no permanecen en la raiz:
    // se les envia a su modulo natural.
    if (state.matchedLocation == '/' &&
        !AppPermissions.canView(user, AppModule.dashboard)) {
      return defaultHomeFor(user);
    }

    final requiredRoles = _rolesFor(state.matchedLocation);
    if (requiredRoles != null && !user.hasAnyRole(requiredRoles)) {
      return '/';
    }

    return null;
  }

  /// Modulo inicial de un rol autenticado.
  static String defaultHomeFor(AppUser? user) {
    if (user == null) return '/login';
    if (AppPermissions.canView(user, AppModule.dashboard)) return '/';
    if (AppPermissions.canView(user, AppModule.orders)) return '/orders';
    return '/';
  }

  /// Matriz RBAC del router (DOC-008): lectura vs mutacion por modulo.
  List<String>? _rolesFor(String location) {
    if (location == '/settings' || location.startsWith('/settings/')) {
      return [AppRoles.admin, AppRoles.operador, AppRoles.auditor];
    }
    final isMutating = location.endsWith('/new') || location.contains('/edit');

    if (location.startsWith('/fleet') || location.startsWith('/drivers')) {
      if (isMutating) return [AppRoles.admin, AppRoles.operador];
      return [AppRoles.admin, AppRoles.operador, AppRoles.auditor];
    }

    if (location.startsWith('/orders')) {
      if (location.endsWith('/new')) {
        return [AppRoles.admin, AppRoles.operador, AppRoles.cliente];
      }
      if (isMutating) return [AppRoles.admin, AppRoles.operador];
      return [
        AppRoles.admin,
        AppRoles.operador,
        AppRoles.cliente,
        AppRoles.auditor,
      ];
    }

    if (location.startsWith('/clients')) {
      if (isMutating) {
        return [AppRoles.admin, AppRoles.operador, AppRoles.cliente];
      }
      return [
        AppRoles.admin,
        AppRoles.operador,
        AppRoles.cliente,
        AppRoles.auditor,
      ];
    }

    if (location == '/notifications' || location.startsWith('/notifications')) {
      return [
        AppRoles.admin,
        AppRoles.operador,
        AppRoles.auditor,
        AppRoles.conductor,
      ];
    }

    if (location == '/reports' || location.startsWith('/reports')) {
      return [AppRoles.admin, AppRoles.operador, AppRoles.auditor];
    }

    if (location == '/carbon' || location.startsWith('/carbon')) {
      return [AppRoles.admin, AppRoles.operador, AppRoles.auditor];
    }

    if (location.startsWith('/routes')) {
      return [
        AppRoles.admin,
        AppRoles.operador,
        AppRoles.auditor,
        AppRoles.conductor,
      ];
    }

    return null;
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._bloc) {
    _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
}
