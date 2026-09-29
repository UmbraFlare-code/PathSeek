import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:pathseek/features/orders/data/models/order_model.dart';
import 'package:pathseek/features/orders/domain/entities/order.dart';
import 'package:pathseek/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final models = await _remoteDataSource.getOrders();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    try {
      final model = await _remoteDataSource.createOrder(
        OrderModel.fromEntity(order),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final model = await _remoteDataSource.updateOrder(
        OrderModel.fromEntity(order),
      );
      return model.toEntity();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    try {
      await _remoteDataSource.deleteOrder(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
