package com.ivan.prota.appointmentbooking.controller;

import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.ivan.prota.appointmentbooking.dto.BusinessDTO;
import com.ivan.prota.appointmentbooking.model.Business;
import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.services.BusinessService;
import com.ivan.prota.appointmentbooking.services.UserService;

@RestController
@RequestMapping("/api/businesses")
public class BusinessController {
    
    @Autowired
    private BusinessService businessService;

    @Autowired
    private UserService userService;

    @GetMapping
    public List<Business> getAllBusinesses() {
        return businessService.getAllBusinesses();
    }

    @GetMapping("/{id}")
    public Optional<Business> getBusinessById(@PathVariable Long id) {
        return businessService.getBusinessById(id);
    }

    @GetMapping("/owner/{ownerId}")
    public List<Business> getBusinessesByOwnerId(@PathVariable Long ownerId) {
        return businessService.getBusinessesByOwnerId(ownerId);
    }

    @GetMapping("/search")
    public List<Business> search(@RequestParam String query) {
        return businessService.search(query);
    }
    
    @PostMapping
    public ResponseEntity<Business> createBusiness(@RequestBody BusinessDTO businessDto) {
        Optional<User> optionalOwner = userService.getUserById(businessDto.getOwnerId());
        User user = null;
        if (optionalOwner.isPresent())
            user = optionalOwner.get();
        else return null;

        Business business = new Business();
        business.setName(businessDto.getName());
        business.setAddress(businessDto.getAddress());
        business.setPhotoUrl(businessDto.getPhotoUrl());
        business.setOwner(user);
        Business savedBusiness = businessService.createBusiness(business);
        return ResponseEntity.ok(savedBusiness);
    }

    @PostMapping("/{id}/upload-image")
    public ResponseEntity<String> uploadBusinessImage(
            @PathVariable Long id,
            @RequestParam("image") MultipartFile file) {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File vuoto");
        }

        try {
            // Cartella in cui salvare
            String uploadDir = "src/main/resources/static/test_images/";

            // Nome file unico
            String fileName = "business_" + id + "_" + System.currentTimeMillis() + "_" + file.getOriginalFilename();

            Path uploadPath = Path.of(uploadDir);

            // crea la cartella se non esiste
            if (!uploadPath.toFile().exists()) {
                uploadPath.toFile().mkdirs();
            }

            // salva il file fisico
            Path filePath = uploadPath.resolve(fileName);
            file.transferTo(filePath.toFile());

            // Path esposto dal backend (che Flutter userà)
            String publicPath = "/test_images/" + fileName;

            return ResponseEntity.ok(publicPath);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Errore durante l'upload");
        }
    }


    @PutMapping("/{id}")
    public Business updateBusiness(@PathVariable Long id, @RequestBody Business uptadedBusinessData) {
        return businessService.updateBusiness(id, uptadedBusinessData);
    }

    @DeleteMapping("/{id}")
    public void deleteBusinessById(@PathVariable Long id) {
        businessService.deleteBusinessById(id);
    }
}
