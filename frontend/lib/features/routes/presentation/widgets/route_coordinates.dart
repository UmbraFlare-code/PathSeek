import 'package:latlong2/latlong.dart';

/// Google encoded-polyline format, five decimal digits (the API geometry contract).
List<LatLng> decodeRoutePolyline(String? encoded) {
  if (encoded == null || encoded.isEmpty || encoded.length > 100000) return [];
  int index = 0, lat = 0, lon = 0;
  int readDelta() {
    int result = 0, shift = 0, value;
    do {
      if (index >= encoded.length || shift > 30) throw const FormatException('Polyline inválida');
      value = encoded.codeUnitAt(index++) - 63;
      if (value < 0 || value > 63) throw const FormatException('Polyline inválida');
      result |= (value & 31) << shift;
      shift += 5;
    } while (value >= 32);
    return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  }
  final points = <LatLng>[];
  try {
    while (index < encoded.length) {
      lat += readDelta(); lon += readDelta();
      if (lat.abs() > 9000000 || lon.abs() > 18000000) return [];
      points.add(LatLng(lat / 100000, lon / 100000));
    }
  } on FormatException { return []; }
  return points;
}
