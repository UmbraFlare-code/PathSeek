package com.pathseek.backend.carbon;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

/**
 * Siembra los proyectos locales de compensación cuando el catálogo está vacío.
 * Idempotente: no duplica proyectos ya cargados por la migración V8 o por una
 * instalación previa. Cubre además los entornos de prueba H2 sin migraciones.
 */
@Component
public class CarbonProjectBootstrap implements ApplicationRunner {

    private final CarbonProjectRepository repository;

    public CarbonProjectBootstrap(CarbonProjectRepository repository) {
        this.repository = repository;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (repository.count() > 0) return;
        save("Reforestación Valle del Mantaro",
                "Plantación de árboles nativos (queñual, quishuar) en laderas del Valle del Mantaro, Junín.",
                "REFORESTACION", new BigDecimal("35.00"));
        save("Agroforestería comunal Huancayo",
                "Sistemas agroforestales con familias campesinas de Huancayo, El Tambo y Chilca.",
                "REFORESTACION", new BigDecimal("28.50"));
        save("Eficiencia energética en escuelas",
                "Cambio de luminarias y aislamiento térmico en instituciones educativas de UGEL Huancayo.",
                "EFICIENCIA_ENERGETICA", new BigDecimal("42.00"));
    }

    private void save(String nombre, String descripcion, String tipo, BigDecimal costoTonelada) {
        CarbonProject project = new CarbonProject();
        project.setNombre(nombre);
        project.setDescripcion(descripcion);
        project.setTipo(tipo);
        project.setCostoTonelada(costoTonelada);
        repository.save(project);
    }
}
