package com.claimspro.controller;

import com.claimspro.dto.ApiResponse;
import com.claimspro.model.LookupValue;
import com.claimspro.repository.LookupRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

@RestController
@RequestMapping("/api/lookup")
public class LookupController {

    private final LookupRepository lookupRepository;

    public LookupController(LookupRepository lookupRepository) {
        this.lookupRepository = lookupRepository;
    }

    @GetMapping("/{category}")
    public ResponseEntity<ApiResponse<List<LookupValue>>> getByCategory(
            @PathVariable String category,
            HttpSession session) {

        if (session.getAttribute("currentUser") == null) {
            return ResponseEntity.status(401).body(ApiResponse.error("Not authenticated."));
        }
        List<LookupValue> values =
                lookupRepository.findByCategoryAndActiveTrueOrderBySortOrderAsc(category);
        return ResponseEntity.ok(ApiResponse.ok("OK", values));
    }
}
