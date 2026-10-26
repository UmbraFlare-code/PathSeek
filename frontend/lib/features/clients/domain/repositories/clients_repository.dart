import 'package:pathseek/features/clients/domain/entities/client_profile.dart';

abstract class ClientsRepository {
  Future<List<ClientProfile>> getClients();

  Future<ClientProfile> getClient(String id);

  Future<ClientProfile> createClient(Map<String, dynamic> payload);

  Future<ClientProfile> updateClient(String id, Map<String, dynamic> payload);

  Future<void> deleteClient(String id);
}
