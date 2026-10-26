import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/route_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<RouteNotificationModel>> getNotifications();

  Future<void> markRead(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<RouteNotificationModel>> getNotifications() async {
    final response = await _client.dio.get(
      '${ApiPaths.rutasNotificaciones}?pagina=0',
    );
    final data = response.data;
    final list = data is List ? data : <dynamic>[];
    return list
        .map((item) => RouteNotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _client.dio.post('${ApiPaths.rutasNotificaciones}/$id/leida');
  }
}
