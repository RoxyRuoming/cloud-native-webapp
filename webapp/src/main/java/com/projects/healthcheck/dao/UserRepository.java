package com.projects.healthcheck.dao;

import com.projects.healthcheck.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    // custom query method
    Optional<User> findByUsername(String username);
}
