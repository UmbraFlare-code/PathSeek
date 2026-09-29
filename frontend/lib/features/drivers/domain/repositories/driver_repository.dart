import 'package:pathseek/features/drivers/domain/entities/driver.dart';

abstract class DriverRepository {
  Future<List<Driver>> getDrivers();

  Future<Driver> createDriver(Driver driver);

  Future<Driver> updateDriver(Driver driver);

  Future<void> deleteDriver(String id);
}
