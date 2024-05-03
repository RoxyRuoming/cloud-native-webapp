package com.projects.healthcheck.rest;

import com.google.api.core.ApiFuture;
import com.google.pubsub.v1.ProjectTopicName;
import com.google.pubsub.v1.PubsubMessage;
import com.projects.healthcheck.dao.UserRepository;
import com.projects.healthcheck.dto.UserInfoDto;
import com.projects.healthcheck.entity.User;
import com.projects.healthcheck.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.lang.InterruptedException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.cloud.pubsub.v1.Publisher;
import com.google.protobuf.ByteString;

@RestController
@RequestMapping("/v1/user")
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private UserService userService;
    private UserRepository userRepository;

    private Publisher publisher;
    private static final String PROJECT_ID = "csye6225-dev-a04";
    private static final String TOPIC_ID = "verify-email"; // "csye-6225-demo-test"

    @Autowired
    public UserController(UserService userService, UserRepository userRepository) {
        this.userService = userService;
        this.userRepository = userRepository;
        // initial Publisher
        try {
            ProjectTopicName topicName = ProjectTopicName.of(PROJECT_ID, TOPIC_ID);
            this.publisher = Publisher.newBuilder(topicName).build();
        } catch (IOException e) {
            logger.error("Error initializing Pub/Sub Publisher: {}", e.getMessage());
        }

    }

    @GetMapping("/verify")
    public ResponseEntity<String> verifyUser(@RequestParam("username") String username,
            @RequestParam("token") String token) {
        // find the user
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (!optionalUser.isPresent()) {
            // user not exist
            return new ResponseEntity<>("User does not exist.", HttpStatus.NOT_FOUND);
        }

        User user = optionalUser.get();
        // check user state
        if (user.getStatus().equals("Verified")) {
            return new ResponseEntity<>("You have been verified. Do not repeat the process!", HttpStatus.BAD_REQUEST);
        }

        // check token expiration info
        if (user.getTokenExpirationTime().isBefore(LocalDateTime.now())) {
            // if expired
            return new ResponseEntity<>("Your verification link expired. Please retry!", HttpStatus.FORBIDDEN);
        }

        // update user verification state as "Verified"
        user.setStatus("Verified");
        userRepository.save(user); // save user new info

        // return ok
        return new ResponseEntity<>("Congratulations! You are verified.", HttpStatus.OK);
    }

    @PostMapping
    public ResponseEntity<?> createUser(@RequestBody User user) {
        if (userService.getUserInformation(user.getUsername()) != null || !isValidEmail(user.getUsername())) {
            logger.warn("Attempt to create a user with invalid email or duplicate username: {}", user.getUsername());
            return ResponseEntity.badRequest().build();
        }
        User createdUser = userService.createUser(user);
        logger.info("User created successfully: {}", createdUser.getUsername());

        // Once user created successfully, publish a message pub/sub topic in gcp
        publishMessage(createdUser);

        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(createdUser.getId())
                .toUri();

        return ResponseEntity.created(location).body(createdUser);
    }

    private void publishMessage(User user) {
        // Construct the message payload
        String payload = "{\"username\": \"" + user.getUsername() + "\", \"email\": \"" + user.getUsername() + "\"}";
        ByteString data = ByteString.copyFromUtf8(payload);
        PubsubMessage message = PubsubMessage.newBuilder().setData(data).build();

        try {
            // Publish the message to the associated Pub/Sub topic
            ApiFuture<String> future = publisher.publish(message); // No need to specify TopicName here
            // Optionally, block and wait for the publish operation to complete
            String messageId = future.get(); // This is a blocking call
            logger.info("Message published with ID: {}", messageId);
        } catch (InterruptedException e) {
            logger.error("Publish thread was interrupted", e);
            // Restore the interrupted status
            Thread.currentThread().interrupt();
        } catch (ExecutionException e) {
            logger.error("Error occurred while publishing message to Pub/Sub topic", e.getCause());
        }
    }

    public boolean isValidEmail(String email) {
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        Pattern pattern = Pattern.compile(emailRegex);
        if (email == null)
            return false;
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }

    public boolean checkStatus(String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            logger.debug("User status for {}: {}", username, user.getStatus());
            return user.getStatus().equals("Verified");
        } else {
            logger.error("User not found for username: {}", username);
            return false;
        }
    }

    @GetMapping("/testSerialization")
    public ResponseEntity<UserInfoDto> testSerialization() {
        logger.debug("Testing serialization of UserInfoDto");
        UserInfoDto staticUserInfo = new UserInfoDto();
        staticUserInfo.setUsername("testUser");
        staticUserInfo.setFirstName("Test");
        staticUserInfo.setLastName("User");

        return ResponseEntity.ok(staticUserInfo);
    }

    @GetMapping(value = "/self")
    public ResponseEntity<?> getSelf(Authentication authentication) {
        String username = authentication.getName();

        // Check if user status is verified
        boolean isVerified = checkStatus(username);
        if (!isVerified) {
            logger.error("User {} is not verified", username);
            return new ResponseEntity<>("User is not verified", HttpStatus.FORBIDDEN);
        }

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> {
                    logger.error("User not found for username: {}", username);
                    return new ResponseStatusException(HttpStatus.NOT_FOUND);
                });

        UserInfoDto userInfo = new UserInfoDto(user);
        logger.info("User information successfully acquired for: {}", username);
        return ResponseEntity.ok(userInfo);
    }

    @PutMapping(value = "/self")
    public ResponseEntity<?> updateUserInformation(Authentication authentication,
            @RequestBody UserInfoDto userInfoDto) {
        String username = authentication.getName();
        logger.debug("Request to update user information for: {}", username);

        // Check if user status is verified
        boolean isVerified = checkStatus(username);
        if (!isVerified) {
            logger.error("User {} is not verified", username);
            return new ResponseEntity<>("User is not verified", HttpStatus.FORBIDDEN);
        }

        User user = userRepository.findByUsername(username).orElse(null);
        if (user == null) {
            logger.warn("Attempt to update non-existing user: {}", username);
            return ResponseEntity.badRequest().build();
        }

        if (!userInfoDto.getUsername().equals(username)) {
            logger.warn("Attempt by {} to update another user's information: {}", username, userInfoDto.getUsername());
            return ResponseEntity.badRequest().build();
        }

        boolean isIllegalAttempt = false;
        if ((userInfoDto.getId() != null && !userInfoDto.getId().equals(user.getId())) ||
                (userInfoDto.getUsername() != null && !userInfoDto.getUsername().equals(user.getUsername())) ||
                userInfoDto.getAccountCreated() != null ||
                userInfoDto.getAccountUpdated() != null) {
            isIllegalAttempt = true;
        }

        if (isIllegalAttempt) {
            logger.error("Illegal attempt to update restricted fields by user: {}", username);
            return ResponseEntity.badRequest().build();
        }

        try {
            userService.updateUser(user, userInfoDto);
            logger.info("User information updated successfully for: {}", username);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            logger.error("Error updating user information for: {}", username, e);
            return ResponseEntity.badRequest().build();
        }
    }
}