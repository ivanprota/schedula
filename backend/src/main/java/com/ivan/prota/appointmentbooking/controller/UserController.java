package com.ivan.prota.appointmentbooking.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.services.UserService;

import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;

    @GetMapping
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    @GetMapping("/{id}")
    public Optional<User> getUserById(@PathVariable Long id) {
        return userService.getUserById(id);
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }

    @PostMapping("/{id}/profile-image")
    public ResponseEntity<User> uploadProfileImage(@PathVariable Long id, @RequestParam("file") MultipartFile file) throws IOException {
        User user = userService.getUserById(id).orElseThrow(() -> new RuntimeException("User not found"));
        String fileName = UUID.randomUUID() + "-" + file.getOriginalFilename();

        Path uploadPath = Paths.get("src/main/resources/static/test_images");
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path filePath = uploadPath.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // 5. Creo URL accessibile dal frontend
        String imageUrl = "/test_images/" + fileName;

        // 6. Aggiorno l’utente
        user.setProfileImage(imageUrl);

        // ⚠️ Importante: NON ritornare la password
        user.setPassword(null);

        // 7. Salvo e ritorno l’utente aggiornato
        User saved = userService.updateUser(user.getId(), user);

        return ResponseEntity.ok(saved);       
    }

    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User uptadedUserData) {
        return userService.updateUser(id, uptadedUserData);
    }

    @DeleteMapping("/{id}")
    public void deleteUserById(@PathVariable Long id) {
        userService.deleteUserById(id);
    }
}
