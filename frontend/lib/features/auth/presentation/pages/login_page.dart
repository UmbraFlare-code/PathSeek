import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 1000 &&
                constraints.maxHeight >= 600 &&
                MediaQuery.textScalerOf(context).scale(16) < 23;
            final form = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth < 600 ? 24 : 40),
                  child: _LoginForm(state: state),
                ),
              ),
            );
            if (wide) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: SingleChildScrollView(child: _BrandPanel()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: form,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          color: AppTheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PathSeek',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distribución sostenible',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    form,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.route_outlined, color: Colors.white, size: 40),
      const SizedBox(height: 24),
      Text(
        'PathSeek',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 32),
      Text(
        'Cada entrega,\nmejor planificada.',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Gestión de la distribución para UGEL Huancayo.',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      const SizedBox(height: 32),
      for (final entry in const [
        (Icons.inventory_2_outlined, 'Pedidos y ventanas de entrega'),
        (Icons.map_outlined, 'Rutas y destinos en el mapa'),
        (Icons.eco_outlined, 'Indicadores de sostenibilidad'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(entry.$1, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.$2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.state});
  final AuthState state;
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.state.isLoading) return;
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(email: _email.text.trim(), password: _password.text),
      );
    } else {
      (Validators.email(_email.text) != null ? _emailFocus : _passwordFocus)
          .requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Inicia sesión',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accede a tu espacio de trabajo con tu cuenta de PathSeek.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              enabled: !state.isLoading,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              validator: Validators.email,
              autocorrect: false,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _password,
              focusNode: _passwordFocus,
              enabled: !state.isLoading,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscure
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.password,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.danger,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.isLoading ? null : _submit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      state.isLoading ? 'Iniciando sesión…' : 'Iniciar sesión',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
