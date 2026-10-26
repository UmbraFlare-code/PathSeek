import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';

abstract class NotificationsRepository {
  Future<List<RouteNotification>> getNotifications();

  Future<void> markRead(String id);
}
