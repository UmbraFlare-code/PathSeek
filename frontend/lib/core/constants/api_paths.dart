class ApiPaths {
  ApiPaths._();

  static const String base = '/api/v1';

  static const String authLogin = '$base/auth/login';
  static const String authRefresh = '$base/auth/refresh';

  static const String vehiculos = '$base/vehiculos';
  static const String conductores = '$base/conductores';
  static const String clientes = '$base/clientes';
  static const String pedidos = '$base/pedidos';
  static const String rutas = '$base/rutas';
}
