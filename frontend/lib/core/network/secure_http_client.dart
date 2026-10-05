import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Crea un [HttpClient] que confia exclusivamente en el certificado
/// auto-firmado de la VPS de PathSeek (pin estricto).
///
/// Flutter (dart:io) NO respeta el network_security_config.xml de Android
/// para validar TLS; usa su propio motor (BoringSSL). Por eso el
/// certificado se carga desde assets y se registra como unica raiz de
/// confianza en un [SecurityContext] propio.
///
/// Solo aplica en plataformas nativas (Android/iOS). En web no se usa:
/// dio emplea el adaptador del navegador, que tiene su propia validacion.
class SecureHttpClientFactory {
  SecureHttpClientFactory._();

  static const String _certAsset = 'assets/certs/pathseek_cert.pem';

  /// Crea el [HttpClient] seguro. Llamar tras
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<HttpClient> create() async {
    final bytes = (await rootBundle.load(_certAsset)).buffer.asUint8List();

    final context = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(bytes);

    return HttpClient(context: context);
  }

  /// `true` si el pin aplica (plataformas nativas).
  static bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
