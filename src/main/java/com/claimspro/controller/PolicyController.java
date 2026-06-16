package com.claimspro.controller;

import com.claimspro.dto.ApiResponse;
import com.claimspro.dto.PolicyInfo;
import com.claimspro.service.PolicyService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpSession;
import java.util.List;

@RestController
@RequestMapping("/api/policies")
public class PolicyController {

    private final PolicyService policyService;

    public PolicyController(PolicyService policyService) {
        this.policyService = policyService;
    }

    @GetMapping("/lookup")
    public ResponseEntity<ApiResponse<List<PolicyInfo>>> lookup(
            @RequestParam String idNumber,
            HttpSession session) {

        if (session.getAttribute("currentUser") == null) {
            return ResponseEntity.status(401).body(ApiResponse.error("Not authenticated."));
        }
        if (idNumber == null || idNumber.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("ID Number is required."));
        }

        try {
            List<PolicyInfo> policies = policyService.getPoliciesByIdNumber(idNumber.trim());
            String msg = policies.isEmpty()
                    ? "No policies found for this ID number."
                    : "Found " + policies.size() + " policy record(s).";
            return ResponseEntity.ok(ApiResponse.ok(msg, policies));
        } catch (Exception e) {
            return ResponseEntity.ok(
                    ApiResponse.ok("Policy service unavailable. Please try again later.", List.of()));
        }
    }
}
