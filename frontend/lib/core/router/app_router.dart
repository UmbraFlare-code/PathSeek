import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/drivers/domain/entities/driver.dart';
import '../../features/drivers/presentation/pages/driver_form_page.dart';
import '../../features/drivers/presentation/pages/driver_list_page.dart';
import '../../features/fleet/domain/entities/vehicle.dart';
import '../../features/fleet/presentation/pages/fleet_list_page.dart';
import '../../features/fleet/presentation/pages/vehicle_form_page.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/presentation/pages/order_form_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
import '../../features/routes/domain/entities/route_plan.dart';
import '../../features/routes/presentation/pages/route_generate_page.dart';
import '../../features/routes/presentation/pages/route_map_page.dart';
import '../constants/app_roles.dart';
import 'home_shell.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  static const Map<String, List<String>> _routeRoles = {
    '/fleet': [AppRoles.admin, AppRoles.operador],
    '/drivers': [AppRoles.admin, AppRoles.operador],
    '/orders': [AppRoles.admin, AppRoles.operador, AppRoles.cliente],
    '/routes': [AppRoles.admin, AppRoles.operador],
    '/map': [AppRoles.admin, AppRoles.operador],
  };

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshListenable(_authBloc),
    redirect: (context, state) => _redirect(state),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
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
                builder: (context, state) =>
                    OrderFormPage(order: state.extra as Order?),
              ),
            ],
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RouteGeneratePage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) =>
                RouteMapPage(plan: state.extra as RoutePlan?),
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

    final allowedRoles = _routeRoles.entries
        .where((entry) => state.matchedLocation.startsWith(entry.key))
        .map((entry) => entry.value)
        .firstOrNull;

    if (allowedRoles != null && !user.hasAnyRole(allowedRoles)) {
      return '/';
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
