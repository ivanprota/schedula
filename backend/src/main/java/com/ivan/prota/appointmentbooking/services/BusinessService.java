package com.ivan.prota.appointmentbooking.services;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import com.ivan.prota.appointmentbooking.model.Business;
import com.ivan.prota.appointmentbooking.repositories.BusinessRepository;

@Service
public class BusinessService {
    
    private BusinessRepository businessRepository;

    public BusinessService(BusinessRepository businessRepository) {
        this.businessRepository = businessRepository;
    }

    public Business createBusiness(Business business) {
        return businessRepository.save(business);
    }

    public List<Business> getAllBusinesses() {
        return businessRepository.findAll();
    }

    public Optional<Business> getBusinessById(Long id) {
        return businessRepository.findById(id);
    }

    public List<Business> getBusinessesByOwnerId(Long id) {
        return businessRepository.findByOwnerId(id);
    }

    public List<Business> search(String query) {
        String q = query.toLowerCase();
        return businessRepository
            .findByNameContainingIgnoreCaseOrAddressContainingIgnoreCase(
                q, q
            );
    }

    public Business updateBusiness(Long id, Business updated) {
        Business existing = businessRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Business non trovato"));

        existing.setName(updated.getName());
        existing.setAddress(updated.getAddress());

        // aggiorno solo se presente
        if (updated.getPhotoUrl() != null) {
            existing.setPhotoUrl(updated.getPhotoUrl());
        }

        // NON sovrascrivere l'owner se non viene passato
        // if (updated.getOwner() != null) {
        //     existing.setOwner(updated.getOwner());
        // }

        return businessRepository.save(existing);
    }

    public void deleteBusinessById(Long id) {
        businessRepository.deleteById(id);
    }
}
