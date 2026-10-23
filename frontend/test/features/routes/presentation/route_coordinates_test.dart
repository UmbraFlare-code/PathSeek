import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/features/routes/presentation/widgets/route_coordinates.dart';

void main() {
  test('API polyline decodes standard GPS coordinates', () {
    final points = decodeRoutePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(points.length, 3);
    expect(points.first.latitude, 38.5);
    expect(points.first.longitude, -120.2);
    expect(points.last.latitude, 43.252);
  });
  test('invalid geometry falls back instead of inventing coordinates', () {
    expect(decodeRoutePolyline('_'), isEmpty);
    expect(decodeRoutePolyline(null), isEmpty);
  });
}
