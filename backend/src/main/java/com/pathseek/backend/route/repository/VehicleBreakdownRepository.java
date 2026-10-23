package com.pathseek.backend.route.repository;
import com.pathseek.backend.route.entity.VehicleBreakdown;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;
public interface VehicleBreakdownRepository extends JpaRepository<VehicleBreakdown, UUID> {
    @Query("select b.id from VehicleBreakdown b where b.activa = true")
    List<UUID> findActiveVehicleIds();
}
