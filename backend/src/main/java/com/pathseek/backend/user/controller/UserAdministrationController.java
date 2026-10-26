package com.pathseek.backend.user.controller;

import com.pathseek.backend.user.dto.*;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.service.UserAdministrationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "Usuarios y Configuración", description = "Administración de cuentas y catálogo de roles (EN-003)")
public class UserAdministrationController {
    private final UserAdministrationService service;
    public UserAdministrationController(UserAdministrationService service) { this.service = service; }

    @GetMapping("/usuarios")
    @Operation(summary = "Lista cuentas de usuario", description = "Paginado con búsqueda por nombre/correo y filtros por rol y estado; solo ADMIN")
    public UserPageResponse list(@RequestParam(defaultValue = "0") int pagina,
            @RequestParam(defaultValue = "20") int tamano, @RequestParam(required = false) String buscar,
            @RequestParam(required = false) UserRole rol, @RequestParam(required = false) Boolean activo) {
        return service.list(pagina, tamano, buscar, rol, activo);
    }

    @PostMapping("/usuarios")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Crea una cuenta de usuario")
    public UserResponse create(@Valid @RequestBody CreateUserRequest request) { return service.create(request); }

    @PutMapping("/usuarios/{id}")
    @Operation(summary = "Edita nombre, correo, rol o estado de una cuenta")
    public UserResponse update(@PathVariable UUID id, @Valid @RequestBody UpdateUserRequest request) {
        return service.update(id, request);
    }

    @GetMapping("/configuracion/roles")
    @Operation(summary = "Consulta el catálogo de roles y capacidades implementadas")
    public List<RoleResponse> roles() {
        // Catalog of currently implemented capabilities; target-only roadmap features are not advertised.
        return List.of(
                new RoleResponse(UserRole.ADMIN, "Administrador", "Administra cuentas y la operación del sistema.",
                        List.of("Gestionar usuarios y roles", "Consultar configuración de roles", "Gestionar flota, conductores y pedidos",
                                "Generar y reoptimizar rutas", "Consultar mapas, indicadores y avisos de rutas")),
                new RoleResponse(UserRole.OPERADOR, "Operador logístico", "Planifica y supervisa las entregas.",
                        List.of("Consultar configuración de roles", "Gestionar flota, conductores y pedidos",
                                "Generar y reoptimizar rutas", "Consultar mapas, indicadores y avisos de rutas")),
                new RoleResponse(UserRole.AUDITOR, "Auditor", "Consulta la información operativa sin modificarla.",
                        List.of("Consultar configuración de roles", "Consultar flota, conductores y pedidos",
                                "Consultar rutas, mapas, indicadores y avisos de rutas")),
                new RoleResponse(UserRole.CONDUCTOR, "Conductor", "Consulta las rutas vinculadas a su perfil de conductor.",
                        List.of("Consultar rutas y mapas propios", "Consultar indicadores propios", "Consultar y marcar avisos propios como leídos")),
                new RoleResponse(UserRole.CLIENTE, "Cliente", "Registra pedidos y consulta sus entregas.",
                        List.of("Crear pedidos", "Consultar pedidos propios")));
    }
}
