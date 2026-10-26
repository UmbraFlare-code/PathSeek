import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathseek/core/errors/failures.dart';
import 'package:pathseek/features/notifications/domain/entities/route_notification.dart';
import 'package:pathseek/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:pathseek/features/notifications/presentation/bloc/notifications_bloc.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository repository;
  late NotificationsBloc bloc;

  const notification = RouteNotification(
    id: 'n1',
    rutaId: 'r1',
    mensaje: 'Incidente reportado en tu ruta',
    leida: false,
  );

  setUp(() {
    repository = MockNotificationsRepository();
    bloc = NotificationsBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  group('NotificationsBloc', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'loads notifications and flags unread',
      build: () {
        when(() => repository.getNotifications())
            .thenAnswer((_) async => const [notification]);
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationsLoaded()),
      expect: () => [
        isA<NotificationsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<NotificationsState>()
            .having((s) => s.notifications, 'notifications', const [notification])
            .having((s) => s.hasUnread, 'hasUnread', true),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'sets error message on failure',
      build: () {
        when(() => repository.getNotifications())
            .thenThrow(const ServerFailure('Error del servidor'));
        return bloc;
      },
      act: (bloc) => bloc.add(const NotificationsLoaded()),
      expect: () => [
        isA<NotificationsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<NotificationsState>().having(
          (s) => s.errorMessage,
          'error',
          'Error del servidor',
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'marks a notification as read',
      build: () {
        when(() => repository.markRead('n1')).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const NotificationsState(notifications: [notification]),
      act: (bloc) => bloc.add(const NotificationMarkedRead('n1')),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.notifications.first.leida, 'leida', true)
            .having((s) => s.hasUnread, 'hasUnread', false),
      ],
    );
  });
}
