package com.pathseek.backend;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.UUID;
import static org.assertj.core.api.Assertions.assertThat;

/** Real PostgreSQL only: each scenario owns a distinct temporary schema. */
@EnabledIfEnvironmentVariable(named = "SPRING_DATASOURCE_URL", matches = "jdbc:postgresql:.*")
class FlywayMigrationTests {
    @Test void emptyDatabaseIsMigratedAndRestartDoesNotReapply() throws Exception { verify(false); }
    @Test void legacyDatabaseKeepsAccountsAndLinksDniWithoutManualMigration() throws Exception { verify(true); }

    private void verify(boolean legacy) throws Exception {
        String schema = "migration_test_" + UUID.randomUUID().toString().replace("-", "");
        String url = System.getenv("SPRING_DATASOURCE_URL");
        String user = System.getenv("SPRING_DATASOURCE_USERNAME");
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        try (Connection connection = DriverManager.getConnection(url, user, password);
             Statement sql = connection.createStatement()) {
            sql.execute("CREATE SCHEMA " + schema);
            connection.setSchema(schema);
            try {
                if (legacy) {
                    try (var resource = getClass().getResourceAsStream("/db/migration/V1__initial_schema.sql")) {
                        sql.execute(new String(resource.readAllBytes(), StandardCharsets.UTF_8));
                    }
                    sql.execute("INSERT INTO usuarios(usuario_id,nombre,email,password_hash,rol,activo) VALUES ('11111111-1111-4111-8111-111111111111','Cuenta conservada','legacy@test.example','hash_personalizado','CONDUCTOR',true)");
                    sql.execute("INSERT INTO conductores(usuario_id,dni,nombre,licencia,categoria,experiencia,disponible) VALUES ('11111111-1111-4111-8111-111111111111','12345678','Perfil conservado','Q12345678','AIII',2,true)");
                }
                var flyway = Flyway.configure().dataSource(url, user, password)
                        .schemas(schema).defaultSchema(schema).locations("classpath:db/migration")
                        .baselineOnMigrate(true).baselineVersion("0").cleanDisabled(true).load();
                assertThat(flyway.migrate().migrationsExecuted).isEqualTo(6);
                assertThat(flyway.migrate().migrationsExecuted).isZero();
                flyway.validate();
                try (ResultSet result = sql.executeQuery("SELECT count(*) FROM flyway_schema_history WHERE success AND type = 'SQL'")) {
                    result.next(); assertThat(result.getInt(1)).isEqualTo(6);
                }
                try (ResultSet result = sql.executeQuery("SELECT count(*) FROM reoptimizacion_eventos")) {
                    result.next(); assertThat(result.getInt(1)).isZero();
                }
                try (ResultSet result = sql.executeQuery("SELECT nombre,password_hash,dni,token_version FROM usuarios")) {
                    if (legacy) {
                        assertThat(result.next()).isTrue();
                        assertThat(result.getString(1)).isEqualTo("Cuenta conservada");
                        assertThat(result.getString(2)).isEqualTo("hash_personalizado");
                        assertThat(result.getString(3)).isEqualTo("12345678");
                        assertThat(result.getLong(4)).isZero();
                    } else assertThat(result.next()).isFalse();
                }
            } finally {
                connection.setSchema("public");
                sql.execute("DROP SCHEMA " + schema + " CASCADE");
            }
        }
    }
}
