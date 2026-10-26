package com.pathseek.backend.carbon;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CarbonProjectRepository extends JpaRepository<CarbonProject, UUID> {

    List<CarbonProject> findByActivoTrueOrderByNombreAsc();
}
