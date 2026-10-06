import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';
import 'package:pathseek/features/routes/domain/entities/generate_routes_result.dart';

abstract class RouteRepository {
  Future<List<DeliveryRoute>> getRoutes({String? fecha});

  Future<DeliveryRoute> getRouteById(String id);

  Future<GenerateRoutesResult> generateRoutes();

  Future<void> deleteRoute(String id);
}
