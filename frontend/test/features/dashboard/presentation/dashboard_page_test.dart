import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/theme/app_theme.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pathseek/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pathseek/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathseek/features/dashboard/presentation/widgets/kpi_card.dart';

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockDashboardBloc mockDashboardBloc;
  late MockAuthBloc mockAuthBloc;

  final testSummary = const DashboardSummary(
    totalVehiculos: 8,
    conductoresDisponibles: 5,
    pedidosPendientes: 12,
    pedidosEnRuta: 4,
    pedidosEntregados: 20,
    pedidosCancelados: 1,
    rutasPlanificadas: 3,
    co2TotalKg: 154.2,
    combustibleTotalL: 52.8,
  );

  final testUser = const AppUser(
    id: '1',
    email: 'admin@pathseek.pe',
    nombre: 'Juan Admin',
    rol: 'ADMIN',
  );

  setUp(() {
    mockDashboardBloc = MockDashboardBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state)
        .thenReturn(AuthState.authenticated(testUser));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.light(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>.value(value: mockDashboardBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const Scaffold(
          body: DashboardView(),
        ),
      ),
    );
  }

  group('DashboardView & KpiCard Light Theme Widget Tests', () {
    testWidgets('renders flat minimalist header and KPI cards correctly',
        (tester) async {
      when(() => mockDashboardBloc.state).thenReturn(
        DashboardState(
          isLoading: false,
          summary: testSummary,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Header elements
      expect(find.text('PANEL DE CONTROL'), findsOneWidget);
      expect(find.text('Resumen de Operaciones'), findsOneWidget);
      expect(
        find.text(
          'Métricas operativas de flota, pedidos y optimización de sostenibilidad',
        ),
        findsOneWidget,
      );

      // KPI cards values and labels
      expect(find.text('Vehículos registrados'), findsOneWidget);
      expect(find.text('Conductores disponibles'), findsOneWidget);
      expect(find.text('Pedidos pendientes'), findsOneWidget);
      expect(find.text('Pedidos en ruta'), findsOneWidget);
      expect(find.text('Pedidos entregados'), findsOneWidget);
      expect(find.text('CO₂ total emitido'), findsOneWidget);
      expect(find.text('Combustible consumido'), findsOneWidget);

      // Quick access section
      expect(find.text('ACCESO RÁPIDO'), findsOneWidget);
      expect(find.text('Gestión de Flota'), findsOneWidget);
      expect(find.text('Conductores'), findsOneWidget);
      expect(find.text('Despacho de Pedidos'), findsOneWidget);
      expect(find.text('Rutas Sostenibles'), findsOneWidget);
    });

    testWidgets('KpiCard renders with flat container without elevation errors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              label: 'Flota Activa',
              value: '10',
              icon: Icons.local_shipping_outlined,
            ),
          ),
        ),
      );

      expect(find.text('Flota Activa'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });
  });
}
