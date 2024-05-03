package com.projects.healthcheck.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User { // generate tables automatically

    // use uuid
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    @Column(name = "id", updatable = false, nullable = false)
    @JsonProperty // don‘ use @JsonIgnore
    private UUID id;

    @JsonProperty("first_name")
    @Column(name = "first_name")
    private String firstName;

    @JsonProperty("last_name")
    @Column(name = "last_name")
    private String lastName;

    @Column(nullable = false, unique = true, name = "username")
    private String username; // Email as username

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY) // password won't include in response payload
    @Column(nullable = false, name = "password")
    private String password;

    @JsonProperty(value = "account_created", access = JsonProperty.Access.READ_ONLY)
    @Column(name = "account_created")
    private LocalDateTime accountCreated;

    @JsonProperty(value = "account_updated", access = JsonProperty.Access.READ_ONLY)
    @Column(name = "account_updated")
    private LocalDateTime accountUpdated;

    // token, tokenCreationTime, tokenExpirationTime
    @JsonProperty(value = "token", access = JsonProperty.Access.WRITE_ONLY) // token won't include in response payload
    @Column
    private String token;

    @JsonProperty(value = "token_creation_time", access = JsonProperty.Access.READ_ONLY)
    @Column(name = "token_creation_time")
    private LocalDateTime tokenCreationTime;

    @JsonProperty(value = "token_expiration_time", access = JsonProperty.Access.READ_ONLY)
    @Column(name = "token_expiration_time")
    private LocalDateTime tokenExpirationTime;

    @JsonProperty(value = "status", access = JsonProperty.Access.READ_ONLY)
    @Column
    private String status;

    public User(String a, String a1, String mail, String a2, LocalDateTime now, LocalDateTime now1) {
    }

    public User(String mail, String test, String user) {
    }

    public User(String mail, String password, String test, String user) {
    }

    @PrePersist
    protected void onCreate() {
        this.accountCreated = LocalDateTime.now();
        this.accountUpdated = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.accountUpdated = LocalDateTime.now();
    }

    // write a constructor with all fields except id
    public User(String firstName, String lastName, String username, String password, LocalDateTime accountCreated,
            LocalDateTime accountUpdated, String token, LocalDateTime tokenCreationTime,
            LocalDateTime tokenExpirationTime, String status) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.username = username;
        this.password = password;
        this.accountCreated = accountCreated;
        this.accountUpdated = accountUpdated;
        this.token = token;
        this.tokenCreationTime = tokenCreationTime;
        this.tokenExpirationTime = tokenExpirationTime;
        this.status = status;
    }

    // this is for the test - updateSelfTest() - a07
    public User(String firstName, String lastName, String username, String password, LocalDateTime accountCreated, LocalDateTime accountUpdated, String status, LocalDateTime tokenExpirationTime) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.username = username;
        this.password = password;
        this.accountCreated = accountCreated == null ? LocalDateTime.now() : accountCreated;
        this.accountUpdated = accountUpdated == null ? LocalDateTime.now() : accountUpdated;
        // 注意：此处默认设置 tokenExpirationTime 和 status，您可能需要根据实际情况调整
        this.tokenExpirationTime = LocalDateTime.now().plusHours(1); // 示例：默认token过期时间设置为1小时后
        this.status = "Verified"; // 示例：默认状态设置为已验证
    }



    public User() {

    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public LocalDateTime getAccountCreated() {
        return accountCreated;
    }

    public void setAccountCreated(LocalDateTime accountCreated) {
        this.accountCreated = accountCreated;
    }

    public LocalDateTime getAccountUpdated() {
        return accountUpdated;
    }

    public void setAccountUpdated(LocalDateTime accountUpdated) {
        this.accountUpdated = accountUpdated;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public LocalDateTime getTokenCreationTime() {
        return tokenCreationTime;
    }

    public void setTokenCreationTime(LocalDateTime tokenCreationTime) {
        this.tokenCreationTime = tokenCreationTime;
    }

    public LocalDateTime getTokenExpirationTime() {
        return tokenExpirationTime;
    }

    public void setTokenExpirationTime(LocalDateTime tokenExpirationTime) {
        this.tokenExpirationTime = tokenExpirationTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "User [id=" + id + ", firstName=" + firstName + ", lastName=" + lastName + ", username=" + username
                + ", password=" + password + ", accountCreated=" + accountCreated + ", accountUpdated=" + accountUpdated
                + ", token=" + token + ", tokenCreationTime=" + tokenCreationTime + ", tokenExpirationTime="
                + tokenExpirationTime + ", status=" + status + "]";
    }

}
