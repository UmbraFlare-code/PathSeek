import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/session_store.dart';
import '../network/shared_prefs_token_storage.dart';
import '../network/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/fleet/data/datasources/fleet_remote_datasource.dart';
import '../../features/fleet/data/repositories/fleet_repository_impl.dart';
import '../../features/fleet/domain/repositories/fleet_repository.dart';
import '../../features/fleet/presentation/bloc/fleet_bloc.dart';
import '../../features/drivers/data/datasources/driver_remote_datasource.dart';
import '../../features/drivers/data/repositories/driver_repository_impl.dart';
import '../../features/drivers/domain/repositories/driver_repository.dart';
import '../../features/drivers/presentation/bloc/driver_bloc.dart';
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> setupDependencies() async {
  locator.registerLazySingleton<TokenStorage>(
    () => SharedPrefsTokenStorage(),
  );
  locator.registerLazySingleton<SessionStore>(
    () => SessionStore(tokenStorage: locator()),
  );
  locator.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenStorage: locator()),
  );

  _registerAuth();
  _registerFleet();
  _registerDrivers();
  _registerOrders();
}

void _registerAuth() {
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(locator()),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: locator(),
      sessionStore: locator(),
    ),
  );
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: locator()),
  );
}

void _registerFleet() {
  locator.registerLazySingleton<FleetRemoteDataSource>(
    () => FleetRemoteDataSourceImpl(locator()),
  );
  locator.registerLazySingleton<FleetRepository>(
    () => FleetRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerFactory<FleetBloc>(
    () => FleetBloc(repository: locator()),
  );
}

void _registerDrivers() {
  locator.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(locator()),
  );
  locator.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerFactory<DriverBloc>(
    () => DriverBloc(repository: locator()),
  );
}

void _registerOrders() {
  locator.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(locator()),
  );
  locator.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerFactory<OrderBloc>(
    () => OrderBloc(repository: locator()),
  );
}
