package com.ivan.prota.appointmentbooking.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com.ivan.prota.appointmentbooking.model.BusinessService;

public interface BusinessServiceRepository extends JpaRepository<BusinessService, Long> {

    List<BusinessService> findByBusinessId(Long businessId);

}
