import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_update.dart';
import 'package:pathseek/features/routes/domain/entities/generate_routes_result.dart';

abstract class RouteRepository {
  Future<List<DeliveryRoute>> getRoutes({String? fecha});

  Future<DeliveryRoute> getRouteById(String id);

  Future<GenerateRoutesResult> generateRoutes();

  Future<void> deleteRoute(String id);

  Future<DeliveryUpdate> completeDelivery(String rutaId, String pedidoId);

  Future<DeliveryUpdate> reportPosition(String rutaId, double lat, double lon);

  Future<void> reportIncident(String rutaId, Map<String, dynamic> payload);

  Future<ReoptimizationResult> reoptimize(Map<String, dynamic> payload);

  /// Reintenta en orden las acciones guardadas sin conexión (EN-008).
  /// Devuelve cuántas se sincronizaron; las rechazadas por regla de negocio
  /// se descartan y las pendientes por falta de red permanecen en la cola.
  Future<int> flushOfflineQueue();
}
