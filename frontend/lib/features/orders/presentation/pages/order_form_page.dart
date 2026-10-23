import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/responsive_field_row.dart';
import '../../../../core/widgets/form_page_layout.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../widgets/time_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/delivery_location_picker.dart';

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
            context.canPop() ? context.pop() : context.go('/orders');
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

  static const List<String> _prioridades = ['EXPRESS', 'ESTANDAR', 'ECONOMICO'];

  static const List<String> _tiposProducto = ['PERECEDERO', 'NO_PERECEDERO'];

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    final user = context.read<AuthBloc>().state.user;
    _clienteIdController = TextEditingController(
      text: order?.clienteId ?? (user?.rol == 'CLIENTE' ? user!.id : ''),
    );
    _direccionController = TextEditingController(text: order?.direccion ?? '');
    _gpsLatController = TextEditingController(
      text: order?.gpsLat.toString() ?? '',
    );
    _gpsLonController = TextEditingController(
      text: order?.gpsLon.toString() ?? '',
    );
    _pesoController = TextEditingController(text: order?.peso.toString() ?? '');
    _volumenController = TextEditingController(
      text: order?.volumen.toString() ?? '',
    );
    _ventanaInicioController = TextEditingController(
      text: order?.ventanaInicio ?? '',
    );
    _ventanaFinController = TextEditingController(
      text: order?.ventanaFin ?? '',
    );
    if (order != null) {
      _prioridad = order.prioridad;
      _tipoProducto = order.tipoProducto;
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
        estado: widget.order?.estado ?? 'PENDIENTE',
      );

      final bloc = context.read<OrderBloc>();
      if (_isEditing) {
        bloc.add(OrderUpdated(order));
      } else {
        bloc.add(OrderCreated(order));
      }
    }
  }

  Future<void> _pickDestination() async {
    final lat = double.tryParse(_gpsLatController.text.trim());
    final lon = double.tryParse(_gpsLonController.text.trim());
    final initial =
        lat != null &&
            lon != null &&
            lat.isFinite &&
            lon.isFinite &&
            lat.abs() <= 90 &&
            lon.abs() <= 180
        ? LatLng(lat, lon)
        : null;
    final point = await showDialog<LatLng>(
      context: context,
      builder: (_) => DeliveryLocationPicker(initial: initial),
    );
    if (!mounted || point == null) return;
    _gpsLatController.text = point.latitude.toStringAsFixed(6);
    _gpsLonController.text = point.longitude.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<OrderBloc>().state.isSaving;

    return FormPageLayout(
      title: _isEditing ? 'Editar pedido' : 'Nuevo pedido',
      description: 'Define el destino, la carga y la ventana de entrega.',
      icon: Icons.inventory_2_outlined,
      backPath: '/orders',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _clienteIdController,
                  readOnly:
                      context.read<AuthBloc>().state.user?.rol == 'CLIENTE',
                  decoration: const InputDecoration(
                    labelText: 'ID de cliente',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: (value) =>
                      Validators.required(value, 'El ID de cliente'),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _prioridad,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: _prioridades
                      .map(
                        (prioridad) => DropdownMenuItem(
                          value: prioridad,
                          child: Text(switch (prioridad) {
                            'EXPRESS' => 'Express',
                            'ESTANDAR' => 'Estándar',
                            'ECONOMICO' => 'Económico',
                            _ => prioridad,
                          }),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _prioridad = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección o punto de referencia',
                helperText:
                    'Ej. "frente a la bodega El Ahorro" si no hay direccion formal',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              maxLines: 2,
              validator: (value) => Validators.required(value, 'La direccion'),
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _gpsLatController,
                  decoration: InputDecoration(
                    labelText: 'Latitud GPS',
                    suffixIcon: IconButton(
                      tooltip: 'Seleccionar destino en mapa',
                      onPressed: _pickDestination,
                      icon: const Icon(Icons.map_outlined),
                    ),
                    prefixIcon: const Icon(Icons.explore_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: (value) =>
                      Validators.range(value, -90, 90, 'La latitud'),
                ),
                TextFormField(
                  controller: _gpsLonController,
                  decoration: const InputDecoration(
                    labelText: 'Longitud GPS',
                    prefixIcon: Icon(Icons.explore_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: (value) =>
                      Validators.range(value, -180, 180, 'La longitud'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => Validators.positive(value, 'El peso'),
                ),
                TextFormField(
                  controller: _volumenController,
                  decoration: const InputDecoration(labelText: 'Volumen (m³)'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.positive(value, 'El volumen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TimeField(
                  controller: _ventanaInicioController,
                  labelText: 'Ventana - hora de inicio',
                  validator: (value) =>
                      Validators.required(value, 'La hora de inicio'),
                ),
                TimeField(
                  controller: _ventanaFinController,
                  labelText: 'Ventana - hora de fin',
                  validator: (value) =>
                      Validators.required(value, 'La hora de fin'),
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _tipoProducto,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de producto',
                  ),
                  items: _tiposProducto
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(switch (tipo) {
                            'PERECEDERO' => 'Perecedero',
                            'NO_PERECEDERO' => 'No perecedero',
                            _ => tipo,
                          }),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _tipoProducto = value);
                    }
                  },
                ),
              ],
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
                            : context.go('/orders'),
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
