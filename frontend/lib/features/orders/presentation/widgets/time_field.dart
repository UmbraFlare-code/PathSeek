import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  Future<void> _pickTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final current = _parse(controller.text) ?? now;

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (picked != null) {
      controller.text = DateFormat('HH:mm').format(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    }
  }

  TimeOfDay? _parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.schedule_outlined),
        suffixIcon: IconButton(
          tooltip: 'Seleccionar hora',
          icon: const Icon(Icons.access_time),
          onPressed: () => _pickTime(context),
        ),
      ),
      readOnly: true,
      onTap: () => _pickTime(context),
      validator: validator,
    );
  }
}
