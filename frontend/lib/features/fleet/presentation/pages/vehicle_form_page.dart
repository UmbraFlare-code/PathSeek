import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_field_row.dart';
import '../../../../core/widgets/form_page_layout.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/fleet_bloc.dart';

class VehicleFormPage extends StatelessWidget {
  const VehicleFormPage({super.key, this.vehicle});

  final Vehicle? vehicle;

  bool get _isEditing => vehicle != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FleetBloc>(
      create: (_) => locator<FleetBloc>(),
      child: BlocListener<FleetBloc, FleetState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Vehiculo actualizado correctamente'
                      : 'Vehiculo registrado correctamente',
                ),
              ),
            );
            context.canPop() ? context.pop() : context.go('/fleet');
          } else if (state.hasSaveError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.saveErrorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        child: VehicleFormView(vehicle: vehicle),
      ),
    );
  }
}

class VehicleFormView extends StatefulWidget {
  const VehicleFormView({super.key, required this.vehicle});

  final Vehicle? vehicle;

  @override
  State<VehicleFormView> createState() => _VehicleFormViewState();
}

class _VehicleFormViewState extends State<VehicleFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _placaController;
  late final TextEditingController _capacidadKgController;
  late final TextEditingController _capacidadM3Controller;
  late final TextEditingController _consumoController;
  late final TextEditingController _factorEmisionController;
  late final TextEditingController _anioController;
  String _tipo = 'CAMIONETA';

  static const List<String> _tipos = ['CAMIONETA', 'FURGON', 'MOTO'];

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    _placaController = TextEditingController(text: vehicle?.placa ?? '');
    _capacidadKgController = TextEditingController(
      text: vehicle?.capacidadKg.toString() ?? '',
    );
    _capacidadM3Controller = TextEditingController(
      text: vehicle?.capacidadM3.toString() ?? '',
    );
    _consumoController = TextEditingController(
      text: vehicle?.consumoKmL.toString() ?? '',
    );
    _factorEmisionController = TextEditingController(
      text: vehicle?.factorEmision.toString() ?? '',
    );
    _anioController = TextEditingController(
      text: vehicle?.anio?.toString() ?? '',
    );
    if (vehicle != null) _tipo = vehicle.tipo;
  }

  @override
  void dispose() {
    _placaController.dispose();
    _capacidadKgController.dispose();
    _capacidadM3Controller.dispose();
    _consumoController.dispose();
    _factorEmisionController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? '',
        placa: _placaController.text.trim().toUpperCase(),
        tipo: _tipo,
        capacidadKg: double.parse(_capacidadKgController.text.trim()),
        capacidadM3: double.parse(_capacidadM3Controller.text.trim()),
        consumoKmL: double.parse(_consumoController.text.trim()),
        factorEmision: double.parse(_factorEmisionController.text.trim()),
        anio: int.tryParse(_anioController.text.trim()),
      );

      final bloc = context.read<FleetBloc>();
      if (_isEditing) {
        bloc.add(FleetVehicleUpdated(vehicle));
      } else {
        bloc.add(FleetVehicleCreated(vehicle));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<FleetBloc>().state.isSaving;

    return FormPageLayout(
      title: _isEditing ? 'Editar vehículo' : 'Nuevo vehículo',
      description:
          'Registra la identificación, capacidad y parámetros de sostenibilidad.',
      icon: Icons.local_shipping_outlined,
      backPath: '/fleet',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _placaController,
              decoration: const InputDecoration(
                labelText: 'Placa',
                prefixIcon: Icon(Icons.confirmation_number_outlined),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: Validators.plate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de vehículo',
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
              items: _tipos
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(switch (tipo) {
                        'CAMIONETA' => 'Camioneta',
                        'FURGON' => 'Furgón',
                        'MOTO' => 'Moto',
                        _ => tipo,
                      }),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _tipo = value);
              },
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _capacidadKgController,
                  decoration: const InputDecoration(
                    labelText: 'Capacidad (kg)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.positive(value, 'La capacidad en kg'),
                ),
                TextFormField(
                  controller: _capacidadM3Controller,
                  decoration: const InputDecoration(
                    labelText: 'Capacidad (m³)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.positive(value, 'La capacidad en m3'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _consumoController,
                  decoration: const InputDecoration(
                    labelText: 'Consumo (km/L)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.positive(value, 'El consumo'),
                ),
                TextFormField(
                  controller: _factorEmisionController,
                  decoration: const InputDecoration(
                    labelText: 'Factor de emisión (kg CO2/km)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.decimal(value, 'El factor de emision'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _anioController,
              decoration: const InputDecoration(
                labelText: 'Año de fabricación',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.trim().isEmpty
                  ? null
                  : Validators.year(value, 'El anio'),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () => context.canPop()
                            ? context.pop()
                            : context.go('/fleet'),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving ? null : _submit,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Guardar' : 'Registrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
