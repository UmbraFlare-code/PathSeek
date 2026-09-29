package com.pathseek.backend.vehicle.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.vehicle.dto.VehicleRequest;
import com.pathseek.backend.vehicle.dto.VehicleResponse;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Year;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class VehicleService {

    private static final String PLATE_CONFLICT_CODE = "VEHICLE_PLATE_CONFLICT";
    private static final String PLATE_CONFLICT_MESSAGE = "Ya existe un vehículo registrado con esa placa";

    private final VehicleRepository vehicleRepository;

    public VehicleService(VehicleRepository vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }

    @Transactional(readOnly = true)
    public List<VehicleResponse> findAll() {
        return vehicleRepository.findAll(Sort.by("placa")).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public VehicleResponse findById(UUID id) {
        return toResponse(getVehicle(id));
    }

    @Transactional
    public VehicleResponse create(VehicleRequest request) {
        validateYear(request.anio());
        String normalizedPlate = normalizePlate(request.placa());
        if (vehicleRepository.existsByPlaca(normalizedPlate)) {
            throw plateConflict();
        }

        Vehicle vehicle = new Vehicle();
        apply(vehicle, request, normalizedPlate);
        return toResponse(save(vehicle));
    }

    @Transactional
    public VehicleResponse update(UUID id, VehicleRequest request) {
        validateYear(request.anio());
        Vehicle vehicle = getVehicle(id);
        String normalizedPlate = normalizePlate(request.placa());
        if (vehicleRepository.existsByPlacaAndIdNot(normalizedPlate, id)) {
            throw plateConflict();
        }

        apply(vehicle, request, normalizedPlate);
        return toResponse(save(vehicle));
    }

    @Transactional
    public void delete(UUID id) {
        Vehicle vehicle = getVehicle(id);
        vehicleRepository.delete(vehicle);
    }

    private Vehicle getVehicle(UUID id) {
        return vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("No se encontró el vehículo solicitado"));
    }

    private Vehicle save(Vehicle vehicle) {
        try {
            return vehicleRepository.saveAndFlush(vehicle);
        } catch (DataIntegrityViolationException exception) {
            throw plateConflict();
        }
    }

    private void apply(Vehicle vehicle, VehicleRequest request, String normalizedPlate) {
        vehicle.setPlaca(normalizedPlate);
        vehicle.setTipo(request.tipo());
        vehicle.setCapacidadKg(request.capacidadKg());
        vehicle.setCapacidadM3(request.capacidadM3());
        vehicle.setConsumoKmL(request.consumoKmL());
        vehicle.setFactorEmision(request.factorEmision());
        vehicle.setAnio(request.anio());
        vehicle.setRestriccionPlacaDigito(request.restriccionPlacaDigito());
    }

    private VehicleResponse toResponse(Vehicle vehicle) {
        return new VehicleResponse(
                vehicle.getId(),
                vehicle.getPlaca(),
                vehicle.getTipo(),
                vehicle.getCapacidadKg(),
                vehicle.getCapacidadM3(),
                vehicle.getConsumoKmL(),
                vehicle.getFactorEmision(),
                vehicle.getAnio(),
                vehicle.getRestriccionPlacaDigito());
    }

    private void validateYear(Integer year) {
        int maximumYear = Year.now().getValue() + 1;
        if (year != null && year > maximumYear) {
            throw new BusinessRuleException(
                    "INVALID_VEHICLE_YEAR",
                    "El año del vehículo no puede ser posterior a " + maximumYear);
        }
    }

    private String normalizePlate(String plate) {
        return plate.trim().toUpperCase(Locale.ROOT);
    }

    private BusinessConflictException plateConflict() {
        return new BusinessConflictException(PLATE_CONFLICT_CODE, PLATE_CONFLICT_MESSAGE);
    }
}
