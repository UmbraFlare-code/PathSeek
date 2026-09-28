class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _plateRegex = RegExp(
    r'^(?:[A-Za-z]{2}\d{4}|[A-Za-z]{3}\d{3}|[A-Za-z]\d[A-Za-z]\d{3})$',
  );

  static final RegExp _dniRegex = RegExp(r'^\d{8}$');

  static final RegExp _licenseRegex = RegExp(r'^[A-Za-z][0-9]{7,9}$');

  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$field es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'El correo');
    if (requiredError != null) return requiredError;
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Ingrese un correo valido';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value, 'La contrasena');
    if (requiredError != null) return requiredError;
    if (value!.length < 8) {
      return 'La contrasena debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? plate(String? value) {
    final requiredError = required(value, 'La placa');
    if (requiredError != null) return requiredError;
    final normalized = value!
        .trim()
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('-', '');
    if (!_plateRegex.hasMatch(normalized)) {
      return 'Formato de placa invalido (ej. ABC123)';
    }
    return null;
  }

  static String? dni(String? value) {
    final requiredError = required(value, 'El DNI');
    if (requiredError != null) return requiredError;
    if (!_dniRegex.hasMatch(value!.trim())) {
      return 'El DNI debe tener 8 digitos';
    }
    return null;
  }

  static String? license(String? value) {
    final requiredError = required(value, 'La licencia');
    if (requiredError != null) return requiredError;
    final normalized = value!.trim().toUpperCase().replaceAll('-', '');
    if (!_licenseRegex.hasMatch(normalized)) {
      return 'Formato de licencia invalido (ej. Q12345678)';
    }
    return null;
  }

  static String? decimal(String? value, [String field = 'Este campo']) {
    final requiredError = required(value, field);
    if (requiredError != null) return requiredError;
    final number = double.tryParse(value!.trim());
    if (number == null || number < 0) {
      return '$field debe ser un numero mayor o igual a 0';
    }
    return null;
  }

  static String? integer(String? value, [String field = 'Este campo']) {
    final requiredError = required(value, field);
    if (requiredError != null) return requiredError;
    final number = int.tryParse(value!.trim());
    if (number == null || number < 0) {
      return '$field debe ser un entero mayor o igual a 0';
    }
    return null;
  }

  static String? timeWindow(String? start, String? end) {
    final startError = required(start, 'La hora de inicio');
    if (startError != null) return startError;
    final endError = required(end, 'La hora de fin');
    if (endError != null) return endError;

    final startParts = start!.split(':');
    final endParts = end!.split(':');
    if (startParts.length != 2 || endParts.length != 2) {
      return 'Formato de hora invalido (HH:mm)';
    }

    final startMinutes = _toMinutes(startParts);
    final endMinutes = _toMinutes(endParts);
    if (startMinutes == null || endMinutes == null) {
      return 'Formato de hora invalido (HH:mm)';
    }

    if (endMinutes <= startMinutes) {
      return 'La hora de fin debe ser posterior a la hora de inicio';
    }
    return null;
  }

  static int? _toMinutes(List<String> parts) {
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null ||
        minutes == null ||
        hours < 0 ||
        hours > 23 ||
        minutes < 0 ||
        minutes > 59) {
      return null;
    }
    return hours * 60 + minutes;
  }
}
