import '../entities/route_plan.dart';

abstract class RouteRepository {
  Future<RoutePlan> generateRoutes({
    required String fechaOperacion,
    required double depositoLat,
    required double depositoLon,
    required double velocidadKmh,
    int tiempoServicioMin = 15,
  });

  Future<RoutePerformance> getPerformance();

  Future<bool> isLocked();

  Future<RouteConfirmResult> confirmRoutes(List<String> pedidoIds);
}
