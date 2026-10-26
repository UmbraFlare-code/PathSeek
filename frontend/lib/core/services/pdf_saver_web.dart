import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Guarda el PDF como descarga del navegador (Flutter Web).
Future<String> savePdfFile(String fileName, Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return fileName;
}
