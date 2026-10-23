import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/permissions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/catalog_layout.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/responsive_field_row.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/user_form_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    if (!AppPermissions.canView(user, AppModule.settings)) {
      return const ErrorView(message: 'No tienes acceso a Configuración.');
    }
    return BlocProvider(
      create: (_) => locator<SettingsBloc>()
        ..add(SettingsLoaded(manageUsers: AppPermissions.canManageUsers(user))),
      child: SettingsView(user: user),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.user});
  final AppUser user;
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _search = TextEditingController();
  bool _rolesSelected = false;
  String? _role;
  bool? _active;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter() => context.read<SettingsBloc>().add(
    SettingsUsersLoaded(
      UserQuery(search: _search.text.trim(), role: _role, active: _active),
    ),
  );

  void _form([UserAccount? account]) {
    final bloc = context.read<SettingsBloc>();
    bloc.add(SettingsUserFormOpened());
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: UserFormDialog(account: account, currentUserId: widget.user.id),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SettingsBloc, SettingsState>(
    builder: (context, state) {
      final manageUsers = AppPermissions.canManageUsers(widget.user);
      final showRoles = _rolesSelected || !manageUsers;
      final page = state.userPage;
      final users = page?.users ?? const <UserAccount>[];
      final loading = showRoles ? state.loadingRoles : state.loadingUsers;
      final error = showRoles ? state.rolesError : state.usersError;
      return CatalogLayout(
        title: 'Configuración',
        description: manageUsers
            ? 'Administra las cuentas y consulta el alcance de cada rol.'
            : 'Consulta los roles y permisos vigentes. Acceso de solo lectura.',
        icon: Icons.settings_outlined,
        actions: [
          if (!showRoles)
            FilledButton.icon(
              onPressed: state.roles.isEmpty || state.loadingRoles
                  ? null
                  : () => _form(),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Nuevo usuario'),
            ),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () {
                    context.read<SettingsBloc>().add(
                      showRoles
                          ? SettingsRolesLoaded()
                          : SettingsUsersLoaded(state.query),
                    );
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
          ),
        ],
        toolbar: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (manageUsers) ...[
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Usuarios'),
                    selected: !showRoles,
                    onSelected: (_) => setState(() => _rolesSelected = false),
                  ),
                  ChoiceChip(
                    label: const Text('Roles y permisos'),
                    selected: showRoles,
                    onSelected: (_) => setState(() => _rolesSelected = true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (showRoles) ...[
              Text(
                'Roles y permisos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Los permisos pertenecen a roles predefinidos. '
                'La asignación de roles se realiza al crear o editar una cuenta.',
              ),
            ] else ...[
              if (state.rolesError != null) ...[
                ErrorView(
                  message: state.rolesError!,
                  onRetry: () =>
                      context.read<SettingsBloc>().add(SettingsRolesLoaded()),
                ),
                const SizedBox(height: 16),
              ],
              ResponsiveFieldRow(
                children: [
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o correo',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _filter(),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _role ?? '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por rol',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos los roles'),
                      ),
                      for (final role in state.roles)
                        DropdownMenuItem(
                          value: role.code,
                          child: Text(role.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _role = value == '' ? null : value);
                      _filter();
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: 'all',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por estado',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos los estados'),
                      ),
                      DropdownMenuItem(value: 'active', child: Text('Activos')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactivos'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(
                        () => _active = switch (value) {
                          'active' => true,
                          'inactive' => false,
                          _ => null,
                        },
                      );
                      _filter();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _filter,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                  if (page != null) ...[
                    Text(
                      '${page.totalElements} cuentas · Página '
                      '${page.totalPages == 0 ? 0 : page.page + 1} de ${page.totalPages}',
                    ),
                    IconButton(
                      tooltip: 'Página anterior',
                      onPressed: loading || page.page <= 0
                          ? null
                          : () => context.read<SettingsBloc>().add(
                              SettingsUsersLoaded(
                                state.query.atPage(page.page - 1),
                              ),
                            ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: 'Página siguiente',
                      onPressed: loading || page.page + 1 >= page.totalPages
                          ? null
                          : () => context.read<SettingsBloc>().add(
                              SettingsUsersLoaded(
                                state.query.atPage(page.page + 1),
                              ),
                            ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        isLoading: loading,
        loadingMessage: showRoles ? 'Cargando roles…' : 'Cargando usuarios…',
        emptyMessage: showRoles
            ? 'No hay roles disponibles.'
            : 'No se encontraron usuarios con estos filtros.',
        itemCount: showRoles ? state.roles.length : users.length,
        totalCount: showRoles ? state.roles.length : page?.totalElements ?? 0,
        errorMessage: error,
        onRetry: () => context.read<SettingsBloc>().add(
          showRoles ? SettingsRolesLoaded() : SettingsUsersLoaded(state.query),
        ),
        itemBuilder: (context, index) => showRoles
            ? _RoleCard(role: state.roles[index])
            : _UserCard(
                account: users[index],
                roles: state.roles,
                ownAccount: users[index].id == widget.user.id,
                onEdit: state.roles.isEmpty || state.loadingRoles
                    ? null
                    : () => _form(users[index]),
              ),
      );
    },
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});
  final RoleDefinition role;
  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusBadge(
            label: role.code,
            icon: Icons.shield_outlined,
            tone: StatusTone.info,
          ),
          const SizedBox(height: 16),
          Text(role.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(role.description),
          const Divider(height: 32),
          Text(
            'Permisos vigentes',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          for (final permission in role.permissions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(permission)),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.account,
    required this.roles,
    required this.ownAccount,
    required this.onEdit,
  });
  final UserAccount account;
  final List<RoleDefinition> roles;
  final bool ownAccount;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    final roleName =
        roles.where((role) => role.code == account.role).firstOrNull?.name ??
        account.role;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        Text(account.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(account.email),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: account.active ? 'Activo' : 'Inactivo',
                  icon: account.active
                      ? Icons.check_circle_outline
                      : Icons.block_outlined,
                  tone: account.active
                      ? StatusTone.success
                      : StatusTone.neutral,
                ),
                if (ownAccount)
                  const StatusBadge(
                    label: 'Tu cuenta',
                    icon: Icons.person_outline,
                  ),
                if (account.isBlocked)
                  const StatusBadge(
                    label: 'Bloqueo temporal',
                    icon: Icons.lock_clock_outlined,
                    tone: StatusTone.warning,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Rol: $roleName'),
            const SizedBox(height: 8),
            Text(
              account.lastLogin == null
                  ? 'Sin inicio de sesión registrado'
                  : 'Último acceso: ${_date(account.lastLogin!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (account.isBlocked) ...[
              const SizedBox(height: 8),
              Text('Bloqueado hasta: ${_date(account.blockedUntil!)}'),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar usuario'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime value) {
    final date = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
