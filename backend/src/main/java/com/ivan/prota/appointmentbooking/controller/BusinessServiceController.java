package com.ivan.prota.appointmentbooking.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ivan.prota.appointmentbooking.model.BusinessService;
import com.ivan.prota.appointmentbooking.services.BusinessServiceService;


@RestController
@RequestMapping("/api/business-services")
public class BusinessServiceController {
    
    @Autowired
    private BusinessServiceService businessServiceService;

    @GetMapping
    public List<BusinessService> getAllBusinessServices() {
        return businessServiceService.getAllBusinessServices();
    }

    @GetMapping("/{id}")
    public Optional<BusinessService> getBusinessServiceById(@PathVariable Long id) {
        return businessServiceService.getBusinessServiceById(id);
    }

    @GetMapping("/business/{businessId}")
    public List<BusinessService> getServicesByBusiness(@PathVariable Long businessId) {
        return businessServiceService.getServicesByBusiness(businessId);
    }
    

    @PostMapping
    public BusinessService createBusinessService(@RequestBody BusinessService businessService) {
        return businessServiceService.createBusinessService(businessService);
    }

    @PutMapping("/{id}")
    public BusinessService updateBusinessService(@PathVariable Long id, @RequestBody BusinessService uptadedBusinessService) {
        return businessServiceService.updateBusinessService(id, uptadedBusinessService);
    }

    @DeleteMapping("/{id}")
    public void deleteBusinessService(@PathVariable Long id) {
        businessServiceService.deleteBusinessServiceById(id);
    }
}
