package com.pathseek.backend.client;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClientProfileRepository extends JpaRepository<ClientProfile, UUID> {

    Optional<ClientProfile> findByUsuarioId(UUID usuarioId);

    boolean existsByUsuarioIdAndIdNot(UUID usuarioId, UUID id);

    List<ClientProfile> findAllByOrderByNombreAsc();
}
