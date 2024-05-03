package com.projects.healthcheck.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "roles")
public class Role {
    public Role(String role) {
        this.role = role;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String role;

    // @ManyToMany(mappedBy = "roles")
    // private List<User> users;

    public Role() {

    }

    // Getters and setters

    // public List<User> getUsers() {
    // return users;
    // }
    //
    // public void setUsers(List<User> users) {
    // this.users = users;
    // }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

}