import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/api_client.dart';

abstract class ReportsRemoteDataSource {
  Future<Uint8List> downloadSustainabilityReport({
    String? desde,
    String? hasta,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  ReportsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<Uint8List> downloadSustainabilityReport({
    String? desde,
    String? hasta,
  }) async {
    final response = await _client.dio.get<List<int>>(
      ApiPaths.reportesSostenibilidad,
      queryParameters: {
        'desde': ?desde,
        'hasta': ?hasta,
      },
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    final data = response.data;
    return data is Uint8List ? data : Uint8List.fromList(data ?? const []);
  }
}
