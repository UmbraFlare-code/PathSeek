import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PathSeek'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text('${user.nombre} (${user.rol})'),
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesion',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _indexFor(GoRouterState.of(context).uri.path),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                case 1:
                  context.go('/fleet');
                case 2:
                  context.go('/drivers');
                case 3:
                  context.go('/orders');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Inicio'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.local_shipping),
                label: Text('Flota'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.badge),
                label: Text('Conductores'),
              ),
              if (user != null &&
                  (user.isAdmin || user.isOperador || user.isCliente))
                const NavigationRailDestination(
                  icon: Icon(Icons.inventory_2),
                  label: Text('Pedidos'),
                ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _indexFor(String location) {
    if (location.startsWith('/fleet')) return 1;
    if (location.startsWith('/drivers')) return 2;
    if (location.startsWith('/orders')) return 3;
    return 0;
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.route,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'PathSeek',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Optimizador de Rutas Sostenibles - UGEL Huancayo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
