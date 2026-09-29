import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  final authBloc = locator<AuthBloc>()
    ..add(const AuthCheckRequested());

  runApp(PathSeekApp(authBloc: authBloc));
}

class PathSeekApp extends StatelessWidget {
  PathSeekApp({super.key, required AuthBloc authBloc})
      : _authBloc = authBloc,
        _router = AppRouter(authBloc);

  final AuthBloc _authBloc;
  final AppRouter _router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: MaterialApp.router(
        title: 'PathSeek',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router.router,
      ),
    );
  }
}
