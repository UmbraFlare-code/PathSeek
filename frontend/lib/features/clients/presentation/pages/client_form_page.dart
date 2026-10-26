import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pathseek/core/constants/app_roles.dart';
import 'package:pathseek/core/di/injection.dart';
import 'package:pathseek/core/widgets/form_page_layout.dart';
import 'package:pathseek/core/widgets/responsive_field_row.dart';
import 'package:pathseek/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pathseek/features/clients/domain/entities/client_profile.dart';
import 'package:pathseek/features/clients/presentation/bloc/clients_bloc.dart';

class ClientFormPage extends StatelessWidget {
  const ClientFormPage({super.key, this.client});

  final ClientProfile? client;

  @override
  Widget build(BuildContext context) => BlocProvider<ClientsBloc>(
    create: (_) => locator<ClientsBloc>(),
    child: ClientFormView(client: client),
  );
}

class ClientFormView extends StatefulWidget {
  const ClientFormView({super.key, this.client});

  final ClientProfile? client;

  @override
  State<ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<ClientFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _direccionController;
  late final TextEditingController _referenciaController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _inicioController;
  late final TextEditingController _finController;
  late final TextEditingController _restriccionesController;
  late final TextEditingController _usuarioController;

  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    _nombreController = TextEditingController(text: client?.nombre ?? '');
    _direccionController = TextEditingController(text: client?.direccion ?? '');
    _referenciaController = TextEditingController(
      text: client?.puntoReferencia ?? '',
    );
    _telefonoController = TextEditingController(text: client?.telefono ?? '');
    _inicioController = TextEditingController(
      text: client?.horarioAtencionInicio ?? '',
    );
    _finController = TextEditingController(
      text: client?.horarioAtencionFin ?? '',
    );
    _restriccionesController = TextEditingController(
      text: client?.restriccionesAcceso ?? '',
    );
    _usuarioController = TextEditingController(
      text: client?.usuarioId ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _referenciaController.dispose();
    _telefonoController.dispose();
    _inicioController.dispose();
    _finController.dispose();
    _restriccionesController.dispose();
    _usuarioController.dispose();
    super.dispose();
  }

  static final _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final usuarioId = _usuarioController.text.trim();
    context.read<ClientsBloc>().add(
          ClientSaved(
            id: widget.client?.id,
            payload: {
              if (!_isEditing && usuarioId.isNotEmpty)
                'usuario_id': usuarioId,
              'nombre': _nombreController.text.trim(),
              if (_direccionController.text.trim().isNotEmpty)
                'direccion': _direccionController.text.trim(),
              if (_referenciaController.text.trim().isNotEmpty)
                'punto_referencia': _referenciaController.text.trim(),
              if (_telefonoController.text.trim().isNotEmpty)
                'telefono': _telefonoController.text.trim(),
              if (_inicioController.text.trim().isNotEmpty)
                'horario_atencion_inicio': _inicioController.text.trim(),
              if (_finController.text.trim().isNotEmpty)
                'horario_atencion_fin': _finController.text.trim(),
              if (_restriccionesController.text.trim().isNotEmpty)
                'restricciones_acceso': _restriccionesController.text.trim(),
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.watch<AuthBloc>().state.user?.rol;
    final isCliente = rol == AppRoles.cliente;
    return BlocListener<ClientsBloc, ClientsState>(
      listener: (context, state) {
        if (state.saveErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.saveErrorMessage!)),
          );
        }
        if (state.lastSavedId != null) {
          context.go('/clients');
        }
      },
      child: FormPageLayout(
        title: _isEditing ? 'Editar cliente' : 'Nuevo cliente',
        description: _isEditing
            ? 'Actualiza las preferencias de entrega del cliente.'
            : 'Registra un cliente y sus ventanas de atención.',
        icon: Icons.storefront_outlined,
        backPath: '/clients',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _usuarioController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Cuenta asociada (no modificable)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                )
              else if (!isCliente)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'ID de cuenta CLIENTE (UUID)',
                      helperText:
                          'Cuenta activa con rol CLIENTE; queda vinculada al perfil.',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Selecciona la cuenta del cliente';
                      }
                      return null;
                    },
                  ),
                ),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del cliente o establecimiento',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Punto de referencia',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 16),
              ResponsiveFieldRow(
                children: [
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  TextFormField(
                    controller: _inicioController,
                    decoration: const InputDecoration(
                      labelText: 'Atención desde (HH:mm)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return null;
                      if (!_timePattern.hasMatch(text)) {
                        return 'Formato HH:mm';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _finController,
                    decoration: const InputDecoration(
                      labelText: 'Atención hasta (HH:mm)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return null;
                      if (!_timePattern.hasMatch(text)) {
                        return 'Formato HH:mm';
                      }
                      final inicio = _inicioController.text.trim();
                      if (inicio.isNotEmpty &&
                          _timePattern.hasMatch(inicio) &&
                          text.compareTo(inicio) <= 0) {
                        return 'Debe ser posterior al inicio';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _restriccionesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Restricciones de acceso',
                  helperText: 'Ej.: sin acceso de camiones después de las 14:00',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ClientsBloc, ClientsState>(
                builder: (context, state) => FilledButton.icon(
                  onPressed: state.isSaving ? null : _submit,
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(state.isSaving ? 'Guardando…' : 'Guardar cliente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
