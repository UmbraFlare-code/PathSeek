import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/router/home_shell.dart';
import 'package:pathseek/core/theme/app_theme.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/auth/presentation/pages/login_page.dart';
import 'package:pathseek/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pathseek/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pathseek/features/drivers/domain/entities/driver.dart';
import 'package:pathseek/features/drivers/presentation/bloc/driver_bloc.dart';
import 'package:pathseek/features/drivers/presentation/pages/driver_form_page.dart';
import 'package:pathseek/features/drivers/presentation/pages/driver_list_page.dart';
import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';
import 'package:pathseek/features/fleet/presentation/bloc/fleet_bloc.dart';
import 'package:pathseek/features/fleet/presentation/pages/fleet_list_page.dart';
import 'package:pathseek/features/fleet/presentation/pages/vehicle_form_page.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';
import 'package:pathseek/features/orders/presentation/bloc/order_bloc.dart';
import 'package:pathseek/features/orders/presentation/pages/order_list_page.dart';
import 'package:pathseek/features/orders/presentation/pages/order_form_page.dart';
import 'package:pathseek/features/orders/presentation/widgets/delivery_location_picker.dart';

class AuthMock extends Mock implements AuthBloc {}

class FleetMock extends Mock implements FleetBloc {}

class DriverMock extends Mock implements DriverBloc {}

class OrdersMock extends Mock implements OrderBloc {}

class DashboardMock extends Mock implements DashboardBloc {}

const imageKey = ValueKey('pro-preview');
const vehicle = Vehicle(
  id: 'v1',
  placa: 'ABC-123',
  tipo: 'FURGON',
  capacidadKg: 1200,
  capacidadM3: 10,
  consumoKmL: 12,
  factorEmision: .2,
  anio: 2024,
);
const secondVehicle = Vehicle(
  id: 'v2',
  placa: 'DEF-456',
  tipo: 'CAMIONETA',
  capacidadKg: 800,
  capacidadM3: 6,
  consumoKmL: 14,
  factorEmision: .18,
  anio: 2023,
);
const driver = Driver(
  id: 'd1',
  usuarioId: 'u1',
  dni: '12345678',
  nombre: 'María Torres Fernández',
  licencia: 'Q12345678',
  categoria: 'AIII',
  experiencia: 5,
  contacto: '999 123 456',
);
const order = Order(
  id: 'p1',
  clienteId: 'IE-SANTA-ISABEL',
  direccion: 'I.E. Santa Isabel, acceso principal de entregas',
  gpsLat: -12.06,
  gpsLon: -75.20,
  peso: 250,
  volumen: 2,
  ventanaInicio: '08:00',
  ventanaFin: '12:00',
  prioridad: 'EXPRESS',
  tipoProducto: 'PERECEDERO',
);

Future<void> snapshot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(imageKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await Directory('build/uiux-pro').create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    var sdk = File(Platform.resolvedExecutable).parent;
    while (!Directory(
      '${sdk.path}/bin/cache/artifacts/material_fonts',
    ).existsSync()) {
      if (sdk.parent.path == sdk.path) {
        throw StateError('Flutter SDK fonts not found');
      }
      sdk = sdk.parent;
    }
    for (final entry in {
      'Roboto': 'roboto-regular.ttf',
      'MaterialIcons': 'materialicons-regular.otf',
    }.entries) {
      final font = FontLoader(entry.key)
        ..addFont(
          File(
            '${sdk.path}/bin/cache/artifacts/material_fonts/${entry.value}',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await font.load();
    }
  });
  late AuthMock auth;
  late FleetMock fleet;
  late DriverMock drivers;
  late OrdersMock orders;
  late StreamController<AuthState> authStream;
  setUp(() {
    auth = AuthMock();
    fleet = FleetMock();
    drivers = DriverMock();
    orders = OrdersMock();
    authStream = StreamController<AuthState>.broadcast();
    addTearDown(authStream.close);
    when(() => auth.stream).thenAnswer((_) => authStream.stream);
    when(() => fleet.stream).thenAnswer((_) => const Stream.empty());
    when(() => drivers.stream).thenAnswer((_) => const Stream.empty());
    when(() => orders.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => fleet.state,
    ).thenReturn(const FleetState(vehicles: [vehicle, secondVehicle]));
    when(() => drivers.state).thenReturn(const DriverState(drivers: [driver]));
    when(() => orders.state).thenReturn(const OrderState(orders: [order]));
  });
  Future<void> render(
    WidgetTester tester, {
    Widget child = const SizedBox(),
    String role = 'ADMIN',
    Size size = const Size(1440, 900),
    double scale = 1,
    GoRouter? router,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => auth.state).thenReturn(
      AuthState.authenticated(
        AppUser(
          id: 'u1',
          nombre: 'María Torres Fernández de Operaciones',
          email: 'test@local',
          rol: role,
        ),
      ),
    );
    Widget builder(BuildContext context, Widget? child) => RepaintBoundary(
      key: imageKey,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: auth),
          BlocProvider<FleetBloc>.value(value: fleet),
          BlocProvider<DriverBloc>.value(value: drivers),
          BlocProvider<OrderBloc>.value(value: orders),
        ],
        child: router == null
            ? MaterialApp(
                theme: AppTheme.light(),
                builder: builder,
                home: child is LoginPage ? child : Scaffold(body: child),
              )
            : MaterialApp.router(
                theme: AppTheme.light(),
                builder: builder,
                routerConfig: router,
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  GoRouter navigation(String location, {Widget? content}) => GoRouter(
    initialLocation: location,
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          for (final path in [
            '/',
            '/fleet',
            '/drivers',
            '/orders',
            '/routes',
            '/orders/new',
          ])
            GoRoute(
              path: path,
              builder: (_, state) =>
                  content ?? Center(child: Text('Contenido ${state.uri.path}')),
            ),
        ],
      ),
    ],
  );

  testWidgets('desktop deep link highlights its module instead of the root', (
    tester,
  ) async {
    final router = navigation('/orders/new');
    addTearDown(router.dispose);
    await render(tester, router: router);
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
    expect(
      tiles.where((tile) => tile.selected).single.title,
      isA<Text>().having((text) => text.data, 'label', 'Pedidos'),
    );
    await tester.tap(find.text('Rutas'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/routes');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'client single destination works on a phone without exposing other modules',
    (tester) async {
      final router = navigation('/orders', content: const OrderListView());
      addTearDown(router.dispose);
      await render(
        tester,
        role: 'CLIENTE',
        size: const Size(375, 812),
        router: router,
      );
      expect(find.text('Mis pedidos'), findsOneWidget);
      expect(find.text('Flota'), findsNothing);
      expect(find.text('Rutas'), findsNothing);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
      await snapshot(tester, 'client-mobile');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'landscape conductor uses a scrollable menu with only allowed modules',
    (tester) async {
      final router = navigation('/routes');
      addTearDown(router.dispose);
      await render(
        tester,
        role: 'CONDUCTOR',
        size: const Size(812, 375),
        router: router,
      );
      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();
      expect(find.text('Resumen'), findsOneWidget);
      expect(find.text('Flota'), findsNothing);
      await tester.tap(find.text('Resumen'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'catalog scroll keeps search and actions reachable on a narrow short screen',
    (tester) async {
      await render(
        tester,
        child: const FleetListView(),
        size: const Size(320, 480),
        scale: 2,
      );
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'does-not-exist');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No hay resultados para tu búsqueda'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('auditor can search drivers but has no write actions', (
    tester,
  ) async {
    await render(
      tester,
      child: const DriverListView(),
      role: 'AUDITOR',
      size: const Size(768, 1024),
    );
    expect(find.text('Nuevo conductor'), findsNothing);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Eliminar'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Q12345678');
    await tester.pumpAndSettle();
    expect(find.text('María Torres Fernández'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(375, 812),
    const Size(812, 375),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('login fits $size with reduced motion', (tester) async {
      await render(tester, child: const LoginPage(), size: size);
      await tester.ensureVisible(find.text('Iniciar sesión'));
      if (size.width == 1440) await snapshot(tester, 'login-desktop');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'login retains input after async failure and preserves its authentication event',
    (tester) async {
      await render(
        tester,
        child: const LoginPage(),
        size: const Size(375, 812),
      );
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@local.com',
      );
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byType(TextFormField).at(1),
                matching: find.byType(TextField),
              ),
            )
            .focusNode!
            .hasFocus,
        isTrue,
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Test12345!');
      await tester.tap(find.byTooltip('Mostrar contraseña'));
      await tester.pump();
      await tester.tap(find.text('Iniciar sesión'));
      verify(
        () => auth.add(
          const AuthLoginRequested(
            email: 'test@local.com',
            password: 'Test12345!',
          ),
        ),
      ).called(1);
      authStream.add(const AuthState.loading());
      await tester.pump();
      authStream.add(AuthState.failure('Credenciales incorrectas'));
      await tester.pumpAndSettle();
      expect(find.text('test@local.com'), findsOneWidget);
      expect(find.text('Credenciales incorrectas'), findsOneWidget);
      expect(find.byTooltip('Ocultar contraseña'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final entry in <String, Widget>{
    'vehicle': const VehicleFormView(vehicle: null),
    'driver': const DriverFormView(driver: null),
    'order': const OrderFormView(order: null),
  }.entries) {
    testWidgets(
      '${entry.key} form keeps actions accessible with double text on a phone',
      (tester) async {
        await render(
          tester,
          child: entry.value,
          size: const Size(375, 812),
          scale: 2,
        );
        await tester.ensureVisible(find.text('Registrar'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'manual destination validates coordinates and confirms the selected point',
    (tester) async {
      LatLng? result;
      await render(
        tester,
        size: const Size(375, 812),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<LatLng>(
                context: context,
                builder: (_) =>
                    const DeliveryLocationPicker(showBaseMap: false),
              );
            },
            child: const Text('Abrir selector'),
          ),
        ),
      );
      await tester.tap(find.text('Abrir selector'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField).at(0));
      await tester.enterText(find.byType(TextFormField).at(0), '95');
      await tester.enterText(find.byType(TextFormField).at(1), '-75.20');
      await tester.ensureVisible(find.text('Ubicar coordenadas'));
      await tester.tap(find.text('Ubicar coordenadas'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('La latitud debe estar entre'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'NaN');
      await tester.tap(find.text('Ubicar coordenadas'));
      await tester.pumpAndSettle();
      expect(find.textContaining('número finito'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), '-12.07');
      await tester.tap(find.text('Ubicar coordenadas'));
      await tester.pumpAndSettle();
      await snapshot(tester, 'destination-mobile');
      await tester.tap(find.text('Usar destino'));
      await tester.pumpAndSettle();
      expect(result, const LatLng(-12.07, -75.20));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'operational desktop combines shell and catalog without clipped cards',
    (tester) async {
      final router = navigation('/fleet', content: const FleetListView());
      addTearDown(router.dispose);
      await render(tester, router: router);
      await snapshot(tester, 'fleet-desktop');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('cancel never confirms a previously selected destination', (
    tester,
  ) async {
    LatLng? result = const LatLng(0, 0);
    await render(
      tester,
      size: const Size(375, 812),
      scale: 1.5,
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<LatLng>(
              context: context,
              builder: (_) => const DeliveryLocationPicker(
                initial: LatLng(-12.06, -75.2),
                showBaseMap: false,
              ),
            );
          },
          child: const Text('Abrir selector'),
        ),
      ),
    );
    await tester.tap(find.text('Abrir selector'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('dashboard presents grouped real fields on desktop', (
    tester,
  ) async {
    final dashboard = DashboardMock();
    when(() => dashboard.stream).thenAnswer((_) => const Stream.empty());
    when(() => dashboard.state).thenReturn(
      const DashboardState(
        summary: DashboardSummary(
          totalVehiculos: 12,
          conductoresDisponibles: 8,
          pedidosPendientes: 15,
          pedidosEnRuta: 24,
          pedidosEntregados: 36,
          rutasPlanificadas: 5,
          co2TotalKg: 18.6,
          combustibleTotalL: 8.2,
        ),
      ),
    );
    final router = navigation(
      '/',
      content: BlocProvider<DashboardBloc>.value(
        value: dashboard,
        child: const DashboardView(),
      ),
    );
    addTearDown(router.dispose);
    await render(tester, router: router);
    await snapshot(tester, 'dashboard-desktop');
    expect(tester.takeException(), isNull);
  });
}
