package com.claimspro.controller;

import com.claimspro.dto.ApiResponse;
import com.claimspro.dto.LoginRequest;
import com.claimspro.service.AuthService;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Map<String, String>>> login(
            @Valid @RequestBody LoginRequest req,
            HttpSession session) {

        return authService.authenticate(req.getEmail(), req.getPassword())
                .map(user -> {
                    session.setAttribute("currentUser", user);
                    return ResponseEntity.ok(ApiResponse.ok("Login successful", user));
                })
                .orElseGet(() -> ResponseEntity
                        .status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Invalid email or password")));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok(ApiResponse.ok(null));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<Map<String, String>>> me(HttpSession session) {
        @SuppressWarnings("unchecked")
        Map<String, String> user = (Map<String, String>) session.getAttribute("currentUser");
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Not authenticated"));
        }
        return ResponseEntity.ok(ApiResponse.ok(user));
    }
}
