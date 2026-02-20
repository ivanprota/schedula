package com.ivan.prota.appointmentbooking.services;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.repositories.UserRepository;
import com.ivan.prota.appointmentbooking.util.JwtUtil;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Autentica l'utente:
     *  - cerca l'utente per email (username)
     *  - confronta la password raw con l'hash nel DB usando BCrypt
     *  - se ok, genera un JWT
     *  - se non ok, ritorna null
     */
    public String authenticate(String username, String password) {
        Optional<User> optionalUser = userRepository.findByEmail(username);

        if (optionalUser.isEmpty()) {
            return null;
        }

        User user = optionalUser.get();

        // 🔐 Controllo password hashata con BCrypt
        boolean matches = passwordEncoder.matches(password, user.getPassword());
        if (!matches) {
            return null;
        }

        // Login OK → genera JWT con la tua utility
        return JwtUtil.generateToken(user.getEmail());
    }
}
