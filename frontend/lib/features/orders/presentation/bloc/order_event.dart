part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrderEvent {
  const OrdersLoaded();
}

class OrderCreated extends OrderEvent {
  const OrderCreated(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

class OrderUpdated extends OrderEvent {
  const OrderUpdated(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

class OrderDeleted extends OrderEvent {
  const OrderDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
