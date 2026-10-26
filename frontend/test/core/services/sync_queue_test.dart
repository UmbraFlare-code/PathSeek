import 'package:flutter_test/flutter_test.dart';
import 'package:pathseek/core/services/sync_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('enqueue and list persist the conductor actions', () async {
    final queue = SyncQueue();
    await queue.enqueue(
      tipo: 'posicion',
      rutaId: 'r1',
      lat: -12.06,
      lon: -75.21,
    );
    await queue.enqueue(tipo: 'completar', rutaId: 'r1', pedidoId: 'o1');

    final actions = await queue.list();
    expect(actions, hasLength(2));
    expect(actions.first.tipo, 'posicion');
    expect(actions.first.lat, -12.06);
    expect(actions.last.pedidoId, 'o1');
  });

  test('removeFirst consumes the queue in order', () async {
    final queue = SyncQueue();
    await queue.enqueue(tipo: 'completar', rutaId: 'r1', pedidoId: 'o1');
    await queue.enqueue(tipo: 'completar', rutaId: 'r1', pedidoId: 'o2');

    await queue.removeFirst();
    final remaining = await queue.list();
    expect(remaining, hasLength(1));
    expect(remaining.first.pedidoId, 'o2');
  });

  test('clear empties the queue', () async {
    final queue = SyncQueue();
    await queue.enqueue(tipo: 'posicion', rutaId: 'r1');
    await queue.clear();
    expect(await queue.length(), 0);
  });
}
