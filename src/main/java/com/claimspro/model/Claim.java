package com.claimspro.model;

import com.claimspro.converter.StringListConverter;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "claims")
public class Claim {

    // ── Identity ──────────────────────────────────────────────────────
    @Id
    @Column(name = "id", nullable = false, updatable = false)
    private String id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ClaimStatus status;

    private LocalDateTime submittedAt;
    private String submittedBy;

    // Case number and status returned by the external BCP registerClaim SOAP API
    private String externalCaseNo;
    private String bcpCaseStatus;

    // ── Insured Information ───────────────────────────────────────────
    private String lifeAssuredName;
    private String gender;
    private String idType;
    private String idNo;
    private String policyNumber;

    // ── Claim Information ─────────────────────────────────────────────
    private String claimType;
    private LocalDate notificationDate;
    private String claimNature;
    private String caseClassification;
    private LocalDate eventDate;
    private String causeOfDeath;

    // ── Reporter Information ──────────────────────────────────────────
    private String reporterId;
    private String reporterName;
    private String relation;
    private String reportVia;
    private String phone;
    private String smsConsent;
    private String contactNumber;
    private String email;
    private String addressLine1;
    private String addressLine2;
    private String addressLine3;
    private String addressLine4;
    private String postalCode;
    private String agentCode;
    private String agentName;
    private String agentMobile;
    private String agentSms;

    // ── Policy Type ───────────────────────────────────────────────────
    @Convert(converter = StringListConverter.class)
    @Column(name = "policy_type")
    private List<String> policyType = new ArrayList<>();

    // ── Claim Comments ────────────────────────────────────────────────
    private String claimOfficer;
    private String pendingStatus;
    private LocalDate reviewDate;

    @Column(columnDefinition = "TEXT")
    private String commentsHistory;

    @Column(columnDefinition = "TEXT")
    private String generalComments;

    // ── Acceptance ────────────────────────────────────────────────────
    private LocalDateTime acceptedAt;

    @Column(columnDefinition = "TEXT")
    private String acceptanceNotes;

    private String acceptedBy;
    private LocalDateTime rejectedAt;

    @Column(columnDefinition = "TEXT")
    private String rejectionNotes;

    private String rejectedBy;

    // ── Evaluation ────────────────────────────────────────────────────
    private LocalDateTime evaluationStartedAt;
    private String evaluatorName;
    private LocalDateTime evaluatedAt;

    @Column(precision = 15, scale = 2)
    private BigDecimal evaluatedAmount;

    private String riskLevel;

    @Column(columnDefinition = "TEXT")
    private String evaluationNotes;

    private String recommendation;

    // ── Approval ──────────────────────────────────────────────────────
    private LocalDateTime approvedAt;

    @Column(precision = 15, scale = 2)
    private BigDecimal approvedAmount;

    @Column(columnDefinition = "TEXT")
    private String approvalNotes;

    private String approvedBy;
    private LocalDateTime deniedAt;

    // ── Getters & Setters ─────────────────────────────────────────────

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public ClaimStatus getStatus() { return status; }
    public void setStatus(ClaimStatus status) { this.status = status; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }

    public String getExternalCaseNo() { return externalCaseNo; }
    public void setExternalCaseNo(String externalCaseNo) { this.externalCaseNo = externalCaseNo; }

    public String getBcpCaseStatus() { return bcpCaseStatus; }
    public void setBcpCaseStatus(String bcpCaseStatus) { this.bcpCaseStatus = bcpCaseStatus; }

    public String getSubmittedBy() { return submittedBy; }
    public void setSubmittedBy(String submittedBy) { this.submittedBy = submittedBy; }

    public String getLifeAssuredName() { return lifeAssuredName; }
    public void setLifeAssuredName(String lifeAssuredName) { this.lifeAssuredName = lifeAssuredName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getIdType() { return idType; }
    public void setIdType(String idType) { this.idType = idType; }

    public String getIdNo() { return idNo; }
    public void setIdNo(String idNo) { this.idNo = idNo; }

    public String getPolicyNumber() { return policyNumber; }
    public void setPolicyNumber(String policyNumber) { this.policyNumber = policyNumber; }

    public String getClaimType() { return claimType; }
    public void setClaimType(String claimType) { this.claimType = claimType; }

    public LocalDate getNotificationDate() { return notificationDate; }
    public void setNotificationDate(LocalDate notificationDate) { this.notificationDate = notificationDate; }

    public String getClaimNature() { return claimNature; }
    public void setClaimNature(String claimNature) { this.claimNature = claimNature; }

    public String getCaseClassification() { return caseClassification; }
    public void setCaseClassification(String caseClassification) { this.caseClassification = caseClassification; }

    public LocalDate getEventDate() { return eventDate; }
    public void setEventDate(LocalDate eventDate) { this.eventDate = eventDate; }

    public String getCauseOfDeath() { return causeOfDeath; }
    public void setCauseOfDeath(String causeOfDeath) { this.causeOfDeath = causeOfDeath; }

    public String getReporterId() { return reporterId; }
    public void setReporterId(String reporterId) { this.reporterId = reporterId; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getRelation() { return relation; }
    public void setRelation(String relation) { this.relation = relation; }

    public String getReportVia() { return reportVia; }
    public void setReportVia(String reportVia) { this.reportVia = reportVia; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getSmsConsent() { return smsConsent; }
    public void setSmsConsent(String smsConsent) { this.smsConsent = smsConsent; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAddressLine1() { return addressLine1; }
    public void setAddressLine1(String addressLine1) { this.addressLine1 = addressLine1; }

    public String getAddressLine2() { return addressLine2; }
    public void setAddressLine2(String addressLine2) { this.addressLine2 = addressLine2; }

    public String getAddressLine3() { return addressLine3; }
    public void setAddressLine3(String addressLine3) { this.addressLine3 = addressLine3; }

    public String getAddressLine4() { return addressLine4; }
    public void setAddressLine4(String addressLine4) { this.addressLine4 = addressLine4; }

    public String getPostalCode() { return postalCode; }
    public void setPostalCode(String postalCode) { this.postalCode = postalCode; }

    public String getAgentCode() { return agentCode; }
    public void setAgentCode(String agentCode) { this.agentCode = agentCode; }

    public String getAgentName() { return agentName; }
    public void setAgentName(String agentName) { this.agentName = agentName; }

    public String getAgentMobile() { return agentMobile; }
    public void setAgentMobile(String agentMobile) { this.agentMobile = agentMobile; }

    public String getAgentSms() { return agentSms; }
    public void setAgentSms(String agentSms) { this.agentSms = agentSms; }

    public List<String> getPolicyType() { return policyType; }
    public void setPolicyType(List<String> policyType) { this.policyType = policyType; }

    public String getClaimOfficer() { return claimOfficer; }
    public void setClaimOfficer(String claimOfficer) { this.claimOfficer = claimOfficer; }

    public String getPendingStatus() { return pendingStatus; }
    public void setPendingStatus(String pendingStatus) { this.pendingStatus = pendingStatus; }

    public LocalDate getReviewDate() { return reviewDate; }
    public void setReviewDate(LocalDate reviewDate) { this.reviewDate = reviewDate; }

    public String getCommentsHistory() { return commentsHistory; }
    public void setCommentsHistory(String commentsHistory) { this.commentsHistory = commentsHistory; }

    public String getGeneralComments() { return generalComments; }
    public void setGeneralComments(String generalComments) { this.generalComments = generalComments; }

    public LocalDateTime getAcceptedAt() { return acceptedAt; }
    public void setAcceptedAt(LocalDateTime acceptedAt) { this.acceptedAt = acceptedAt; }

    public String getAcceptanceNotes() { return acceptanceNotes; }
    public void setAcceptanceNotes(String acceptanceNotes) { this.acceptanceNotes = acceptanceNotes; }

    public String getAcceptedBy() { return acceptedBy; }
    public void setAcceptedBy(String acceptedBy) { this.acceptedBy = acceptedBy; }

    public LocalDateTime getRejectedAt() { return rejectedAt; }
    public void setRejectedAt(LocalDateTime rejectedAt) { this.rejectedAt = rejectedAt; }

    public String getRejectionNotes() { return rejectionNotes; }
    public void setRejectionNotes(String rejectionNotes) { this.rejectionNotes = rejectionNotes; }

    public String getRejectedBy() { return rejectedBy; }
    public void setRejectedBy(String rejectedBy) { this.rejectedBy = rejectedBy; }

    public LocalDateTime getEvaluationStartedAt() { return evaluationStartedAt; }
    public void setEvaluationStartedAt(LocalDateTime evaluationStartedAt) { this.evaluationStartedAt = evaluationStartedAt; }

    public String getEvaluatorName() { return evaluatorName; }
    public void setEvaluatorName(String evaluatorName) { this.evaluatorName = evaluatorName; }

    public LocalDateTime getEvaluatedAt() { return evaluatedAt; }
    public void setEvaluatedAt(LocalDateTime evaluatedAt) { this.evaluatedAt = evaluatedAt; }

    public BigDecimal getEvaluatedAmount() { return evaluatedAmount; }
    public void setEvaluatedAmount(BigDecimal evaluatedAmount) { this.evaluatedAmount = evaluatedAmount; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getEvaluationNotes() { return evaluationNotes; }
    public void setEvaluationNotes(String evaluationNotes) { this.evaluationNotes = evaluationNotes; }

    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }

    public LocalDateTime getApprovedAt() { return approvedAt; }
    public void setApprovedAt(LocalDateTime approvedAt) { this.approvedAt = approvedAt; }

    public BigDecimal getApprovedAmount() { return approvedAmount; }
    public void setApprovedAmount(BigDecimal approvedAmount) { this.approvedAmount = approvedAmount; }

    public String getApprovalNotes() { return approvalNotes; }
    public void setApprovalNotes(String approvalNotes) { this.approvalNotes = approvalNotes; }

    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }

    public LocalDateTime getDeniedAt() { return deniedAt; }
    public void setDeniedAt(LocalDateTime deniedAt) { this.deniedAt = deniedAt; }
}
