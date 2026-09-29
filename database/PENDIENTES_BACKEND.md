# Tareas Pendientes y Guía de Integración Backend - Módulo de Base de Datos

Este documento detalla los requerimientos, recomendaciones y tareas pendientes que el equipo de **Backend (Java / Spring Boot)** debe implementar para consumir de manera óptima los procedimientos almacenados, disparadores y tablas del módulo `database/`.

---

## 📌 Checklist de Tareas Pendientes

### 1. Migración Flyway (Integración Continua de BD)
- [ ] Crear la migración `V4__add_triggers_and_stored_procedures.sql` en `backend/src/main/resources/db/migration/`.
- [ ] Copiar el contenido de `database/02_triggers.sql` y `database/03_stored_procedures.sql` a la migración `V4`.
- [ ] Verificar que `mvn test` ejecute las migraciones sin errores sobre H2 / PostgreSQL de prueba.

---

### 2. Invocación de Procedimientos Almacenados en Spring Data JPA

#### A. Invocación de `sp_registrar_pedido`
Se recomienda invocar la función de BD a través de un `@Query` nativo en `OrderRepository.java`:

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, UUID> {

    @Query(value = "SELECT sp_registrar_pedido(:clienteId, :direccion, :gpsLat, :gpsLon, :peso, :volumen, :ventanaInicio, :ventanaFin, :prioridad, :tipoProducto)", nativeQuery = true)
    UUID registrarPedidoSp(
        @Param("clienteId") String clienteId,
        @Param("direccion") String direccion,
        @Param("gpsLat") BigDecimal gpsLat,
        @Param("gpsLon") BigDecimal gpsLon,
        @Param("peso") BigDecimal peso,
        @Param("volumen") BigDecimal volumen,
        @Param("ventanaInicio") String ventanaInicio,
        @Param("ventanaFin") String ventanaFin,
        @Param("prioridad") String prioridad,
        @Param("tipoProducto") String tipoProducto
    );
}
```

#### B. Bloqueo de Usuarios por Intentos Fallidos (RN-001)
Integrar la llamada a `sp_bloquear_usuario_intentos` en `AuthService.java` durante el manejo de credenciales incorrectas:

```java
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    @Query(value = "SELECT sp_bloquear_usuario_intentos(:usuarioId)", nativeQuery = true)
    Boolean registrarIntentoFallidoSp(@Param("usuarioId") UUID usuarioId);
}
```

#### C. Tarea Programada para Limpieza de Tokens Expirados
Crear un componente `@Scheduled` en el backend para invocar periódicamente la limpieza de tokens:

```java
@Component
public class TokenCleanupScheduler {

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    // Se ejecuta diariamente a las 3:00 AM
    @Scheduled(cron = "0 0 3 * * ?")
    @Transactional
    public void executeTokenCleanup() {
        int deletedCount = refreshTokenRepository.limpiarTokensExpiradosSp();
        log.info("Se limpiaron {} refresh tokens expirados de la base de datos.", deletedCount);
    }
}
```

#### D. Endpoint de Dashboard (RF-005)
Crear la DTO `DashboardSummaryResponse` y mapear el retorno de `sp_obtener_resumen_dashboard()`:

```java
@GetMapping("/dashboard/resumen")
@PreAuthorize("hasAnyRole('ADMIN', 'OPERADOR', 'AUDITOR')")
public ResponseEntity<String> getDashboardSummary() {
    String jsonSummary = dashboardService.getSummaryJson();
    return ResponseEntity.ok(jsonSummary);
}
```

---

### 3. Mapeo de Entidades JPA para Tablas del Roadmap

Cuando se inicie la iteración correspondiente al Roadmap (RF-003, RF-009), se deben crear las siguientes entidades JPA marcadas con `@Table`:

1. **`ClientEntity` (`clientes`)**:
   - `UUID clienteId`
   - `@OneToOne UserEntity usuario`
   - `String nombre`, `direccion`, `puntoReferencia`, `telefono`
2. **`RouteEntity` (`rutas`)**:
   - `UUID rutaId`
   - `LocalDate fecha`
   - `@ManyToOne DriverEntity conductor`
   - `@ManyToOne VehicleEntity vehiculo`
   - `BigDecimal distanciaKm`, `co2Kg`, `combustibleL`
   - `@Enumerated(EnumType.STRING) RouteStatus estado`
3. **`RouteOrderEntity` (`ruta_pedidos`)**:
   - Clave compuesta `@EmbeddedId RouteOrderId` (`rutaId`, `pedidoId`)
   - `Integer orden`, `LocalTime horaEstimada`, `Boolean cumplioVentana`
4. **`AuditEntity` (`auditoria`)**:
   - `UUID auditoriaId`
   - `@ManyToOne UserEntity usuario`
   - `String accion`, `entidad`, `detalles`, `ip`
   - `Instant fecha`

---

### 4. Manejo de Excepciones de Base de Datos en `GlobalExceptionHandler`

Mapear las excepciones SQL lanzadas por los triggers y procedimientos almacenados (códigos de error `23505` y `22023` con mensajes prefijados):

```java
@ExceptionHandler(DataIntegrityViolationException.class)
public ResponseEntity<ApiErrorResponse> handleDataIntegrity(DataIntegrityViolationException ex) {
    if (ex.getMessage().contains("ORDER_DUPLICATE")) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(new ApiErrorResponse("ORDER_DUPLICATE", "Ya existe un pedido activo registrado para esta dirección y horario."));
    }
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
        .body(new ApiErrorResponse("DATA_INTEGRITY_ERROR", "Error de integridad de datos."));
}
```

---

## 📅 Matriz de Prioridades para el Equipo Backend

| Tarea | Prioridad | Sprint Sugerido |
| --- | --- | --- |
| Copiar triggers y SP a migración Flyway `V4` | **Alta** | Sprint Actual |
| Integrar `sp_bloquear_usuario_intentos` en Login | **Alta** | Sprint Actual |
| Crear Scheduled Job para `sp_limpiar_tokens_expirados` | **Media** | Próximo Sprint |
| Endpoint `/api/v1/dashboard/resumen` usando SP | **Media** | Próximo Sprint |
| Entidades JPA `RouteEntity` y `RouteOrderEntity` | **Alta (para RF-003)** | Sprint Rutas |
