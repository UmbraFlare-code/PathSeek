import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests (Flat & Minimalist Design)', () {
    testWidgets('renders all design elements correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockAuthBloc.state).thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());

      // Brand Title and Subtitle
      expect(find.text('Path'), findsOneWidget);
      expect(find.text('Seek'), findsOneWidget);
      expect(find.textContaining('UGEL Huancayo'), findsOneWidget);

      // Section tag and form title
      expect(find.text('ACCESO AL SISTEMA'), findsOneWidget);
      expect(find.text('Ingresa a tu cuenta'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);

      // Submit Button
      expect(find.text('Iniciar Sesión'), findsOneWidget);

      // Demo role chips
      expect(find.text('CUENTAS DE DEMOSTRACIÓN'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Operador'), findsOneWidget);
      expect(find.text('Conductor'), findsOneWidget);

      // Footer and Eco Badge
      expect(find.text('Optimización de Emisiones CO₂'), findsOneWidget);
      expect(find.textContaining('v1.0.0-MVP'), findsOneWidget);
    });

    testWidgets('triggers AuthLoginRequested when demo role chip is clicked', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockAuthBloc.state).thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());

      final adminChip = find.text('Admin');
      await tester.ensureVisible(adminChip);
      await tester.tap(adminChip);
      await tester.pump();

      verify(() => mockAuthBloc.add(
            const AuthLoginRequested(
              email: 'admin@pathseek.pe',
              password: 'Admin123!',
            ),
          )).called(1);
    });

    testWidgets('shows validation errors when submitting empty form', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockAuthBloc.state).thenReturn(const AuthState.unauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());

      final submitBtn = find.text('Iniciar Sesión');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('El correo es obligatorio'), findsOneWidget);
      expect(find.text('La contrasena es obligatorio'), findsOneWidget);
    });
  });
}
