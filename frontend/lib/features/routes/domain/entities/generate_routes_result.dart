import 'package:equatable/equatable.dart';
import 'package:pathseek/features/routes/domain/entities/delivery_route.dart';

class GenerateRoutesResult extends Equatable {
  const GenerateRoutesResult({
    this.rutas = const [],
    this.pedidosNoAsignados = const [],
  });

  final List<DeliveryRoute> rutas;
  final List<String> pedidosNoAsignados;

  @override
  List<Object?> get props => [rutas, pedidosNoAsignados];
}
