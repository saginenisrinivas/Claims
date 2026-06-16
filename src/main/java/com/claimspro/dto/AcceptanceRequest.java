package com.claimspro.dto;

import javax.validation.constraints.NotBlank;

public class AcceptanceRequest {

    private String notes;

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
