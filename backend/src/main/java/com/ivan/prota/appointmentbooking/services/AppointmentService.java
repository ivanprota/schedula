package com.ivan.prota.appointmentbooking.services;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ivan.prota.appointmentbooking.dto.AppointmentCreationRequest;
import com.ivan.prota.appointmentbooking.model.Appointment;
import com.ivan.prota.appointmentbooking.model.AppointmentsStatus;
import com.ivan.prota.appointmentbooking.model.BusinessService;
import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.repositories.AppointmentRepository;
import com.ivan.prota.appointmentbooking.repositories.BusinessServiceRepository;
import com.ivan.prota.appointmentbooking.repositories.UserRepository;

@Service
public class AppointmentService {

    @Autowired
    private UserRepository userRepository;

    private final AppointmentRepository appointmentRepository;
    private final BusinessServiceRepository businessServiceRepository;

    public AppointmentService(AppointmentRepository appointmentRepository,
                              BusinessServiceRepository businessServiceRepository) {
        this.appointmentRepository = appointmentRepository;
        this.businessServiceRepository = businessServiceRepository;
    }

    public Appointment createAppointment(Appointment appointment) {
        return appointmentRepository.save(appointment);
    }

    public Appointment createAppointmentFromRequest(AppointmentCreationRequest request) {

        BusinessService service = businessServiceRepository
            .findById(request.getServiceId())
            .orElseThrow(() -> new RuntimeException("Servizio non trovato"));

        LocalDate date = LocalDate.parse(request.getDate());
        LocalTime time = LocalTime.parse(request.getTime());

        Appointment appointment = new Appointment();
        appointment.setService(service);
        appointment.setDate(date);
        appointment.setTime(time);
        appointment.setStatus(AppointmentsStatus.BOOKED);

        User user = userRepository.findById(request.getUserId()).orElseThrow(() -> new RuntimeException("Utente non trovato"));
        appointment.setUser(user);

        return appointmentRepository.save(appointment);
    }

    public List<Appointment> getAllAppointments() {
        return appointmentRepository.findAll();
    }

    public Optional<Appointment> getAppointmentById(Long id) {
        return appointmentRepository.findById(id);
    }

    public List<Appointment> getAppointmentsByBusinessAndDate(Long businessId, LocalDate date) {
        return appointmentRepository.findByService_Business_IdAndDate(businessId, date);
    }

    public List<Appointment> getAppointmentsByUserId(Long userId) {
        return appointmentRepository.findByUserId(userId);
    }

    public Appointment updateAppointment(Long id, Appointment updatedAppointmentData) {
        Appointment existing = appointmentRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Appuntamento non trovato"));

        existing.setDate(updatedAppointmentData.getDate());
        existing.setTime(updatedAppointmentData.getTime());
        existing.setStatus(updatedAppointmentData.getStatus());
        existing.setUser(updatedAppointmentData.getUser());
        existing.setService(updatedAppointmentData.getService());

        return appointmentRepository.save(existing);
    }

    public List<Appointment> getAppointmentsForOwnerBusinesses(Long ownerId) {
        return appointmentRepository.findByService_Business_OwnerId(ownerId);
    }


    public void deleteAppointment(Long id) {
        Appointment appointment = appointmentRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Appointment not found"));

        appointment.setStatus(AppointmentsStatus.CANCELLED);
        appointmentRepository.save(appointment);
    }

}
