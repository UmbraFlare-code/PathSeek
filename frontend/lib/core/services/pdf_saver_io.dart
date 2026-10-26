import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Guarda el PDF en la carpeta de documentos de la app (Android/iOS/escritorio).
Future<String> savePdfFile(String fileName, Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
