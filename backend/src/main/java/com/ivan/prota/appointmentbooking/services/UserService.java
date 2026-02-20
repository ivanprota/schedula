package com.ivan.prota.appointmentbooking.services;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import com.ivan.prota.appointmentbooking.model.User;
import com.ivan.prota.appointmentbooking.repositories.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;


@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User createUser(User user) {
        String hashed = passwordEncoder.encode(user.getPassword());
        user.setPassword(hashed);
        return userRepository.save(user);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public User updateUser(Long id, User updatedUserData) {
        Optional<User> OptionalExistingUser = userRepository.findById(id);
        User existingUser = null;
        if (OptionalExistingUser.isPresent())
            existingUser = OptionalExistingUser.get();

        existingUser.setEmail(updatedUserData.getEmail());
        existingUser.setPassword(passwordEncoder.encode(updatedUserData.getPassword()));
        existingUser.setFirstName(updatedUserData.getFirstName());
        existingUser.setLastName(updatedUserData.getLastName());
        existingUser.setProfileImage(updatedUserData.getProfileImage());
        existingUser.setBusinesses(updatedUserData.getBusinesses());
        existingUser.setAppointments(updatedUserData.getAppointments());

        return userRepository.save(existingUser);
    }

    public void deleteUserById(Long id) {
        userRepository.deleteById(id);
    }
}
