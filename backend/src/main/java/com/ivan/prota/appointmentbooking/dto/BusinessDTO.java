package com.ivan.prota.appointmentbooking.dto;

public class BusinessDTO {
    private String name;
    private String address;
    private String photoUrl;
    private Long ownerId;

    // getter
    public String getName() { return this.name; }
    public String getAddress() { return this.address; }
    public String getPhotoUrl() { return this.photoUrl; }
    public Long getOwnerId() { return this.ownerId; }
}
