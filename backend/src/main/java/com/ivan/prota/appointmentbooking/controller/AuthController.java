package com.ivan.prota.appointmentbooking.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ivan.prota.appointmentbooking.services.AuthService;
import com.ivan.prota.appointmentbooking.services.UserService;
import com.ivan.prota.appointmentbooking.dto.LoginRequest;
import com.ivan.prota.appointmentbooking.dto.LoginResponse;
import com.ivan.prota.appointmentbooking.dto.RegisterRequest;
import com.ivan.prota.appointmentbooking.model.User;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        String token = authService.authenticate(request.getEmail(), request.getPassword());
        Optional<User> optionalUser = userService.getUserByEmail(request.getEmail());
        User user = null;
        if (optionalUser.isPresent()) {
            user = optionalUser.get();
            LoginResponse response = new LoginResponse(token, user.getId());
            if (token != null) {
                return ResponseEntity.ok(response);
            }
        }   
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenziali non valide");
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {

        // 1. Controllo se email già esiste
        if (userService.getUserByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body("Email già registrata");
        }

        // 2. Creo nuovo utente
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword()); // verrà hashata in UserService
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        // immagine di default
        user.setProfileImage("http://10.0.2.2:8080/test_images/default_user.png");

        User savedUser = userService.createUser(user);

        // 3. Genero token (come nel login)
        String token = com.ivan.prota.appointmentbooking.util.JwtUtil
                .generateToken(savedUser.getEmail());

        // 4. Ritorno stessa risposta del login: token + userId
        LoginResponse response = new LoginResponse(token, savedUser.getId());

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

}

