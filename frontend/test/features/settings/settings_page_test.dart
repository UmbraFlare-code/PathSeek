import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/core/theme/app_theme.dart';
import 'package:pathseek/features/auth/domain/entities/app_user.dart';
import 'package:pathseek/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:pathseek/features/settings/presentation/pages/settings_page.dart';
import 'settings_test_support.dart';

const admin = AppUser(
  id: 'self',
  nombre: 'Admin',
  email: 'admin@example.test',
  rol: 'ADMIN',
);
const auditor = AppUser(
  id: 'audit',
  nombre: 'Auditor',
  email: 'audit@example.test',
  rol: 'AUDITOR',
);

Future<SettingsBloc> mount(
  WidgetTester tester,
  FakeSettingsRepository repo, {
  AppUser user = admin,
  Size size = const Size(1200, 900),
  double scale = 1,
  GlobalKey? capture,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final bloc = SettingsBloc(repository: repo)
    ..add(SettingsLoaded(manageUsers: user.isAdmin));
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RepaintBoundary(
        key: capture,
        child: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: Column(
              children: [
                if (capture != null)
                  const Text('Vista de prueba · Datos ficticios'),
                Expanded(child: SettingsView(user: user)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return bloc;
}

Future<void> visibleTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
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
  testWidgets('auditor sees only role definitions and never queries accounts', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await mount(tester, repo, user: auditor);
    expect(find.text('Roles y permisos'), findsOneWidget);
    expect(find.text('Nuevo usuario'), findsNothing);
    expect(find.text('Usuarios'), findsNothing);
    expect(find.text('Gestionar usuarios y asignar roles'), findsOneWidget);
    expect(repo.userRequests, 0);
  });

  testWidgets('search and pagination preserve submitted filters', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await mount(tester, repo);
    await tester.enterText(find.byType(TextField).first, 'operador');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Buscar'));
    await tester.pumpAndSettle();
    expect(repo.queries.last.search, 'operador');
    await tester.tap(find.byTooltip('Página siguiente'));
    await tester.pumpAndSettle();
    expect(repo.queries.last.page, 1);
    expect(repo.queries.last.search, 'operador');
  });

  testWidgets(
    'new account validates fields, retains errors, retries successfully',
    (tester) async {
      final repo = FakeSettingsRepository()
        ..saveFailure = const ValidationFailure('El correo ya existe');
      await mount(tester, repo);
      await tester.tap(find.text('Nuevo usuario'));
      await tester.pumpAndSettle();
      await visibleTap(tester, find.text('Guardar usuario'));
      expect(repo.changes, isEmpty);
      expect(
        find.text('Revisa los campos indicados antes de guardar.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre completo'),
        'Cuenta nueva',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        'cuenta@example.test',
      );
      await visibleTap(tester, find.byKey(const Key('user-role')));
      await tester.tap(find.text('Cliente').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('new-user-password')),
        'Password12',
      );
      await visibleTap(tester, find.text('Guardar usuario'));
      expect(find.text('El correo ya existe'), findsOneWidget);
      expect(find.text('Cuenta nueva'), findsOneWidget);
      repo.saveFailure = null;
      await visibleTap(tester, find.text('Guardar usuario'));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Usuario creado correctamente.'), findsOneWidget);
      expect(repo.changes.last.password, 'Password12');
    },
  );

  testWidgets('own account role and active controls cannot be changed', (
    tester,
  ) async {
    await mount(tester, FakeSettingsRepository());
    await visibleTap(tester, find.text('Editar usuario').first);
    final role = tester.widget<DropdownButtonFormField<String>>(
      find.byKey(const Key('user-role')),
    );
    final active = tester.widget<SwitchListTile>(
      find.byKey(const Key('user-active')),
    );
    expect(role.onChanged, isNull);
    expect(active.onChanged, isNull);
    expect(find.byKey(const Key('new-user-password')), findsNothing);
  });

  testWidgets('deactivation requires explicit confirmation', (tester) async {
    final repo = FakeSettingsRepository();
    await mount(tester, repo);
    await visibleTap(tester, find.text('Editar usuario').last);
    await visibleTap(tester, find.byKey(const Key('user-active')));
    await visibleTap(tester, find.text('Guardar usuario'));
    expect(find.text('Confirmar cambio de acceso'), findsOneWidget);
    expect(repo.changes, isEmpty);
    await tester.tap(find.text('Confirmar cambio'));
    await tester.pumpAndSettle();
    expect(repo.changes.single.active, false);
    expect(repo.changes.single.id, 'other');
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('320 dp layout and form support text scale $scale', (
      tester,
    ) async {
      await mount(
        tester,
        FakeSettingsRepository(),
        size: const Size(320, 812),
        scale: scale,
      );
      expect(tester.takeException(), isNull);
      await visibleTap(tester, find.text('Nuevo usuario'));
      expect(tester.takeException(), isNull);
      await visibleTap(tester, find.text('Guardar usuario'));
      expect(tester.takeException(), isNull);
      await visibleTap(tester, find.text('Cancelar'));
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    ('desktop', const Size(1440, 1000)),
    ('mobile', const Size(375, 1000)),
  ]) {
    testWidgets('render ${scenario.$1} preview', (tester) async {
      final key = GlobalKey();
      await mount(
        tester,
        FakeSettingsRepository(),
        size: scenario.$2,
        capture: key,
      );
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build').create(recursive: true);
        await File(
          'build/settings-preview-${scenario.$1}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    });
  }
}
