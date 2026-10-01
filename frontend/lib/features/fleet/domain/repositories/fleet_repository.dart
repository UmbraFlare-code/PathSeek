import 'package:pathseek/features/fleet/domain/entities/vehicle.dart';

abstract class FleetRepository {
  Future<List<Vehicle>> getVehicles();

  Future<Vehicle> createVehicle(Vehicle vehicle);

  Future<Vehicle> updateVehicle(Vehicle vehicle);

  Future<void> deleteVehicle(String id);
}
