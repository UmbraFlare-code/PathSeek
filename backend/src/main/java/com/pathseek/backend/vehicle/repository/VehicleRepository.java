package com.pathseek.backend.vehicle.repository;

import com.pathseek.backend.vehicle.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import jakarta.persistence.QueryHint;
import java.util.Collection;
import jakarta.persistence.LockModeType;
import java.util.List;

import java.util.UUID;

public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints({@QueryHint(name = "jakarta.persistence.lock.timeout", value = "0"),
            @QueryHint(name = "jakarta.persistence.query.timeout", value = "5000")})
    @Query("select v from Vehicle v where v.id in :ids order by v.id")
    List<Vehicle> lockPlanningSubset(Collection<UUID> ids);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select v from Vehicle v order by v.id")
    List<Vehicle> lockForPlanning();

    boolean existsByPlaca(String placa);

    boolean existsByPlacaAndIdNot(String placa, UUID id);
}
