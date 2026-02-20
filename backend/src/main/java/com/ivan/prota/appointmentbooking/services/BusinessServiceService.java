package com.ivan.prota.appointmentbooking.services;

import com.ivan.prota.appointmentbooking.model.BusinessService;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import com.ivan.prota.appointmentbooking.repositories.BusinessServiceRepository;

@Service
public class BusinessServiceService {
    
    private BusinessServiceRepository businessServiceRepository;

    public BusinessServiceService(BusinessServiceRepository serviceRepository) {
        this.businessServiceRepository = serviceRepository;
    }

    public BusinessService createBusinessService(BusinessService service) {
        return businessServiceRepository.save(service);
    }

    public List<BusinessService> getAllBusinessServices() {
        return businessServiceRepository.findAll();
    }

    public Optional<BusinessService> getBusinessServiceById(Long id) {
        return businessServiceRepository.findById(id);
    }

    public List<BusinessService> getServicesByBusiness(Long businessId) {
        return businessServiceRepository.findByBusinessId(businessId);
    }

    public BusinessService updateBusinessService(Long id, BusinessService updatedBusinessService) {
        Optional<BusinessService> optionalExistingBusinessService = businessServiceRepository.findById(id);
        BusinessService existingBusinessService = null;

        if (optionalExistingBusinessService.isPresent())
            existingBusinessService = optionalExistingBusinessService.get();

        existingBusinessService.setName(updatedBusinessService.getName());
        existingBusinessService.setPrice(updatedBusinessService.getPrice());
        existingBusinessService.setDurationMinutes(updatedBusinessService.getDurationMinutes());
        existingBusinessService.setIconUrl(updatedBusinessService.getIconUrl());
        existingBusinessService.setBusiness(updatedBusinessService.getBusiness());

        return businessServiceRepository.save(existingBusinessService);
    }

    public void deleteBusinessServiceById(Long id) {
        businessServiceRepository.deleteById(id);
    }
}
