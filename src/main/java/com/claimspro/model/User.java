package com.claimspro.model;

import javax.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String role;

    public User() {}

    public User(String email, String password, String name, String role) {
        this.email    = email;
        this.password = password;
        this.name     = name;
        this.role     = role;
    }

    public Long getId()             { return id; }
    public String getEmail()        { return email; }
    public void setEmail(String e)  { this.email = e; }
    public String getPassword()     { return password; }
    public void setPassword(String p){ this.password = p; }
    public String getName()         { return name; }
    public void setName(String n)   { this.name = n; }
    public String getRole()         { return role; }
    public void setRole(String r)   { this.role = r; }
}
