[← Volver al README Principal](../../README.md)

# Manual de Usuario — PathSeek V_1_0_0

**Proyecto:** PathSeek · **Fecha:** 2026-10-25 · **Responsable:** Equipo PIPRE

Plataforma de optimización de rutas sostenibles para **UGEL Huancayo**.

---

## 1. Acceso

| Perfil | Módulos disponibles |
| --- | --- |
| **ADMIN** | Resumen, Flota, Conductores, Pedidos, Clientes, Rutas, Reportes, Compensación, Configuración |
| **OPERADOR** | Resumen, Flota, Conductores, Pedidos, Clientes, Rutas, Reportes, Compensación |
| **AUDITOR** | Consulta de todo lo anterior, sin crear, editar ni eliminar |
| **CONDUCTOR** | Resumen, Rutas propias y Avisos de rutas |
| **CLIENTE** | Pedidos propios y su perfil en Clientes |

1. Abre la plataforma (web o APK móvil).
2. Inicia sesión con el correo y la contraseña entregados.
3. La sesión expira por inactividad; vuelve a iniciar sesión si se solicita.

---

## 2. Operación diaria (ADMIN / OPERADOR)

### 2.1 Preparar la operación
- **Flota:** registra vehículos con placa, tipo, capacidad, consumo y factor de emisión.
- **Conductores:** registra DNI, licencia, categoría y disponibilidad.
- **Pedidos:** registra dirección (o referencia), coordenadas, peso, volumen, ventana de entrega y prioridad. Puedes seleccionar el destino en el mapa.
- **Clientes:** registra los perfiles con horario de atención y restricciones de acceso; los pedidos de un cliente se asocian a su cuenta.

### 2.2 Generar rutas
1. Entra a **Rutas** y pulsa **Generar rutas**.
2. El motor agrupa los pedidos pendientes en vehículos disponibles respetando capacidad, ventanas y prioridades (EXPRESS → ESTANDAR → ECONÓMICO).
3. Los pedidos que no caben quedan como *no asignados* y aparecen en el aviso de resultado.

### 2.3 Ante un incidente en la vía
1. Abre el detalle de la ruta afectada.
2. Pulsa **Reportar incidente**: elige tipo (bloqueo, obras, accidente, congestión severa), describe, confirma coordenadas y radio.
3. Pulsa **Reoptimizar**: el sistema recalcula solo la secuencia pendiente, conserva las entregas realizadas y avisa al conductor.

### 2.4 Reportes y sostenibilidad
- **Reportes:** elige un rango de fechas (opcional) y descarga el PDF con emisiones, distancia, combustible y cumplimiento de ventanas por ruta.
- **Compensación:** consulta la huella anual, los árboles equivalentes y los proyectos locales sugeridos.

---

## 3. Modo conductor (CONDUCTOR)

1. Entra a **Rutas** para ver tus rutas asignadas y su secuencia de entregas.
2. **Reportar posición:** indica tu latitud/longitud actual (el sistema actualiza el progreso estimado).
3. **Completar entrega:** pulsa el botón de la parada correspondiente; debes respetar el orden de la secuencia.
4. **Avisos:** la campana superior muestra los incidentes o cambios de tu ruta; márcalos como leídos cuando los revises.
5. **Sin conexión:** la app muestra tu última ruta guardada, encola tus entregas y posición, y las sincroniza sola al recuperar la red.

> Las distancias, emisiones y horarios mostrados son estimaciones del optimizador; no corresponden a tráfico observado.

---

## 4. Módulo Clientes (CLIENTE)

1. Entra a **Clientes** y crea tu perfil con dirección, referencia, teléfono, horario de atención y restricciones de acceso.
2. Tus pedidos quedan asociados a tu cuenta; solo tú los ves y los creas.
3. Puedes actualizar tus preferencias cuando cambien.

---

## 5. Preguntas frecuentes

| Síntoma | Solución |
| --- | --- |
| No veo un módulo | Tu rol no tiene acceso a él; consulta la tabla de perfiles |
| Un pedido no se asignó | Falta capacidad o su ventana es inalcanzable; ajusta los datos |
| La ruta no muestra recorrido por calles | Sin conexión o proveedor no disponible; se muestra el esquema de paradas |
| Mis acciones quedaron en cola | Estás sin conexión; se sincronizarán automáticamente al volver la red |

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación del manual de usuario (EN-009). | Equipo PIPRE |
