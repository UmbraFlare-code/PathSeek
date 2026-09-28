import 'package:pathseek/features/orders/domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();

  Future<Order> createOrder(Order order);

  Future<Order> updateOrder(Order order);

  Future<void> deleteOrder(String id);
}
