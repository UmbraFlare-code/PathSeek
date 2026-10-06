import '../../features/auth/domain/entities/app_user.dart';
import 'app_roles.dart';

/// Modulos del sistema con control de acceso por rol.
enum AppModule { fleet, drivers, orders, routes, dashboard }

/// Matriz de permisos alineada con DOC-008 (RBAC) y el backend.
///
/// - Flota/Conductores: ADMIN y OPERADOR escriben; AUDITOR solo lee.
/// - Pedidos: ADMIN y OPERADOR escriben; CLIENTE crea y lee; AUDITOR lee.
/// - Rutas: ADMIN y OPERADOR generan/gestionan; AUDITOR solo lee.
/// - Dashboard: ADMIN, OPERADOR y AUDITOR ven metricas.
/// - CONDUCTOR: sin modulos hasta EP-03 (modo conductor).
class AppPermissions {
  AppPermissions._();

  static bool canView(AppUser? user, AppModule module) {
    if (user == null) return false;
    switch (module) {
      case AppModule.fleet:
      case AppModule.drivers:
        return user.hasAnyRole(
            [AppRoles.admin, AppRoles.operador, AppRoles.auditor]);
      case AppModule.orders:
        return user.hasAnyRole([
          AppRoles.admin,
          AppRoles.operador,
          AppRoles.cliente,
          AppRoles.auditor,
        ]);
      case AppModule.routes:
        return user.hasAnyRole(
            [AppRoles.admin, AppRoles.operador, AppRoles.auditor]);
      case AppModule.dashboard:
        // DOC-008: ADMIN/OPERADOR/AUDITOR lectura; CONDUCTOR lectura basica;
        // CLIENTE sin acceso.
        return user.hasAnyRole([
          AppRoles.admin,
          AppRoles.operador,
          AppRoles.auditor,
          AppRoles.conductor,
        ]);
    }
  }

  static bool canCreate(AppUser? user, AppModule module) {
    if (user == null) return false;
    switch (module) {
      case AppModule.fleet:
      case AppModule.drivers:
        return user.hasAnyRole([AppRoles.admin, AppRoles.operador]);
      case AppModule.orders:
        return user.hasAnyRole([AppRoles.admin, AppRoles.operador, AppRoles.cliente]);
      case AppModule.routes:
        return user.hasAnyRole([AppRoles.admin, AppRoles.operador]);
      case AppModule.dashboard:
        return false;
    }
  }

  static bool canUpdate(AppUser? user, AppModule module) {
    if (user == null) return false;
    switch (module) {
      case AppModule.fleet:
      case AppModule.drivers:
      case AppModule.orders:
      case AppModule.routes:
        return user.hasAnyRole([AppRoles.admin, AppRoles.operador]);
      case AppModule.dashboard:
        return false;
    }
  }

  static bool canDelete(AppUser? user, AppModule module) => canUpdate(user, module);
}
