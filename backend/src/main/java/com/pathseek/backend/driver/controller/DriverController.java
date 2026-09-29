package com.pathseek.backend.driver.controller;

import com.pathseek.backend.driver.dto.DriverRequest;
import com.pathseek.backend.driver.dto.DriverResponse;
import com.pathseek.backend.driver.service.DriverService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/conductores")
@Tag(name = "Conductores", description = "Gestión de conductores")
public class DriverController {

    private final DriverService driverService;

    public DriverController(DriverService driverService) {
        this.driverService = driverService;
    }

    @GetMapping
    @Operation(summary = "Lista todos los conductores")
    public ResponseEntity<List<DriverResponse>> findAll() {
        return ResponseEntity.ok(driverService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Busca un conductor por su identificador")
    public ResponseEntity<DriverResponse> findById(@PathVariable UUID id) {
        return ResponseEntity.ok(driverService.findById(id));
    }

    @PostMapping
    @Operation(summary = "Registra un conductor")
    public ResponseEntity<DriverResponse> create(@Valid @RequestBody DriverRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(driverService.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualiza un conductor")
    public ResponseEntity<DriverResponse> update(
            @PathVariable UUID id,
            @Valid @RequestBody DriverRequest request) {
        return ResponseEntity.ok(driverService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Elimina un conductor")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        driverService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
