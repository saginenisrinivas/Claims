package com.claimspro.service;

import com.claimspro.dto.*;
import com.claimspro.exception.ClaimNotFoundException;
import com.claimspro.exception.InvalidClaimStateException;
import com.claimspro.model.Claim;
import com.claimspro.model.ClaimStatus;
import com.claimspro.repository.ClaimRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * All business logic for the claims lifecycle.
 *
 * State machine:
 *   SUBMITTED --> ACCEPTED  (accept)
 *   SUBMITTED --> REJECTED  (reject)
 *   ACCEPTED  --> UNDER_EVALUATION  (startEvaluation)
 *   UNDER_EVALUATION --> EVALUATED  (evaluate)
 *   EVALUATED --> APPROVED  (approve)
 *   EVALUATED --> DENIED    (deny)
 */
@Service
public class ClaimService {

    private final ClaimRepository repository;
    private final ClaimRegistrationSoapService soapService;

    public ClaimService(ClaimRepository repository, ClaimRegistrationSoapService soapService) {
        this.repository   = repository;
        this.soapService  = soapService;
    }

    // ── Registration ──────────────────────────────────────────────────

    @Transactional
    public Claim registerClaim(ClaimRegistrationRequest req, String submittedBy) {
        validateNotificationDateNotFuture(req.getNotificationDate());
        validateEventDateNotFuture(req.getEventDate());

        long seq = repository.nextSequenceValue();
        String id = String.format("CLM-%d-%04d", LocalDate.now().getYear(), seq);

        Claim claim = new Claim();
        claim.setId(id);
        claim.setStatus(ClaimStatus.SUBMITTED);
        claim.setSubmittedAt(LocalDateTime.now());
        claim.setSubmittedBy(submittedBy);

        // Insured
        claim.setLifeAssuredName(req.getLifeAssuredName().trim());
        claim.setGender(req.getGender());
        claim.setIdType(req.getIdType());
        claim.setIdNo(req.getIdNo());
        claim.setPolicyNumber(req.getPolicyNumber());

        // Claim information
        claim.setClaimType(req.getClaimType());
        claim.setNotificationDate(req.getNotificationDate());
        claim.setClaimNature(req.getClaimNature());
        claim.setCaseClassification(req.getCaseClassification());
        claim.setEventDate(req.getEventDate());
        claim.setCauseOfDeath(req.getCauseOfDeath());

        // Reporter
        claim.setReporterId(req.getReporterId());
        claim.setReporterName(req.getReporterName().trim());
        claim.setRelation(req.getRelation());
        claim.setReportVia(req.getReportVia());
        claim.setPhone(req.getPhone().trim());
        claim.setSmsConsent(req.getSmsConsent());
        claim.setContactNumber(req.getContactNumber());
        claim.setEmail(req.getEmail().trim().toLowerCase());
        claim.setAddressLine1(req.getAddressLine1());
        claim.setAddressLine2(req.getAddressLine2());
        claim.setAddressLine3(req.getAddressLine3());
        claim.setAddressLine4(req.getAddressLine4());
        claim.setPostalCode(req.getPostalCode());
        claim.setAgentCode(req.getAgentCode());
        claim.setAgentName(req.getAgentName());
        claim.setAgentMobile(req.getAgentMobile());
        claim.setAgentSms(req.getAgentSms());

        // Policy
        claim.setPolicyType(req.getPolicyType());

        // Comments
        claim.setClaimOfficer(req.getClaimOfficer());
        claim.setPendingStatus(req.getPendingStatus());
        claim.setReviewDate(req.getReviewDate());
        claim.setGeneralComments(req.getGeneralComments().trim());

        // BCP registration is mandatory — reject locally if BCP rejects.
        ClaimRegistrationSoapService.SoapResult soapResult = soapService.registerClaim(claim);
        if (!soapResult.isSuccess()) {
            throw new InvalidClaimStateException(soapResult.getErrorMessage());
        }

        claim.setExternalCaseNo(soapResult.getCaseNumber());
        claim.setBcpCaseStatus(soapResult.getCaseStatus());
        return repository.save(claim);
    }

    // ── Acceptance ────────────────────────────────────────────────────

    @Transactional
    public Claim acceptClaim(String id, AcceptanceRequest req, String officerName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.SUBMITTED,
                "Only SUBMITTED claims can be accepted. Current status: " + claim.getStatus());

        claim.setStatus(ClaimStatus.ACCEPTED);
        claim.setAcceptedAt(LocalDateTime.now());
        claim.setAcceptedBy(officerName);
        claim.setAcceptanceNotes(req.getNotes());

        return repository.save(claim);
    }

    @Transactional
    public Claim rejectClaim(String id, AcceptanceRequest req, String officerName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.SUBMITTED,
                "Only SUBMITTED claims can be rejected. Current status: " + claim.getStatus());

        if (req.getNotes() == null || req.getNotes().isBlank()) {
            throw new InvalidClaimStateException("Rejection reason is required.");
        }

        claim.setStatus(ClaimStatus.REJECTED);
        claim.setRejectedAt(LocalDateTime.now());
        claim.setRejectedBy(officerName);
        claim.setRejectionNotes(req.getNotes().trim());

        return repository.save(claim);
    }

    // ── Evaluation ────────────────────────────────────────────────────

    @Transactional
    public Claim startEvaluation(String id, String evaluatorName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.ACCEPTED,
                "Only ACCEPTED claims can start evaluation. Current status: " + claim.getStatus());

        claim.setStatus(ClaimStatus.UNDER_EVALUATION);
        claim.setEvaluationStartedAt(LocalDateTime.now());
        claim.setEvaluatorName(evaluatorName);

        return repository.save(claim);
    }

    @Transactional
    public Claim evaluateClaim(String id, EvaluationRequest req, String evaluatorName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.UNDER_EVALUATION,
                "Only UNDER_EVALUATION claims can be evaluated. Current status: " + claim.getStatus());

        validateRiskLevel(req.getRiskLevel());
        validateEvaluationNotes(req.getEvaluationNotes());

        claim.setStatus(ClaimStatus.EVALUATED);
        claim.setEvaluatedAt(LocalDateTime.now());
        claim.setEvaluatedAmount(req.getEvaluatedAmount());
        claim.setRiskLevel(req.getRiskLevel().toLowerCase());
        claim.setEvaluationNotes(req.getEvaluationNotes().trim());
        claim.setRecommendation(req.getRecommendation());
        claim.setEvaluatorName(evaluatorName);

        return repository.save(claim);
    }

    // ── Approval ──────────────────────────────────────────────────────

    @Transactional
    public Claim approveClaim(String id, ApprovalRequest req, String approverName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.EVALUATED,
                "Only EVALUATED claims can be approved. Current status: " + claim.getStatus());

        if (req.getApprovedAmount() == null) {
            throw new InvalidClaimStateException("Approved amount is required.");
        }
        if (req.getNotes() == null || req.getNotes().isBlank()) {
            throw new InvalidClaimStateException("Approval notes are required.");
        }

        BigDecimal approved = req.getApprovedAmount();
        validateApprovedAmountNotExceedsEvaluated(approved, claim.getEvaluatedAmount());

        claim.setStatus(ClaimStatus.APPROVED);
        claim.setApprovedAt(LocalDateTime.now());
        claim.setApprovedAmount(approved);
        claim.setApprovalNotes(req.getNotes().trim());
        claim.setApprovedBy(approverName);

        return repository.save(claim);
    }

    @Transactional
    public Claim denyClaim(String id, ApprovalRequest req, String approverName) {
        Claim claim = findOrThrow(id);

        requireStatus(claim, ClaimStatus.EVALUATED,
                "Only EVALUATED claims can be denied. Current status: " + claim.getStatus());

        if (req.getNotes() == null || req.getNotes().isBlank()) {
            throw new InvalidClaimStateException("Denial reason is required.");
        }

        claim.setStatus(ClaimStatus.DENIED);
        claim.setDeniedAt(LocalDateTime.now());
        claim.setApprovalNotes(req.getNotes().trim());
        claim.setApprovedBy(approverName);

        return repository.save(claim);
    }

    // ── Queries ───────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<Claim> getAllClaims(String search, String status, String claimType) {
        ClaimStatus statusEnum = null;
        if (status != null && !status.isBlank()) {
            try { statusEnum = ClaimStatus.valueOf(status.toUpperCase()); }
            catch (IllegalArgumentException ignored) {}
        }
        String q = (search    != null && !search.isBlank())    ? search    : null;
        String t = (claimType != null && !claimType.isBlank()) ? claimType : null;
        return repository.search(q, statusEnum, t);
    }

    @Transactional(readOnly = true)
    public Claim getById(String id) {
        return findOrThrow(id);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total",         repository.count());
        stats.put("submitted",     repository.countByStatus(ClaimStatus.SUBMITTED));
        stats.put("accepted",      repository.countByStatus(ClaimStatus.ACCEPTED));
        stats.put("underEval",     repository.countByStatus(ClaimStatus.UNDER_EVALUATION));
        stats.put("evaluated",     repository.countByStatus(ClaimStatus.EVALUATED));
        stats.put("approved",      repository.countByStatus(ClaimStatus.APPROVED));
        stats.put("rejected",      repository.countByStatus(ClaimStatus.REJECTED)
                                 + repository.countByStatus(ClaimStatus.DENIED));
        stats.put("totalApproved", repository.sumApprovedAmounts());
        return stats;
    }

    // ── Business rule validators ──────────────────────────────────────

    private void validateNotificationDateNotFuture(java.time.LocalDate date) {
        if (date != null && date.isAfter(java.time.LocalDate.now())) {
            throw new InvalidClaimStateException(
                    "Notification date cannot be in the future.");
        }
    }

    private void validateEventDateNotFuture(java.time.LocalDate date) {
        if (date != null && date.isAfter(java.time.LocalDate.now())) {
            throw new InvalidClaimStateException(
                    "Event date cannot be in the future.");
        }
    }

    private void validateRiskLevel(String riskLevel) {
        if (!List.of("low", "medium", "high").contains(riskLevel.toLowerCase())) {
            throw new InvalidClaimStateException(
                    "Risk level must be one of: low, medium, high.");
        }
    }

    private void validateEvaluationNotes(String notes) {
        if (notes == null || notes.trim().length() < 20) {
            throw new InvalidClaimStateException(
                    "Evaluation notes must be at least 20 characters.");
        }
    }

    private void validateApprovedAmountNotExceedsEvaluated(
            BigDecimal approved, BigDecimal evaluated) {
        if (evaluated != null && approved.compareTo(evaluated) > 0) {
            throw new InvalidClaimStateException(
                    "Approved amount (" + approved + ") cannot exceed evaluated amount ("
                    + evaluated + ").");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────

    private Claim findOrThrow(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new ClaimNotFoundException(id));
    }

    private void requireStatus(Claim claim, ClaimStatus required, String message) {
        if (claim.getStatus() != required) {
            throw new InvalidClaimStateException(message);
        }
    }

}
