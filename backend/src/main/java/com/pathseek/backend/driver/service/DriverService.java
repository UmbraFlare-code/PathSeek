package com.pathseek.backend.driver.service;

import com.pathseek.backend.driver.dto.DriverRequest;
import com.pathseek.backend.driver.dto.DriverResponse;
import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class DriverService {

    private static final String DNI_CONFLICT_CODE = "DRIVER_DNI_CONFLICT";
    private static final String DNI_CONFLICT_MESSAGE = "Ya existe un conductor registrado con ese DNI";
    private static final String LICENSE_CONFLICT_CODE = "DRIVER_LICENSE_CONFLICT";
    private static final String LICENSE_CONFLICT_MESSAGE = "Ya existe un conductor registrado con esa licencia";

    private final DriverRepository driverRepository;

    public DriverService(DriverRepository driverRepository) {
        this.driverRepository = driverRepository;
    }

    @Transactional(readOnly = true)
    public List<DriverResponse> findAll() {
        return driverRepository.findAll(Sort.by("nombre")).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public DriverResponse findById(UUID id) {
        return toResponse(getDriver(id));
    }

    @Transactional
    public DriverResponse create(DriverRequest request) {
        String dni = normalizeDni(request.dni());
        String licencia = normalizeLicense(request.licencia());
        assertUnique(dni, licencia, null);

        Driver driver = new Driver();
        apply(driver, request, dni, licencia, true);
        return toResponse(save(driver));
    }

    @Transactional
    public DriverResponse update(UUID id, DriverRequest request) {
        Driver driver = getDriver(id);
        String dni = normalizeDni(request.dni());
        String licencia = normalizeLicense(request.licencia());
        assertUnique(dni, licencia, id);

        apply(driver, request, dni, licencia, false);
        return toResponse(save(driver));
    }

    @Transactional
    public void delete(UUID id) {
        Driver driver = getDriver(id);
        driverRepository.delete(driver);
    }

    private Driver getDriver(UUID id) {
        return driverRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("No se encontró el conductor solicitado"));
    }

    private void assertUnique(String dni, String licencia, UUID excludedId) {
        boolean dniTaken = excludedId == null
                ? driverRepository.existsByDni(dni)
                : driverRepository.existsByDniAndIdNot(dni, excludedId);
        if (dniTaken) {
            throw new BusinessConflictException(DNI_CONFLICT_CODE, DNI_CONFLICT_MESSAGE);
        }

        boolean licenseTaken = excludedId == null
                ? driverRepository.existsByLicencia(licencia)
                : driverRepository.existsByLicenciaAndIdNot(licencia, excludedId);
        if (licenseTaken) {
            throw new BusinessConflictException(LICENSE_CONFLICT_CODE, LICENSE_CONFLICT_MESSAGE);
        }
    }

    private Driver save(Driver driver) {
        try {
            return driverRepository.saveAndFlush(driver);
        } catch (DataIntegrityViolationException exception) {
            throw new BusinessConflictException(DNI_CONFLICT_CODE, DNI_CONFLICT_MESSAGE);
        }
    }

    private void apply(Driver driver, DriverRequest request, String dni, String licencia, boolean creating) {
        driver.setUsuarioId(parseUsuarioId(request.usuarioId()));
        driver.setDni(dni);
        driver.setNombre(request.nombre().trim());
        driver.setLicencia(licencia);
        driver.setCategoria(request.categoria());
        driver.setExperiencia(request.experiencia());
        if (request.disponible() != null) {
            driver.setDisponible(request.disponible());
        } else if (creating) {
            driver.setDisponible(true);
        }
        String contacto = request.contacto() == null || request.contacto().isBlank()
                ? null
                : request.contacto().trim();
        driver.setContacto(contacto);
    }

    private DriverResponse toResponse(Driver driver) {
        return new DriverResponse(
                driver.getId(),
                driver.getUsuarioId(),
                driver.getDni(),
                driver.getNombre(),
                driver.getLicencia(),
                driver.getCategoria(),
                driver.getExperiencia(),
                driver.getDisponible(),
                driver.getContacto());
    }

    private String normalizeDni(String dni) {
        return dni.trim();
    }

    private String normalizeLicense(String licencia) {
        return licencia.trim().toUpperCase(Locale.ROOT).replace("-", "");
    }

    private UUID parseUsuarioId(String usuarioId) {
        if (usuarioId == null || usuarioId.isBlank()) {
            return null;
        }
        try {
            return UUID.fromString(usuarioId.trim());
        } catch (IllegalArgumentException exception) {
            throw new BusinessRuleException(
                    "INVALID_DRIVER_USER",
                    "El usuario_id no es un identificador válido");
        }
    }
}
