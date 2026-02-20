package com.ivan.prota.appointmentbooking.model;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.*;;

@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(length = 1000)
    private String profileImage;

    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
    @JsonManagedReference
    private List<Business> businesses;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Appointment> appointments;

    // getter

    public Long getId() { return this.id; }
    public String getEmail() { return this.email; }
    public String getPassword() { return this.password; }
    public String getFirstName() { return this.firstName; }
    public String getLastName() { return this.lastName; }
    public String getProfileImage() {return this.profileImage; }
    public List<Business> getBusinesses() { return this.businesses; }
    public List<Appointment> getAppointments() { return this.appointments; }

    // setter
    public void setEmail(String newEmail) { this.email = newEmail; }
    public void setPassword(String newPassword) { this.password = newPassword; }
    public void setFirstName(String newFirstName) {this.firstName = newFirstName; }
    public void setLastName(String newLastName) { this.lastName = newLastName; }
    public void setProfileImage(String newProfileImage) { this.profileImage = newProfileImage; }
    public void setBusinesses(List<Business> newBusinesses) { this.businesses = newBusinesses; }
    public void setAppointments(List<Appointment> newAppointments) { this.appointments = newAppointments; }
}
