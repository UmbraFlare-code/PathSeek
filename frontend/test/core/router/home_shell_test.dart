import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/router/home_shell.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  const admin = AppUser(
    id: '1',
    nombre: 'Admin User',
    email: 'admin@pathseek.pe',
    rol: 'ADMIN',
  );

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(admin));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildApp(String initialLocation) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: HomeShell(child: child),
          ),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const Text('Page: Home')),
            GoRoute(path: '/fleet', builder: (_, _) => const Text('Page: Fleet')),
            GoRoute(path: '/drivers', builder: (_, _) => const Text('Page: Drivers')),
            GoRoute(path: '/orders', builder: (_, _) => const Text('Page: Orders')),
            GoRoute(path: '/routes', builder: (_, _) => const Text('Page: Routes')),
            GoRoute(path: '/routes/r-1', builder: (_, _) => const Text('Page: Route Detail')),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('HomeShell NavigationBar & NavigationRail selection tests', () {
    testWidgets('mobile NavigationBar updates selectedIndex when navigating', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Initial on /
      await tester.pumpWidget(buildApp('/'));
      await tester.pumpAndSettle();

      var navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0); // Inicio

      // 2. Navigate to /routes
      await tester.tap(find.text('Rutas'));
      await tester.pumpAndSettle();

      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 4); // Rutas is index 4

      // 3. Navigate to /fleet
      await tester.tap(find.text('Flota'));
      await tester.pumpAndSettle();

      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1); // Flota is index 1

      // 4. Navigate to /drivers
      await tester.tap(find.text('Conductores'));
      await tester.pumpAndSettle();

      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2); // Conductores is index 2

      // 5. Navigate to /orders
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 3); // Pedidos is index 3
    });

    testWidgets('desktop NavigationRail updates selectedIndex when navigating', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp('/routes'));
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 4); // Rutas
    });
  });
}
