package com.ivan.prota.appointmentbooking.repositories;

import com.ivan.prota.appointmentbooking.model.Business;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BusinessRepository extends JpaRepository<Business, Long> {
    List<Business> findByOwnerId(Long id);
    List<Business> findByNameContainingIgnoreCaseOrAddressContainingIgnoreCase(
        String name,
        String address
    );
}
