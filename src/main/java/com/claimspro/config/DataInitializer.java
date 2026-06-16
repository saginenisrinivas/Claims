package com.claimspro.config;

import com.claimspro.model.Claim;
import com.claimspro.model.ClaimStatus;
import com.claimspro.model.LookupValue;
import com.claimspro.model.User;
import com.claimspro.repository.ClaimRepository;
import com.claimspro.repository.LookupRepository;
import com.claimspro.repository.UserRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Component
public class DataInitializer implements ApplicationRunner {

    private final UserRepository   userRepository;
    private final ClaimRepository  claimRepository;
    private final LookupRepository lookupRepository;
    private final JdbcTemplate     jdbcTemplate;

    public DataInitializer(UserRepository userRepository,
                           ClaimRepository claimRepository,
                           LookupRepository lookupRepository,
                           JdbcTemplate jdbcTemplate) {
        this.userRepository   = userRepository;
        this.claimRepository  = claimRepository;
        this.lookupRepository = lookupRepository;
        this.jdbcTemplate     = jdbcTemplate;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        createSequenceIfAbsent();
        seedUsers();
        seedClaims();
        seedLookupValues();
    }

    private void createSequenceIfAbsent() {
        jdbcTemplate.execute("CREATE SEQUENCE IF NOT EXISTS claim_seq START 1 INCREMENT 1");
    }

    // ── Users ─────────────────────────────────────────────────────────

    private void seedUsers() {
        if (userRepository.count() > 0) return;

        userRepository.saveAll(List.of(
            new User("admin@claims.com",   "admin123",   "Admin User",     "Administrator"),
            new User("officer@claims.com", "officer123", "Claims Officer", "Claims Officer"),
            new User("manager@claims.com", "manager123", "Case Manager",   "Case Manager")
        ));
    }

    // ── Claims ────────────────────────────────────────────────────────

    private void seedClaims() {
        if (claimRepository.count() > 0) return;

        LocalDateTime now = LocalDateTime.now();

        claimRepository.saveAll(List.of(
            build("CLM-2026-0001", "Alice Johnson",   "alice@example.com",  "555-0101",
                  "Medical",   ClaimStatus.SUBMITTED, now.minusDays(18)),

            build("CLM-2026-0002", "Bob Williams",    "bob@example.com",    "555-0102",
                  "Auto",      ClaimStatus.SUBMITTED, now.minusDays(16)),

            withAccepted(
                build("CLM-2026-0003", "Carol Martinez", "carol@example.com",  "555-0103",
                      "Property", ClaimStatus.ACCEPTED, now.minusDays(20)),
                now.minusDays(17), "Documents verified. Proceeding to evaluation."),

            withUnderEval(
                withAccepted(
                    build("CLM-2026-0004", "David Lee",     "david@example.com",  "555-0104",
                          "Auto",     ClaimStatus.UNDER_EVALUATION, now.minusDays(25)),
                    now.minusDays(22), "Valid documentation confirmed."),
                now.minusDays(20), "Senior Evaluator"),

            withEvaluated(
                withAccepted(
                    build("CLM-2026-0005", "Emma Davis",    "emma@example.com",   "555-0105",
                          "Medical", ClaimStatus.EVALUATED, now.minusDays(40)),
                    now.minusDays(38), ""),
                now.minusDays(30), new BigDecimal("24500.00"), "medium",
                "Medical expenses verified. Non-covered items deducted.", "approve", "Dr. Evaluator"),

            withApproved(
                withEvaluated(
                    withAccepted(
                        build("CLM-2026-0006", "Frank Wilson",  "frank@example.com",  "555-0106",
                              "Property", ClaimStatus.APPROVED, now.minusDays(55)),
                        now.minusDays(53), ""),
                    now.minusDays(45), new BigDecimal("80000.00"), "high",
                    "On-site assessment completed. Equipment list cross-checked.", "approve", "Senior Evaluator"),
                now.minusDays(35), new BigDecimal("80000.00"),
                "Approved after legal review. Payment authorised.", "Case Manager"),

            withRejected(
                build("CLM-2026-0007", "Grace Kim",     "grace@example.com",  "555-0107",
                      "Medical",   ClaimStatus.REJECTED, now.minusDays(65)),
                now.minusDays(62),
                "Pre-existing condition — not covered under current policy.", "Claims Officer")
        ));

        // Set sequence past the seeded records so new claims start at 8
        jdbcTemplate.execute("SELECT setval('claim_seq', 7)");
    }

    // ── Lookup Values ─────────────────────────────────────────────────

    private void seedLookupValues() {
        // API-mapped categories: always delete + re-seed so codes stay in sync with BCP
        refreshCategory("GENDER",
            lv("GENDER", "M", "Male",   1),
            lv("GENDER", "F", "Female", 2)
        );

        refreshCategory("ID_TYPE",
            lv("ID_TYPE", "34", "Omang",    1),
            lv("ID_TYPE", "9",  "Others",   2),
            lv("ID_TYPE", "P",  "Passport", 3)
        );

        refreshCategory("CLAIM_TYPE",
            lv("CLAIM_TYPE", "15", "Funeral", 1),
            lv("CLAIM_TYPE", "2",  "Death",   2)
        );

        refreshCategory("CLAIM_NATURE",
            lv("CLAIM_NATURE", "1", "Illness (Non-accident)", 1),
            lv("CLAIM_NATURE", "2", "Accident",               2),
            lv("CLAIM_NATURE", "3", "Suicide",                3)
        );

        refreshCategory("RELATION",
            lv("RELATION", "0",    "N/A",              1),
            lv("RELATION", "1",    "Spouse",            2),
            lv("RELATION", "2",    "Child",             3),
            lv("RELATION", "3",    "Parent",            4),
            lv("RELATION", "4",    "Relative",          5),
            lv("RELATION", "1001", "Self",              6),
            lv("RELATION", "6",    "Other",             7),
            lv("RELATION", "7",    "Employer",          8),
            lv("RELATION", "8",    "Employee",          9),
            lv("RELATION", "9",    "Heir",              10),
            lv("RELATION", "10",   "Trustee",           11),
            lv("RELATION", "11",   "Official Assignee", 12),
            lv("RELATION", "12",   "Public Trustee",    13),
            lv("RELATION", "13",   "Siblings",          14),
            lv("RELATION", "14",   "Niece/Nephew",      15),
            lv("RELATION", "15",   "Assignee",          16),
            lv("RELATION", "18",   "Administrator",     17),
            lv("RELATION", "26",   "Executrix",         18),
            lv("RELATION", "27",   "Executor",          19)
        );

        // Static categories: seed only if not yet present
        seedIfEmpty("CASE_CLASSIFICATION",
            lv("CASE_CLASSIFICATION", "Standard",            "Standard",            1),
            lv("CASE_CLASSIFICATION", "Complex",             "Complex",             2),
            lv("CASE_CLASSIFICATION", "Fast Track",          "Fast Track",          3),
            lv("CASE_CLASSIFICATION", "Fraud Investigation", "Fraud Investigation", 4),
            lv("CASE_CLASSIFICATION", "Legal",               "Legal",               5)
        );

        seedIfEmpty("REPORT_VIA",
            lv("REPORT_VIA", "Post / Mail",   "Post / Mail",   1),
            lv("REPORT_VIA", "Phone",         "Phone",         2),
            lv("REPORT_VIA", "Email",         "Email",         3),
            lv("REPORT_VIA", "Walk In",       "Walk In",       4),
            lv("REPORT_VIA", "Online Portal", "Online Portal", 5)
        );

        seedIfEmpty("CLAIM_OFFICER",
            lv("CLAIM_OFFICER", "Officer A", "Officer A", 1),
            lv("CLAIM_OFFICER", "Officer B", "Officer B", 2),
            lv("CLAIM_OFFICER", "Officer C", "Officer C", 3),
            lv("CLAIM_OFFICER", "Officer D", "Officer D", 4)
        );
    }

    private void refreshCategory(String category, LookupValue... values) {
        jdbcTemplate.update("DELETE FROM lookup_values WHERE category = ?", category);
        lookupRepository.saveAll(List.of(values));
    }

    private void seedIfEmpty(String category, LookupValue... values) {
        if (lookupRepository.findByCategoryAndActiveTrueOrderBySortOrderAsc(category).isEmpty()) {
            lookupRepository.saveAll(List.of(values));
        }
    }

    private static LookupValue lv(String category, String code, String label, int order) {
        return new LookupValue(category, code, label, order);
    }

    // ── Builders ──────────────────────────────────────────────────────

    private Claim build(String id, String name, String email, String phone,
                        String type, ClaimStatus status, LocalDateTime submittedAt) {
        Claim c = new Claim();
        c.setId(id);
        c.setStatus(status);
        c.setSubmittedAt(submittedAt);
        c.setSubmittedBy("System");
        c.setLifeAssuredName(name);
        c.setReporterName(name);
        c.setEmail(email);
        c.setPhone(phone);
        c.setClaimType(type);
        c.setClaimNature("Individual Life");
        c.setNotificationDate(submittedAt.toLocalDate());
        c.setRelation("Self");
        c.setReportVia("Post / Mail");
        c.setSmsConsent("Yes");
        c.setAddressLine1("123 Main Street");
        c.setAddressLine3("Gaborone");
        c.setPostalCode("00000");
        c.setPolicyType(List.of("Individual"));
        c.setGeneralComments("Initial claim submission.");
        c.setAgentCode("AGT-001");
        c.setAgentName("Default Agent");
        return c;
    }

    private Claim withAccepted(Claim c, LocalDateTime at, String notes) {
        c.setAcceptedAt(at);
        c.setAcceptedBy("Claims Officer");
        c.setAcceptanceNotes(notes);
        return c;
    }

    private Claim withUnderEval(Claim c, LocalDateTime at, String evaluator) {
        c.setEvaluationStartedAt(at);
        c.setEvaluatorName(evaluator);
        return c;
    }

    private Claim withEvaluated(Claim c, LocalDateTime at, BigDecimal amount,
                                 String risk, String notes, String rec, String evaluator) {
        c.setEvaluatedAt(at);
        c.setEvaluatedAmount(amount);
        c.setRiskLevel(risk);
        c.setEvaluationNotes(notes);
        c.setRecommendation(rec);
        c.setEvaluatorName(evaluator);
        return c;
    }

    private Claim withApproved(Claim c, LocalDateTime at, BigDecimal amount,
                                String notes, String approver) {
        c.setApprovedAt(at);
        c.setApprovedAmount(amount);
        c.setApprovalNotes(notes);
        c.setApprovedBy(approver);
        return c;
    }

    private Claim withRejected(Claim c, LocalDateTime at, String notes, String rejector) {
        c.setRejectedAt(at);
        c.setRejectionNotes(notes);
        c.setRejectedBy(rejector);
        return c;
    }
}
