import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> createOrder(OrderModel order);

  Future<OrderModel> updateOrder(OrderModel order);

  Future<void> deleteOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _client.dio.get(ApiPaths.pedidos);
    final data = response.data;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final response =
        await _client.dio.post(ApiPaths.pedidos, data: order.toJson());
    return OrderModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    final response = await _client.dio.put(
      '${ApiPaths.pedidos}/${order.id}',
      data: order.toJson(),
    );
    return OrderModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _client.dio.delete('${ApiPaths.pedidos}/$id');
  }

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }
}
