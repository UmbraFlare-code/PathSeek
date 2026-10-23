package com.pathseek.backend.route.repository;
import com.pathseek.backend.route.entity.RoadIncident;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
public interface RoadIncidentRepository extends JpaRepository<RoadIncident, UUID> {
    List<RoadIncident> findByRuta_IdAndActivaTrue(UUID routeId);
    List<RoadIncident> findByRuta_IdInAndActivaTrue(Collection<UUID> routeIds);
}
