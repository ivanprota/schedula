package com.ivan.prota.appointmentbooking.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ivan.prota.appointmentbooking.model.Appointment;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    
    List<Appointment> findByService_Business_IdAndDate(Long businessId, LocalDate date);
    List<Appointment> findByUserId(Long userId);
    List<Appointment> findByService_Business_OwnerId(Long ownerId);
}
