package com.pathseek.backend.driver.repository;

import com.pathseek.backend.driver.entity.Driver;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface DriverRepository extends JpaRepository<Driver, UUID> {

    boolean existsByDni(String dni);

    boolean existsByDniAndIdNot(String dni, UUID id);

    boolean existsByLicencia(String licencia);

    boolean existsByLicenciaAndIdNot(String licencia, UUID id);
}
