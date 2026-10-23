import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/theme/app_theme.dart';
import 'package:pathseek/core/widgets/search_sort_controls.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pathseek/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pathseek/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/presentation/bloc/route_bloc.dart';
import 'package:pathseek/features/routes/presentation/pages/route_list_page.dart';
import 'package:pathseek/features/routes/presentation/pages/route_detail_page.dart';
import 'package:pathseek/features/routes/presentation/widgets/interactive_route_map.dart';

class AuthMock extends Mock implements AuthBloc {}

class RoutesMock extends Mock implements RouteBloc {}

class DashboardMock extends Mock implements DashboardBloc {}

const planned = DeliveryRoute(
  id: 'r1',
  fecha: '2026-10-22',
  placa: 'W1A-100',
  conductorNombre: 'Juan Pérez',
  distanciaKm: 18.4,
  co2Kg: 4.8,
  combustibleL: 2.1,
  pedidos: [
    RouteOrder(
      pedidoId: 'p1',
      orden: 1,
      direccion: 'I.E. Santa Isabel',
      gpsLat: -12.062,
      gpsLon: -75.205,
      horaEstimada: '09:15',
      ventanaInicio: '08:00',
      ventanaFin: '12:00',
      peso: 25,
    ),
  ],
);
const completed = DeliveryRoute(
  id: 'r2',
  fecha: '2026-10-21',
  placa: 'W2B-200',
  conductorNombre: 'María Torres',
  estado: 'COMPLETADA',
  distanciaKm: 12.7,
  co2Kg: 3.1,
  combustibleL: 1.6,
);
const previewKey = ValueKey('ui-preview');

Future<void> capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(previewKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = await Directory('build/uiux').create(recursive: true);
    await File(
      '${dir.path}/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Use the SDK fonts so local previews show real text and Material icons.
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
    final fonts = '${sdk.path}/bin/cache/artifacts/material_fonts';
    for (final entry in {
      'Roboto': 'roboto-regular.ttf',
      'MaterialIcons': 'materialicons-regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(
          File(
            '$fonts/${entry.value}',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await loader.load();
    }
  });
  late AuthMock auth;
  late RoutesMock routes;
  setUp(() {
    auth = AuthMock();
    routes = RoutesMock();
    when(() => auth.stream).thenAnswer((_) => const Stream.empty());
    when(() => routes.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => routes.state,
    ).thenReturn(const RouteState(routes: [planned, completed]));
  });
  Future<void> render(
    WidgetTester tester, {
    String role = 'ADMIN',
    Size size = const Size(1280, 900),
    double scale = 1,
    Widget? child,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(() => auth.state).thenReturn(
      AuthState.authenticated(
        AppUser(
          id: 'u1',
          nombre: 'Operaciones',
          email: 'test@local',
          rol: role,
        ),
      ),
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: auth),
          BlocProvider<RouteBloc>.value(value: routes),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: widget!,
          ),
          home: RepaintBoundary(
            key: previewKey,
            child: Scaffold(body: child ?? const RouteListView()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'desktop routes retain metrics and generate through the existing event',
    (tester) async {
      await render(tester);
      expect(find.text('Generar rutas'), findsOneWidget);
      expect(find.text('Combustible'), findsOneWidget);
      expect(find.byTooltip('Eliminar ruta planificada'), findsOneWidget);
      await capture(tester, 'routes-desktop');
      await tester.tap(find.text('Generar rutas'));
      verify(() => routes.add(const RoutesGenerated())).called(1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'mobile filters can be cleared and completed routes have no delete action',
    (tester) async {
      await render(tester, size: const Size(390, 844));
      await capture(tester, 'routes-mobile');
      await tester.enterText(find.byType(TextField), 'W2B');
      await tester.pumpAndSettle();
      expect(find.text('W1A-100'), findsNothing);
      expect(find.text('Eliminar'), findsNothing);
      await tester.tap(find.byTooltip('Limpiar búsqueda'));
      await tester.pumpAndSettle();
      expect(find.text('W1A-100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final role in ['AUDITOR', 'CONDUCTOR']) {
    testWidgets(
      '$role cannot generate or delete even on a narrow screen with large text',
      (tester) async {
        await render(tester, role: role, size: const Size(320, 640), scale: 2);
        expect(find.text('Generar rutas'), findsNothing);
        expect(find.text('Eliminar'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'a read-only empty state never asks the user to generate routes',
    (tester) async {
      when(() => routes.state).thenReturn(const RouteState());
      await render(tester, role: 'CONDUCTOR', size: const Size(390, 844));
      expect(
        find.textContaining('Todavía no tienes rutas asignadas'),
        findsOneWidget,
      );
      expect(find.text('Generar rutas'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'map controls and selected delivery support mobile enlarged text',
    (tester) async {
      await render(
        tester,
        size: const Size(390, 844),
        scale: 1.5,
        child: const SingleChildScrollView(
          child: InteractiveRouteMap(
            route: planned,
            height: 300,
            showBaseMap: false,
          ),
        ),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('stop-p1')));
      await tester.tap(find.byKey(const ValueKey('stop-p1')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Parada #1: I.E. Santa Isabel'),
        findsOneWidget,
      );
      await capture(tester, 'map-mobile');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('shared search controls fit desktop narrow containers', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await render(
      tester,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 350,
          child: SearchSortControls<String>(
            queryController: controller,
            hint: 'Buscar',
            sortItems: const {'date': 'Fecha reciente'},
            sortValue: 'date',
            onQueryChanged: () {},
            onSortChanged: (_) {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'route detail and road profile fit a narrow viewport at double text size',
    (tester) async {
      when(
        () => routes.state,
      ).thenReturn(const RouteState(selectedRoute: planned));
      await render(
        tester,
        size: const Size(320, 640),
        scale: 2,
        child: const RouteDetailView(showBaseMap: false),
      );
      await tester.ensureVisible(find.text('Altitud y calzada estimadas'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  for (final empty in [false, true]) {
    testWidgets(
      'dashboard remains readable on mobile with large text (empty: $empty)',
      (tester) async {
        final dashboard = DashboardMock();
        when(() => dashboard.stream).thenAnswer((_) => const Stream.empty());
        when(() => dashboard.state).thenReturn(
          DashboardState(
            summary: empty
                ? null
                : const DashboardSummary(
                    totalVehiculos: 12,
                    rutasPlanificadas: 8,
                  ),
          ),
        );
        await render(
          tester,
          role: 'CONDUCTOR',
          size: const Size(320, 640),
          scale: 2,
          child: BlocProvider<DashboardBloc>.value(
            value: dashboard,
            child: const DashboardView(),
          ),
        );
        expect(find.textContaining('Genera rutas'), findsNothing);
        if (!empty) {
          await tester.ensureVisible(find.text('Rutas de distribución'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
