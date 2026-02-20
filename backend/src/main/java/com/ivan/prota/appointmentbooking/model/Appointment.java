package com.ivan.prota.appointmentbooking.model;

import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.persistence.*;

@Entity
public class Appointment {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private LocalTime time;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AppointmentsStatus status;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "service_id")
    private BusinessService service;

    // getter

    public Long getId() { return this.id; }
    public LocalDate getDate() { return this.date; }
    public LocalTime getTime() { return this.time; }
    public AppointmentsStatus getStatus() { return this.status; }
    public User getUser() { return this.user; }
    public BusinessService getService() { return this.service; }

    // setter
    public void setDate(LocalDate newDate) { this.date = newDate; }
    public void setTime(LocalTime newTime) { this.time = newTime; }
    public void setStatus(AppointmentsStatus newStatus) { this.status = newStatus; }
    public void setUser(User newUser) { this.user = newUser; }
    public void setService(BusinessService newService) { this.service = newService; }
}
