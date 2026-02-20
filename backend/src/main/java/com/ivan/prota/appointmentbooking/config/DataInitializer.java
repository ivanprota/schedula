package com.ivan.prota.appointmentbooking.config;

import java.util.ArrayList;

import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.ivan.prota.appointmentbooking.model.Business;
import com.ivan.prota.appointmentbooking.model.BusinessService;
import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.repositories.BusinessRepository;
import com.ivan.prota.appointmentbooking.repositories.UserRepository;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final BusinessRepository businessRepository;
    private final PasswordEncoder passwordEncoder;

    // Base URL per Android Emulator
    private static final String BASE_URL = "http://10.0.2.2:8080";

    public DataInitializer(UserRepository userRepository,
                           BusinessRepository businessRepository,
                           PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.businessRepository = businessRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() == 0) {

            // --- Utenti ---
            User user1 = new User();
            user1.setEmail("ivanprota99@gmail.com");
            user1.setPassword(passwordEncoder.encode("password")); // 🔐 HASH
            user1.setFirstName("Ivan");
            user1.setLastName("Prota");
            user1.setProfileImage(BASE_URL + "/test_images/user1.jpg");
            user1.setAppointments(new ArrayList<>());

            User user2 = new User();
            user2.setEmail("sadiesink@gmail.com");
            user2.setPassword(passwordEncoder.encode("password")); // 🔐 HASH
            user2.setFirstName("Sadie");
            user2.setLastName("Sink");
            user2.setProfileImage(BASE_URL + "/test_images/user2.jpg");
            user2.setAppointments(new ArrayList<>());

            // --- Attività ---
            Business business1 = new Business();
            business1.setName("Barbiere");
            business1.setAddress("Via Volte 1");
            business1.setPhotoUrl(BASE_URL + "/test_images/barbiere1.jpg");
            business1.setOwner(user1);
            business1.setServices(new ArrayList<>());

            Business business2 = new Business();
            business2.setName("Estetista");
            business2.setAddress("Piazza San Leone 12");
            business2.setPhotoUrl(BASE_URL + "/test_images/estetista1.jpg");
            business2.setOwner(user2);
            business2.setServices(new ArrayList<>());

            // --- Servizi ---
            BusinessService haircut = new BusinessService();
            haircut.setName("Taglio capelli");
            haircut.setPrice(15.0);
            haircut.setDurationMinutes(30);
            haircut.setBusiness(business1);

            BusinessService shave = new BusinessService();
            shave.setName("Rasatura barba");
            shave.setPrice(10.0);
            shave.setDurationMinutes(20);
            shave.setBusiness(business1);

            BusinessService manicure = new BusinessService();
            manicure.setName("Manicure");
            manicure.setPrice(20.0);
            manicure.setDurationMinutes(45);
            manicure.setBusiness(business2);

            // Collego i servizi
            business1.getServices().add(haircut);
            business1.getServices().add(shave);
            business2.getServices().add(manicure);

            // --- Salvataggio ---
            userRepository.save(user1);
            userRepository.save(user2);
            businessRepository.save(business1);
            businessRepository.save(business2);
        }
    }
}
