package com.claimspro.dto;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import java.math.BigDecimal;

public class ApprovalRequest {

    // Required for approval; optional for denial
    @DecimalMin(value = "0.01", message = "Approved amount must be greater than zero")
    private BigDecimal approvedAmount;

    @NotBlank(message = "Decision notes are required")
    private String notes;

    public BigDecimal getApprovedAmount() { return approvedAmount; }
    public void setApprovedAmount(BigDecimal approvedAmount) { this.approvedAmount = approvedAmount; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
