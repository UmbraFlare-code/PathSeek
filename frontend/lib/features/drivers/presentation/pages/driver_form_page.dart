import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_field_row.dart';
import '../../../../core/widgets/form_page_layout.dart';
import '../../domain/entities/driver.dart';
import '../bloc/driver_bloc.dart';

class DriverFormPage extends StatelessWidget {
  const DriverFormPage({super.key, this.driver});

  final Driver? driver;

  bool get _isEditing => driver != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverBloc>(
      create: (_) => locator<DriverBloc>(),
      child: BlocListener<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Conductor actualizado correctamente'
                      : 'Conductor registrado correctamente',
                ),
              ),
            );
            context.canPop() ? context.pop() : context.go('/drivers');
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
        child: DriverFormView(driver: driver),
      ),
    );
  }
}

class DriverFormView extends StatefulWidget {
  const DriverFormView({super.key, required this.driver});

  final Driver? driver;

  @override
  State<DriverFormView> createState() => _DriverFormViewState();
}

class _DriverFormViewState extends State<DriverFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _dniController;
  late final TextEditingController _nombreController;
  late final TextEditingController _licenciaController;
  late final TextEditingController _experienciaController;
  late final TextEditingController _contactoController;
  String _categoria = 'AII';
  bool _disponible = true;

  static const List<String> _categorias = ['AII', 'AIII', 'BII', 'BIII'];

  bool get _isEditing => widget.driver != null;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    _dniController = TextEditingController(text: driver?.dni ?? '');
    _nombreController = TextEditingController(text: driver?.nombre ?? '');
    _licenciaController = TextEditingController(text: driver?.licencia ?? '');
    _experienciaController = TextEditingController(
      text: driver?.experiencia.toString() ?? '',
    );
    _contactoController = TextEditingController(text: driver?.contacto ?? '');
    if (driver != null) {
      _categoria = driver.categoria;
      _disponible = driver.disponible;
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _licenciaController.dispose();
    _experienciaController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final driver = Driver(
        id: widget.driver?.id ?? '',
        usuarioId: '',
        dni: _dniController.text.trim(),
        nombre: _nombreController.text.trim(),
        licencia: _licenciaController.text.trim().toUpperCase(),
        categoria: _categoria,
        experiencia: int.parse(_experienciaController.text.trim()),
        disponible: _disponible,
        contacto: _contactoController.text.trim().isEmpty
            ? null
            : _contactoController.text.trim(),
      );

      final bloc = context.read<DriverBloc>();
      if (_isEditing) {
        bloc.add(DriverUpdated(driver));
      } else {
        bloc.add(DriverCreated(driver));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<DriverBloc>().state.isSaving;

    return FormPageLayout(
      title: _isEditing ? 'Editar conductor' : 'Nuevo conductor',
      description:
          'Mantén actualizados los datos, la licencia y la disponibilidad.',
      icon: Icons.badge_outlined,
      backPath: '/drivers',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _dniController,
              decoration: const InputDecoration(
                labelText: 'DNI',
                helperText:
                    'Se vincula con la cuenta CONDUCTOR que tenga este DNI.',
                helperMaxLines: 3,
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.dni,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => Validators.required(value, 'El nombre'),
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _licenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Licencia de conducir',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: Validators.license,
                ),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categorias
                      .map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoria = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                TextFormField(
                  controller: _experienciaController,
                  decoration: const InputDecoration(
                    labelText: 'Años de experiencia',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      Validators.integer(value, 'La experiencia'),
                ),
                TextFormField(
                  controller: _contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Contacto (teléfono)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disponible para rutas'),
              value: _disponible,
              onChanged: (value) => setState(() => _disponible = value),
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
                            : context.go('/drivers'),
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
