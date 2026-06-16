package com.claimspro.model;

import javax.persistence.*;

@Entity
@Table(name = "lookup_values")
public class LookupValue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String category;

    @Column(nullable = false, length = 50)
    private String code;

    @Column(nullable = false, length = 100)
    private String label;

    @Column(name = "sort_order")
    private int sortOrder;

    private boolean active = true;

    public LookupValue() {}

    public LookupValue(String category, String code, String label, int sortOrder) {
        this.category  = category;
        this.code      = code;
        this.label     = label;
        this.sortOrder = sortOrder;
        this.active    = true;
    }

    public Long getId()             { return id; }
    public String getCategory()     { return category; }
    public void setCategory(String v) { this.category = v; }
    public String getCode()         { return code; }
    public void setCode(String v)   { this.code = v; }
    public String getLabel()        { return label; }
    public void setLabel(String v)  { this.label = v; }
    public int getSortOrder()       { return sortOrder; }
    public void setSortOrder(int v) { this.sortOrder = v; }
    public boolean isActive()       { return active; }
    public void setActive(boolean v){ this.active = v; }
}
