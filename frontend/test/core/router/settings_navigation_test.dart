import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/router/home_shell.dart';
import 'package:pathseek/core/theme/app_theme.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';

class _AuthMock extends Mock implements AuthBloc {}

void main() {
  Future<GoRouter> renderShell(
    WidgetTester tester, {
    required String role,
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _AuthMock();
    when(() => auth.stream).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => auth.state).thenReturn(
      AuthState.authenticated(
        AppUser(
          id: 'user-$role',
          nombre: 'Usuario de prueba',
          email: 'usuario@pathseek.test',
          rol: role,
        ),
      ),
    );
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Text('Contenido inicial'),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) =>
                  const Text('Contenido configuración'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: auth,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  for (final role in ['ADMIN', 'OPERADOR', 'AUDITOR']) {
    testWidgets('$role encuentra y abre Configuración en escritorio', (
      tester,
    ) async {
      final router = await renderShell(tester, role: role);

      expect(find.text('Configuración'), findsOneWidget);
      await tester.tap(find.text('Configuración'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/settings');
      expect(find.text('Contenido configuración'), findsOneWidget);
      final selected = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Configuración'),
          matching: find.byType(ListTile),
        ),
      );
      expect(selected.selected, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  for (final role in ['CLIENTE', 'CONDUCTOR']) {
    testWidgets('$role no tiene enlace de Configuración', (tester) async {
      await renderShell(tester, role: role);

      expect(find.text('Configuración'), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'ADMIN abre Configuración desde el menú móvil y cierra el panel',
    (tester) async {
      final router = await renderShell(
        tester,
        role: 'ADMIN',
        size: const Size(390, 844),
      );

      // Seis destinos requieren un menú lateral en lugar de saturar la barra.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Configuración'), findsNothing);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Configuración'));
      await tester.tap(find.text('Configuración'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/settings');
      expect(find.text('Contenido configuración'), findsOneWidget);
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
