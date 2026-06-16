package com.claimspro.dto;

import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

public class EvaluationRequest {

    @NotNull(message = "Evaluated amount is required")
    @DecimalMin(value = "0.01", message = "Evaluated amount must be greater than zero")
    private BigDecimal evaluatedAmount;

    @NotBlank(message = "Risk level is required")
    private String riskLevel;

    @NotBlank(message = "Evaluation notes are required")
    private String evaluationNotes;

    private String recommendation;

    public BigDecimal getEvaluatedAmount() { return evaluatedAmount; }
    public void setEvaluatedAmount(BigDecimal evaluatedAmount) { this.evaluatedAmount = evaluatedAmount; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getEvaluationNotes() { return evaluationNotes; }
    public void setEvaluationNotes(String evaluationNotes) { this.evaluationNotes = evaluationNotes; }

    public String getRecommendation() { return recommendation; }
    public void setRecommendation(String recommendation) { this.recommendation = recommendation; }
}
