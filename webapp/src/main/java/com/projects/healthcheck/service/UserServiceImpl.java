package com.projects.healthcheck.service;

import com.projects.healthcheck.dao.UserRepository;
import com.projects.healthcheck.dto.UserInfoDto;
import com.projects.healthcheck.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {
    private UserRepository userRepository;

    private PasswordEncoder bCryptPasswordEncoder;

    @Autowired
    public UserServiceImpl(UserRepository userRepository, PasswordEncoder bCryptPasswordEncoder) {
        this.userRepository = userRepository;
        this.bCryptPasswordEncoder = bCryptPasswordEncoder;
    }

    @Override
    public User createUser(User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        // ignoring any user input of setting accountCreated and accountUpdated
        user.setAccountCreated(LocalDateTime.now());
        user.setAccountUpdated(LocalDateTime.now());
        return userRepository.save(user);
    }

    @Override
    // user vs userInfoDto: user is info before change, userInfoDto is the user
    // object from the request body
    public User updateUser(User user, UserInfoDto userInfoDto) {
        Optional<User> existingUser = userRepository.findByUsername(user.getUsername());
        if (!existingUser.isPresent()) {
            return null;
        }
        User updatedUser = existingUser.get();
        updatedUser.setFirstName(userInfoDto.getFirstName());
        updatedUser.setLastName(userInfoDto.getLastName());
        updatedUser.setPassword(bCryptPasswordEncoder.encode(userInfoDto.getPassword()));
        updatedUser.setAccountUpdated(LocalDateTime.now());
//        updatedUser.setStatus(userInfoDto.getStatus());
        return userRepository.save(updatedUser);
    }

    @Override
    public User getUserInformation(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }
}
