import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/auth_bloc.dart';

/// Propuesta de diseño Minimalista y Flat para el Login móvil de PathSeek.
/// Prioriza tipografía ligera (w300/w400), líneas limpias, cero sombras pesadas
/// y una ergonomía optimizada para interacción táctil en dispositivos móviles.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1411),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Cabecera Minimalista
                      const _MinimalMobileHeader(),
                      const SizedBox(height: 36),

                      // 2. Tarjeta Flat de Formulario
                      _FlatLoginCard(state: state),

                      const SizedBox(height: 28),

                      // 3. Accesos Rápidos de Demostración (Chips Flat para Móvil)
                      const _QuickRoleCredentials(),

                      const SizedBox(height: 32),

                      // 4. Pie Institucional
                      const _MinimalFooter(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Cabecera con isotipo geométrico lineal y tipografía ligera
class _MinimalMobileHeader extends StatelessWidget {
  const _MinimalMobileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Isotipo geométrico flat
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF162019),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.alt_route_rounded,
              color: AppTheme.accent,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Título del Sistema en tipografía ligera
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Path',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Seek',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Subtítulo institucional delicado
        const Text(
          'UGEL Huancayo  •  Logística Sostenible',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8E9E93),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

/// Tarjeta Flat sin sombras, con borde tenue y fondo mate
class _FlatLoginCard extends StatelessWidget {
  final AuthState state;

  const _FlatLoginCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF141C16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Etiqueta superior sutil
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACCESO AL SISTEMA',
                style: TextStyle(
                  color: Color(0xFF9EAEA3),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Título del formulario
          const Text(
            'Ingresa a tu cuenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa tus credenciales para gestionar rutas y flota',
            style: TextStyle(
              color: Color(0xFF7E8F83),
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),

          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LoadingIndicator(
                message: 'Verificando credenciales...',
              ),
            )
          else
            const _LoginForm(),
        ],
      ),
    );
  }
}

/// Formulario Flat con inputs lineales y tipografía ligera
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo Correo
          const Text(
            'Correo electrónico',
            style: TextStyle(
              color: Color(0xFFB0C0B5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: 'ejemplo@pathseek.pe',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: Color(0xFF7E8F83),
                size: 19,
              ),
              filled: true,
              fillColor: const Color(0xFF1B251F),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppTheme.accent,
                  width: 1.2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.2,
                ),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
          ),
          const SizedBox(height: 18),

          // Campo Contraseña
          const Text(
            'Contraseña',
            style: TextStyle(
              color: Color(0xFFB0C0B5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF7E8F83),
                size: 19,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF7E8F83),
                  size: 19,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFF1B251F),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppTheme.accent,
                  width: 1.2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 1.2,
                ),
              ),
            ),
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            validator: Validators.password,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 26),

          // Botón Flat de Ingreso
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector rápido de credenciales para comodidad en pruebas móviles
class _QuickRoleCredentials extends StatelessWidget {
  const _QuickRoleCredentials();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'CUENTAS DE DEMOSTRACIÓN',
            style: TextStyle(
              color: Color(0xFF6E7E73),
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: const [
            _RoleChip(
              roleName: 'Admin',
              email: 'admin@pathseek.pe',
              icon: Icons.shield_outlined,
            ),
            _RoleChip(
              roleName: 'Operador',
              email: 'operador@pathseek.pe',
              icon: Icons.tune_rounded,
            ),
            _RoleChip(
              roleName: 'Conductor',
              email: 'conductor.juan@pathseek.pe',
              icon: Icons.directions_car_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String roleName;
  final String email;
  final IconData icon;

  const _RoleChip({
    required this.roleName,
    required this.email,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<AuthBloc>().add(
              AuthLoginRequested(
                email: email,
                password: 'Admin123!',
              ),
            );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF131B15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: AppTheme.accent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 5),
            Text(
              roleName,
              style: const TextStyle(
                color: Color(0xFFA5B5AA),
                fontSize: 11.5,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pie de página minimalista con versión, entidad y micro-badge de sostenibilidad
class _MinimalFooter extends StatelessWidget {
  const _MinimalFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 13,
              color: AppTheme.accent.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 5),
            Text(
              'Optimización de Emisiones CO₂',
              style: TextStyle(
                color: const Color(0xFF8E9E93).withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'v1.0.0-MVP  •  Huancayo, Perú',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 11,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
