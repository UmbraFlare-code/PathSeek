import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.account, required this.currentUserId});
  final UserAccount? account;
  final String currentUserId;
  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _form = GlobalKey<FormState>();
  final _errorFocus = FocusNode();
  late final TextEditingController _name, _email;
  final _password = TextEditingController();
  final _dni = TextEditingController();
  String? _role;
  late bool _active;
  bool _hidePassword = true;
  bool _invalid = false;
  bool _confirming = false;
  bool get _editing => widget.account != null;
  bool get _ownAccount => widget.account?.id == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.account?.name ?? '');
    _email = TextEditingController(text: widget.account?.email ?? '');
    _role = widget.account?.role;
    _dni.text = widget.account?.dni ?? "";
    _active = widget.account?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _dni.dispose();
    _errorFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_confirming || context.read<SettingsBloc>().state.saving) return;
    if (!_form.currentState!.validate()) {
      setState(() => _invalid = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _errorFocus.requestFocus();
        final context = _errorFocus.context;
        if (context != null) Scrollable.ensureVisible(context);
      });
      return;
    }
    if (_editing &&
        (_role != widget.account!.role ||
            _active != widget.account!.active ||
            _email.text.trim().toLowerCase() !=
                widget.account!.email.toLowerCase())) {
      setState(() => _confirming = true);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text('Confirmar cambio de acceso'),
          content: Text(
            'Se actualizará el acceso de ${_name.text.trim()}. '
            'Rol: $_role. Estado: ${_active ? "activo" : "inactivo"}. '
            'Al cambiar el correo, rol o estado se cierran las sesiones de esta cuenta. '
            'Deberá iniciar sesión nuevamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar cambio'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      setState(() => _confirming = false);
      if (confirmed != true) return;
    }
    if (!mounted) return;
    context.read<SettingsBloc>().add(
      SettingsUserSaved(
        UserChanges(
          dni: _role == "CONDUCTOR" ? _dni.text.trim() : null,
          id: widget.account?.id,
          name: _name.text.trim(),
          email: _email.text.trim(),
          role: _role!,
          active: _active,
          password: _editing ? null : _password.text,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<SettingsBloc, SettingsState>(
    listenWhen: (previous, current) =>
        previous.savedRevision != current.savedRevision,
    listener: (context, state) {
      showAppSnackBar(
        context,
        _editing
            ? 'Usuario actualizado correctamente.'
            : 'Usuario creado correctamente.',
      );
      Navigator.pop(context);
    },
    builder: (context, state) {
      final disabled = state.saving || _confirming;
      return PopScope(
        canPop: !disabled,
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(16),
          scrollable: true,
          title: Text(_editing ? 'Editar usuario' : 'Nuevo usuario'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: _form,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _editing
                          ? 'Actualiza los datos de la cuenta y su acceso.'
                          : 'Crea una cuenta y asigna uno de los roles del sistema.',
                    ),
                    if (_invalid) ...[
                      const SizedBox(height: 16),
                      Focus(
                        focusNode: _errorFocus,
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            'Revisa los campos indicados antes de guardar.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (state.saveError != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          state.saveError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _name,
                      enabled: !disabled,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                      autofillHints: const [AutofillHints.name],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          Validators.required(value, 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      enabled: !disabled,
                      maxLength: 254,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: const Key('user-role'),
                      initialValue: _role,
                      isExpanded: true,
                      itemHeight: null,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      validator: (value) =>
                          Validators.required(value, 'El rol'),
                      items: [
                        for (final role in state.roles)
                          DropdownMenuItem(
                            value: role.code,
                            child: Text(role.name),
                          ),
                      ],
                      onChanged: disabled || _ownAccount
                          ? null
                          : (value) {
                              if (value != null) setState(() => _role = value);
                            },
                    ),
                    if (_role == 'CONDUCTOR') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dni,
                        enabled: !disabled,
                        decoration: const InputDecoration(
                          labelText: 'DNI del conductor',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        validator: Validators.dni,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'La cuenta se vincula automáticamente al perfil con el mismo DNI. '
                        'Puedes crear primero la cuenta o el conductor.',
                      ),
                    ],
                    if (_ownAccount) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Por seguridad, no puedes cambiar tu propio rol ni desactivar tu cuenta.',
                      ),
                    ],
                    if (!_editing) ...[
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('new-user-password'),
                        controller: _password,
                        enabled: !disabled,
                        decoration: InputDecoration(
                          labelText: 'Contraseña inicial',
                          helperText:
                              'Al menos 8 caracteres con mayúscula, minúscula y número.',
                          helperMaxLines: 4,
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            onPressed: disabled
                                ? null
                                : () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        obscureText: _hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: validateAccountPassword,
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      SwitchListTile.adaptive(
                        key: const Key('user-active'),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cuenta activa'),
                        subtitle: const Text(
                          'Las cuentas inactivas no pueden iniciar sesión.',
                        ),
                        value: _active,
                        onChanged: disabled || _ownAccount
                            ? null
                            : (value) => setState(() => _active = value),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: disabled ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: disabled ? null : _submit,
              icon: state.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(state.saving ? 'Guardando…' : 'Guardar usuario'),
            ),
          ],
        ),
      );
    },
  );
}

String? validateAccountPassword(String? value) {
  if (value != null && utf8.encode(value).length > 72) {
    return 'La contraseña no puede superar 72 bytes. Reduce su longitud.';
  }
  if (value == null ||
      value.length < 8 ||
      !RegExp(r'[A-Z]').hasMatch(value) ||
      !RegExp(r'[a-z]').hasMatch(value) ||
      !RegExp(r'[0-9]').hasMatch(value)) {
    return 'Usa 8 caracteres o más, mayúscula, minúscula y número.';
  }
  return null;
}
