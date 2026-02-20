package com.ivan.prota.appointmentbooking.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;


@Entity
public class Business {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    @Column(length = 1000)
    private String photoUrl;

    @ManyToOne
    @JoinColumn(name = "owner_id")
    @JsonBackReference
    private User owner;

    @OneToMany(mappedBy = "business", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<BusinessService> services;

    // getter

    public Long getId() { return this.id; }
    public String getName() { return this.name; }
    public String getAddress() { return this.address; }
    public String getPhotoUrl() { return this.photoUrl; }
    public User getOwner() { return this.owner; }
    public List<BusinessService> getServices() { return this.services; }

    // setter

    public void setName(String newName) { this.name = newName; }
    public void setAddress(String newAddress) { this.address = newAddress; }
    public void setPhotoUrl(String newPhotoUrl) { this.photoUrl = newPhotoUrl; }
    public void setOwner(User newOwner) { this.owner = newOwner; }
    public void setServices(List<BusinessService> newServices) { this.services = newServices; }
}
