import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../widgets/time_field.dart';

class OrderFormPage extends StatelessWidget {
  const OrderFormPage({super.key, this.order});

  final Order? order;

  bool get _isEditing => order != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderBloc>(
      create: (_) => locator<OrderBloc>(),
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Pedido actualizado correctamente'
                      : 'Pedido registrado correctamente',
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
        child: OrderFormView(order: order),
      ),
    );
  }
}

class OrderFormView extends StatefulWidget {
  const OrderFormView({super.key, required this.order});

  final Order? order;

  @override
  State<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<OrderFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clienteIdController;
  late final TextEditingController _direccionController;
  late final TextEditingController _gpsLatController;
  late final TextEditingController _gpsLonController;
  late final TextEditingController _pesoController;
  late final TextEditingController _volumenController;
  late final TextEditingController _ventanaInicioController;
  late final TextEditingController _ventanaFinController;
  String _prioridad = 'ESTANDAR';
  String _tipoProducto = 'NO_PERECEDERO';
  String _estado = 'PENDIENTE';

  static const List<String> _estados = [
    'PENDIENTE',
    'EN_RUTA',
    'ENTREGADO',
    'CANCELADO',
  ];

  static const List<String> _prioridades = [
    'EXPRESS',
    'ESTANDAR',
    'ECONOMICO',
  ];

  static const List<String> _tiposProducto = [
    'PERECEDERO',
    'NO_PERECEDERO',
  ];

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    _clienteIdController =
        TextEditingController(text: order?.clienteId ?? '');
    _direccionController = TextEditingController(text: order?.direccion ?? '');
    _gpsLatController =
        TextEditingController(text: order?.gpsLat.toString() ?? '');
    _gpsLonController =
        TextEditingController(text: order?.gpsLon.toString() ?? '');
    _pesoController = TextEditingController(text: order?.peso.toString() ?? '');
    _volumenController =
        TextEditingController(text: order?.volumen.toString() ?? '');
    _ventanaInicioController =
        TextEditingController(text: order?.ventanaInicio ?? '');
    _ventanaFinController =
        TextEditingController(text: order?.ventanaFin ?? '');
    if (order != null) {
      _prioridad = order.prioridad;
      _tipoProducto = order.tipoProducto;
      _estado = order.estado;
    }
  }

  @override
  void dispose() {
    _clienteIdController.dispose();
    _direccionController.dispose();
    _gpsLatController.dispose();
    _gpsLonController.dispose();
    _pesoController.dispose();
    _volumenController.dispose();
    _ventanaInicioController.dispose();
    _ventanaFinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final windowError = Validators.timeWindow(
        _ventanaInicioController.text.trim(),
        _ventanaFinController.text.trim(),
      );
      if (windowError != null) {
        showAppSnackBar(context, windowError, isError: true);
        return;
      }
      final order = Order(
        id: widget.order?.id ?? '',
        clienteId: _clienteIdController.text.trim(),
        direccion: _direccionController.text.trim(),
        gpsLat: double.parse(_gpsLatController.text.trim()),
        gpsLon: double.parse(_gpsLonController.text.trim()),
        peso: double.parse(_pesoController.text.trim()),
        volumen: double.parse(_volumenController.text.trim()),
        ventanaInicio: _ventanaInicioController.text.trim(),
        ventanaFin: _ventanaFinController.text.trim(),
        prioridad: _prioridad,
        tipoProducto: _tipoProducto,
        estado: _isEditing ? _estado : 'PENDIENTE',
      );

      final bloc = context.read<OrderBloc>();
      if (_isEditing) {
        bloc.add(OrderUpdated(order));
      } else {
        bloc.add(OrderCreated(order));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<OrderBloc>().state.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar pedido' : 'Nuevo pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _clienteIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID de cliente',
                              prefixIcon: Icon(Icons.store_outlined),
                            ),
                            validator: (value) =>
                                Validators.required(value, 'El ID de cliente'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _prioridad,
                            decoration: const InputDecoration(
                              labelText: 'Prioridad',
                            ),
                            items: _prioridades
                                .map(
                                  (prioridad) => DropdownMenuItem(
                                    value: prioridad,
                                    child: Text(prioridad),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _prioridad = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Direccion o punto de referencia',
                        helperText:
                            'Ej. "frente a la bodega El Ahorro" si no hay direccion formal',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          Validators.required(value, 'La direccion'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gpsLatController,
                            decoration: const InputDecoration(
                              labelText: 'Latitud GPS',
                              prefixIcon: Icon(Icons.explore_outlined),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (value) =>
                                Validators.range(value, -90, 90, 'La latitud'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _gpsLonController,
                            decoration: const InputDecoration(
                              labelText: 'Longitud GPS',
                              prefixIcon: Icon(Icons.explore_outlined),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (value) => Validators.range(
                                value, -180, 180, 'La longitud'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pesoController,
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                Validators.positive(value, 'El peso'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _volumenController,
                            decoration: const InputDecoration(
                              labelText: 'Volumen (m3)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                Validators.positive(value, 'El volumen'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TimeField(
                            controller: _ventanaInicioController,
                            labelText: 'Ventana - hora de inicio',
                            validator: (value) =>
                                Validators.required(value, 'La hora de inicio'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TimeField(
                            controller: _ventanaFinController,
                            labelText: 'Ventana - hora de fin',
                            validator: (value) =>
                                Validators.required(value, 'La hora de fin'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _tipoProducto,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de producto',
                            ),
                            items: _tiposProducto
                                .map(
                                  (tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _tipoProducto = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                        ),
                        items: _estados
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _estado = value);
                          }
                        },
                      ),
                    ],
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
