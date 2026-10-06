class ApiPaths {
  ApiPaths._();

  static const String base = '/api/v1';

  static const String authLogin = '$base/auth/login';
  static const String authRefresh = '$base/auth/refresh';
  static const String authLogout = '$base/auth/logout';

  static const String vehiculos = '$base/vehiculos';
  static const String conductores = '$base/conductores';
  static const String pedidos = '$base/pedidos';

  static const String rutasGenerar = '$base/rutas/generar';
  static const String rutasConfirmar = '$base/rutas/confirmar';
  static const String rutasMetricas = '$base/rutas/metricas-rendimiento';
  static const String rutasLock = '$base/rutas/lock';
}
