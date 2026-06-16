package com.claimspro.controller;

import com.claimspro.dto.*;
import com.claimspro.model.Claim;
import com.claimspro.service.ClaimService;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/claims")
public class ClaimController {

    private final ClaimService claimService;

    public ClaimController(ClaimService claimService) {
        this.claimService = claimService;
    }

    // ── List & Stats ──────────────────────────────────────────────────

    @GetMapping
    public ResponseEntity<ApiResponse<List<Claim>>> list(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String claimType) {

        List<Claim> claims = claimService.getAllClaims(search, status, claimType);
        return ResponseEntity.ok(ApiResponse.ok(claims));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> stats() {
        return ResponseEntity.ok(ApiResponse.ok(claimService.getStats()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Claim>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.ok(claimService.getById(id)));
    }

    // ── Registration ──────────────────────────────────────────────────

    @PostMapping
    public ResponseEntity<ApiResponse<Claim>> register(
            @Valid @RequestBody ClaimRegistrationRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Claims Officer");
        if (denied != null) return denied;

        String user = getCurrentUserName(session);
        Claim claim = claimService.registerClaim(req, user);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Case " + claim.getId() + " registered successfully", claim));
    }

    // ── Acceptance ────────────────────────────────────────────────────

    @PutMapping("/{id}/accept")
    public ResponseEntity<ApiResponse<Claim>> accept(
            @PathVariable String id,
            @RequestBody AcceptanceRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Claims Officer");
        if (denied != null) return denied;

        Claim claim = claimService.acceptClaim(id, req, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Case accepted successfully", claim));
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<Claim>> reject(
            @PathVariable String id,
            @RequestBody AcceptanceRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Claims Officer");
        if (denied != null) return denied;

        Claim claim = claimService.rejectClaim(id, req, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Case rejected", claim));
    }

    // ── Evaluation ────────────────────────────────────────────────────

    @PutMapping("/{id}/start-evaluation")
    public ResponseEntity<ApiResponse<Claim>> startEvaluation(
            @PathVariable String id,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Claims Officer");
        if (denied != null) return denied;

        Claim claim = claimService.startEvaluation(id, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Evaluation started", claim));
    }

    @PutMapping("/{id}/evaluate")
    public ResponseEntity<ApiResponse<Claim>> evaluate(
            @PathVariable String id,
            @Valid @RequestBody EvaluationRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Claims Officer");
        if (denied != null) return denied;

        Claim claim = claimService.evaluateClaim(id, req, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Evaluation submitted. Case ready for approval.", claim));
    }

    // ── Approval ──────────────────────────────────────────────────────

    @PutMapping("/{id}/approve")
    public ResponseEntity<ApiResponse<Claim>> approve(
            @PathVariable String id,
            @RequestBody ApprovalRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Case Manager");
        if (denied != null) return denied;

        Claim claim = claimService.approveClaim(id, req, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Case approved. Payment authorised.", claim));
    }

    @PutMapping("/{id}/deny")
    public ResponseEntity<ApiResponse<Claim>> deny(
            @PathVariable String id,
            @RequestBody ApprovalRequest req,
            HttpSession session) {

        ResponseEntity<ApiResponse<Claim>> denied = denyIfNotRole(session, "Case Manager");
        if (denied != null) return denied;

        Claim claim = claimService.denyClaim(id, req, getCurrentUserName(session));
        return ResponseEntity.ok(ApiResponse.ok("Case denied.", claim));
    }

    // ── Helpers ───────────────────────────────────────────────────────

    @SuppressWarnings("unchecked")
    private Map<String, String> getCurrentUser(HttpSession session) {
        return (Map<String, String>) session.getAttribute("currentUser");
    }

    private String getCurrentUserName(HttpSession session) {
        Map<String, String> user = getCurrentUser(session);
        return user != null ? user.getOrDefault("name", "Unknown") : "Unknown";
    }

    private ResponseEntity<ApiResponse<Claim>> denyIfNotRole(HttpSession session, String... allowedRoles) {
        Map<String, String> user = getCurrentUser(session);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Not authenticated."));
        }
        String role = user.getOrDefault("role", "");
        for (String allowed : allowedRoles) {
            if (allowed.equals(role)) return null;
        }
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("Access denied: your role '" + role + "' is not permitted to perform this action."));
    }
}
