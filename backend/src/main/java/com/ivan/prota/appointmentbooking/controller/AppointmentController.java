package com.ivan.prota.appointmentbooking.controller;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.ivan.prota.appointmentbooking.dto.AppointmentCreationRequest;
import com.ivan.prota.appointmentbooking.model.Appointment;
import com.ivan.prota.appointmentbooking.services.AppointmentService;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {
    
    @Autowired
    private AppointmentService appointmentService;

    @GetMapping
    public List<Appointment> getAllAppointment() {
        return appointmentService.getAllAppointments();
    }

    @GetMapping("/{id}")
    public Optional<Appointment> getAppointmentById(@PathVariable Long id) {
        return appointmentService.getAppointmentById(id);
    }
    
    @GetMapping("/business/{businessId}/date/{date}")
    public List<Appointment> getAppointmentsForBusinessAndDate(@PathVariable Long businessId, @PathVariable String date) {
        LocalDate parsedDate = LocalDate.parse(date);
        return appointmentService.getAppointmentsByBusinessAndDate(businessId, parsedDate);
    }
    
    @GetMapping("/user/{userId}")
    public List<Appointment> getAppointmentsByUserId(@PathVariable Long userId) {
        return appointmentService.getAppointmentsByUserId(userId);
    }

    @GetMapping("/owner/{ownerId}")
    public List<Appointment> getAppointmentsForOwner(@PathVariable Long ownerId) {
        return appointmentService.getAppointmentsForOwnerBusinesses(ownerId);
    }


    @PostMapping
    public Appointment createAppointment(@RequestBody AppointmentCreationRequest request) {
        return appointmentService.createAppointmentFromRequest(request);
    }

    @PutMapping("/{id}")
    public Appointment updateAppointment(@PathVariable Long id, @RequestBody Appointment uptadedAppointmentData) {
        return appointmentService.updateAppointment(id, uptadedAppointmentData);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<Void> deleteAppointment(@PathVariable Long id) {
        appointmentService.deleteAppointment(id);
        return ResponseEntity.ok().build();
    }
}
