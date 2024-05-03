package com.projects.healthcheck.service;

import com.projects.healthcheck.dto.UserInfoDto;
import com.projects.healthcheck.entity.User;

public interface UserService {

    User createUser(User user);

    User updateUser(User user, UserInfoDto userInfoDto);

    User getUserInformation(String username);
}