import 'package:dio/dio.dart';
import 'package:pathseek/core/errors/error_mapper.dart';
import 'package:pathseek/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';
import 'package:pathseek/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({required NotificationsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<RouteNotification>> getNotifications() async {
    try {
      final models = await _remoteDataSource.getNotifications();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _remoteDataSource.markRead(id);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }
}
