package com.ivan.prota.appointmentbooking.model;

import jakarta.persistence.*;

@Entity
public class BusinessService {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;
    
    private double price;
    private int durationMinutes;
    private String iconUrl;

    @ManyToOne
    @JoinColumn(name = "business_id")
    private Business business;

    // getter

    public Long getId() { return this.id; }
    public String getName() { return this.name; }
    public double getPrice() { return this.price; }
    public int getDurationMinutes() { return this.durationMinutes; }
    public String getIconUrl() { return this.iconUrl; }
    public Business getBusiness() { return this.business; }

    // setter

    public void setName(String newName) { this.name = newName; }
    public void setPrice(double newPrice) { this.price = newPrice; }
    public void setDurationMinutes(int newDurationMinutes) { this.durationMinutes = newDurationMinutes; }
    public void setIconUrl(String newIconUrl) { this.iconUrl = newIconUrl; }
    public void setBusiness(Business newBusiness) { this.business = newBusiness; }
}
