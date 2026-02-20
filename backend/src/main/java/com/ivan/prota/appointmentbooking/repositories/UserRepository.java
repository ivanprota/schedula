package com.ivan.prota.appointmentbooking.repositories;

import com.ivan.prota.appointmentbooking.model.User;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;


public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);  
}
