import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _soles = NumberFormat.currency(
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  static final NumberFormat decimal = NumberFormat('#,##0.00');

  static final NumberFormat integer = NumberFormat('#,##0');

  static String soles(num value) => _soles.format(value);

  static String km(num value) => '${decimal.format(value)} km';

  static String liters(num value) => '${decimal.format(value)} L';

  static String co2(num value) => '${decimal.format(value)} kg CO\u2082';

  static String percent(num value) => '${decimal.format(value)}%';

  static String date(DateTime value) =>
      DateFormat('dd/MM/yyyy').format(value);

  static String time(DateTime value) => DateFormat('HH:mm').format(value);

  static String dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm').format(value);
}
