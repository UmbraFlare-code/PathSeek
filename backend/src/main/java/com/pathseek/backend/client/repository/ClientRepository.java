package com.pathseek.backend.client.repository;

import com.pathseek.backend.client.entity.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClientRepository extends JpaRepository<Client, UUID> {
    List<Client> findByActivoTrue();
    Optional<Client> findByNombreIgnoreCase(String nombre);
}
