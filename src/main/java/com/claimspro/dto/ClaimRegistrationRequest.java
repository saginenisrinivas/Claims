package com.claimspro.dto;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;

public class ClaimRegistrationRequest {

    // Insured Information
    @NotBlank(message = "Life Assured Name is required")
    private String lifeAssuredName;
    private String gender;
    private String idType;
    private String idNo;
    private String policyNumber;

    // Claim Information
    @NotBlank(message = "Type of Claim is required")
    private String claimType;

    @NotNull(message = "Notification Date is required")
    private LocalDate notificationDate;

    @NotBlank(message = "Claim Nature is required")
    private String claimNature;

    private String caseClassification;

    @NotNull(message = "Event Date is required")
    private LocalDate eventDate;

    private String causeOfDeath;

    // Reporter Information
    private String reporterId;

    @NotBlank(message = "Reporter Name is required")
    private String reporterName;

    @NotBlank(message = "Relation with Life Assured is required")
    private String relation;

    @NotBlank(message = "Report Via is required")
    private String reportVia;

    @NotBlank(message = "Mobile Phone is required")
    private String phone;

    private String smsConsent;
    private String contactNumber;

    @NotBlank(message = "Email Address is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Address is required")
    private String addressLine1;

    private String addressLine2;
    private String addressLine3;
    private String addressLine4;
    private String postalCode;
    private String agentCode;
    private String agentName;
    private String agentMobile;
    private String agentSms;

    // Policy Type
    private List<String> policyType;

    // Claim Comments
    private String claimOfficer;
    private String pendingStatus;
    private LocalDate reviewDate;

    @NotBlank(message = "General Comments are required")
    private String generalComments;

    // ── Getters & Setters ──────────────────────────────────────────────

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

    public String getGeneralComments() { return generalComments; }
    public void setGeneralComments(String generalComments) { this.generalComments = generalComments; }
}
