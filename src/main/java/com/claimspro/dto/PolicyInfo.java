package com.claimspro.dto;

public class PolicyInfo {

    private String policyNumber;
    private String policyName;
    private String policyHolderName;
    private String policyStatus;
    private String premium;
    private String nextDueDate;
    private String roleType;

    public PolicyInfo() {}

    public String getPolicyNumber()               { return policyNumber; }
    public void setPolicyNumber(String v)         { this.policyNumber = v; }

    public String getPolicyName()                 { return policyName; }
    public void setPolicyName(String v)           { this.policyName = v; }

    public String getPolicyHolderName()           { return policyHolderName; }
    public void setPolicyHolderName(String v)     { this.policyHolderName = v; }

    public String getPolicyStatus()               { return policyStatus; }
    public void setPolicyStatus(String v)         { this.policyStatus = v; }

    public String getPremium()                    { return premium; }
    public void setPremium(String v)              { this.premium = v; }

    public String getNextDueDate()                { return nextDueDate; }
    public void setNextDueDate(String v)          { this.nextDueDate = v; }

    public String getRoleType()                   { return roleType; }
    public void setRoleType(String v)             { this.roleType = v; }
}
