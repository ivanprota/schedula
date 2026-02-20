package com.ivan.prota.appointmentbooking.dto;

public class AppointmentCreationRequest {
    private Long serviceId;
    private String date; // "2025-11-15"
    private String time; // "10:30:00"
    private Long userId;

    public Long getServiceId() { return serviceId; }
    public void setServiceId(Long serviceId) { this.serviceId = serviceId; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
}
