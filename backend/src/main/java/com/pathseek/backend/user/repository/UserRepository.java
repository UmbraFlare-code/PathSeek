package com.pathseek.backend.user.repository;

import com.pathseek.backend.user.entity.User;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID>, org.springframework.data.jpa.repository.JpaSpecificationExecutor<User> {

    Optional<User> findByEmail(String email);
    Optional<User> findByDni(String dni);

    boolean existsByEmail(String email);

    boolean existsByEmailIgnoreCaseAndIdNot(String email, UUID id);

    boolean existsByEmailIgnoreCase(String email);

    long countByRolAndActivo(com.pathseek.backend.user.entity.UserRole rol, boolean activo);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where u.id = :id")
    Optional<User> findByIdForUpdate(@Param("id") UUID id);

    // Serialize administration of existing administrators before checking the last active one.
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where u.rol = com.pathseek.backend.user.entity.UserRole.ADMIN order by u.id")
    java.util.List<User> lockAdministrators();

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where lower(u.email) = :email")
    Optional<User> findByEmailForUpdate(@Param("email") String email);
}
