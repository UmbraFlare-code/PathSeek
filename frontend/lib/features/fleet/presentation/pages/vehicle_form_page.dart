import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
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
            context.pop();
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

  static const List<String> _tipos = [
    'CAMIONETA',
    'FURGON',
    'MOTO',
  ];

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
      text: vehicle?.anio.toString() ?? '',
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
        anio: int.parse(_anioController.text.trim()),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar vehiculo' : 'Nuevo vehiculo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                      initialValue: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vehiculo',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                      ),
                      items: _tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _tipo = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacidadKgController,
                            decoration: const InputDecoration(
                              labelText: 'Capacidad (kg)',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                Validators.positive(value, 'La capacidad en kg'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _capacidadM3Controller,
                            decoration: const InputDecoration(
                              labelText: 'Capacidad (m3)',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                Validators.positive(value, 'La capacidad en m3'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _consumoController,
                            decoration: const InputDecoration(
                              labelText: 'Consumo (km/L)',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                Validators.positive(value, 'El consumo'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _factorEmisionController,
                            decoration: const InputDecoration(
                              labelText: 'Factor de emision (kg CO2/km)',
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) => Validators.decimal(
                                value, 'El factor de emision'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _anioController,
                      decoration: const InputDecoration(
                        labelText: 'Anio de fabricacion',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.year(value, 'El anio'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isSaving ? null : () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isEditing ? 'Guardar' : 'Registrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
