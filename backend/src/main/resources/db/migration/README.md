# Migraciones de PathSeek

Esta carpeta es la fuente de migraciones ejecutadas por Spring Boot antes de validar JPA. V1/V2/V3 adoptan la base histórica mediante DDL idempotente; V5/V6/V7 incorporan las ampliaciones existentes. V4 se reserva al seed de desarrollo histórico y no se ejecuta como migración: no se recrean cuentas, contraseñas ni pedidos al actualizar una base existente.

Las bases sin historial se adoptan con baseline 0 y reciben todas las migraciones. Las nuevas se crean desde V1. Flyway conserva `flyway_schema_history`, verifica checksums y bloquea migraciones concurrentes. Una migración fallida impide iniciar el backend.

No modificar archivos versionados después de distribuirlos; añadir V8, V9, etc. para los próximos cambios. Los archivos en `database/` quedan como scripts históricos de compatibilidad y semilla; no son el mecanismo de actualización. Las envolturas BEGIN/COMMIT históricas se retiraron de estas copias porque Flyway administra la transacción.

Compose conserva los scripts iniciales 01–04 para mantener los datos demo únicamente en volúmenes locales nuevos; las ampliaciones 05–07 se ejecutan por Flyway, tanto en bases nuevas como existentes. La aplicación Java también migra automáticamente una base PostgreSQL vacía, aunque no use Docker. Nunca se ejecuta clean automáticamente.
