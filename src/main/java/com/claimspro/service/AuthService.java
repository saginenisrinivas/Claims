package com.claimspro.service;

import com.claimspro.model.User;
import com.claimspro.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {

    private final UserRepository userRepository;

    public AuthService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public Optional<Map<String, String>> authenticate(String email, String password) {
        return userRepository.findByEmailIgnoreCase(email.trim())
                .filter(u -> u.getPassword().equals(password))
                .map(u -> {
                    Map<String, String> profile = new HashMap<>();
                    profile.put("email", u.getEmail().toLowerCase());
                    profile.put("name",  u.getName());
                    profile.put("role",  u.getRole());
                    return profile;
                });
    }
}
