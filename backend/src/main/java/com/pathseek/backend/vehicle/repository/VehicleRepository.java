package com.pathseek.backend.vehicle.repository;

import com.pathseek.backend.vehicle.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {

    boolean existsByPlaca(String placa);

    boolean existsByPlacaAndIdNot(String placa, UUID id);
}
