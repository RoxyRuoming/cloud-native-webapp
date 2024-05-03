package com.projects.healthcheck.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.projects.healthcheck.entity.User;
import org.hibernate.annotations.DynamicUpdate;

import java.time.LocalDateTime;
import java.util.UUID;

public class UserInfoDto { // for safety consideration...

    private UUID id;
    private String username;
    @JsonProperty("first_name")
    private String firstName;

    @JsonProperty("last_name")
    private String lastName;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    @JsonProperty(value = "account_created", access = JsonProperty.Access.READ_ONLY)
    private LocalDateTime accountCreated;

    @JsonProperty(value = "account_updated", access = JsonProperty.Access.READ_ONLY)
    private LocalDateTime accountUpdated;

    // token,tokenCreationTime,tokenExpirationTime
    @JsonProperty(value = "token", access = JsonProperty.Access.WRITE_ONLY)
    private String token;

    @JsonProperty(value = "token_creation_time", access = JsonProperty.Access.READ_ONLY)
    private LocalDateTime tokenCreationTime;

    @JsonProperty(value = "token_expiration_time", access = JsonProperty.Access.READ_ONLY)
    private LocalDateTime tokenExpirationTime;

//    @JsonProperty(value = "status")
    @JsonProperty(value = "status", access = JsonProperty.Access.READ_ONLY)
    private String status;

    public UserInfoDto() {
    }

    public UserInfoDto(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.firstName = user.getFirstName();
        this.password = user.getPassword();
        this.lastName = user.getLastName();
        this.accountCreated = user.getAccountCreated();
        this.accountUpdated = user.getAccountUpdated();
        this.token = user.getToken();
        this.tokenCreationTime = user.getTokenCreationTime();
        this.tokenExpirationTime = user.getTokenExpirationTime();
        this.status = user.getStatus();
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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
}
