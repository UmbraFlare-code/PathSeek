import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Observa la conectividad del dispositivo (EN-008).
/// En web usa el estado del navegador; en móvil el estado de la red.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onlineStream => _controller.stream;

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  StreamSubscription<List<ConnectivityResult>> start() {
    return _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isOnline(results));
    });
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}
