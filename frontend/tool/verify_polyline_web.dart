import 'package:pathseek/features/routes/presentation/widgets/route_coordinates.dart';

// Compile with dart compile js and execute with Node to cover web integer semantics.
void main() {
  final route = decodeRoutePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
  if (route.length != 3 || route.first.latitude != 38.5 ||
      route.first.longitude != -120.2 || route.last.latitude != 43.252) {
    throw StateError('Web polyline decoding corrupted negative coordinate deltas');
  }
  final southern = decodeRoutePolyline('~hbE~hbE');
  if (southern.length != 1 || southern.single.latitude != -1 || southern.single.longitude != -1) {
    throw StateError('Web polyline decoding corrupted southern/western coordinates');
  }
  // ignore: avoid_print -- command-line regression probe, not application code.
  print('Web polyline: negative deltas and southern/western coordinates passed');
}
