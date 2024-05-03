package com.projects.healthcheck;
//

//import org.junit.jupiter.api.Test;
//import org.springframework.boot.test.context.SpringBootTest;
//
//@SpringBootTest
//class HealthcheckApplicationTests {
//
//	@Test
//	void contextLoads() {
//	}
//
//}

//package com.projects.healthcheck.rest;

import com.projects.healthcheck.dao.TestUserRepository;
import com.projects.healthcheck.dto.UserInfoDto;
import com.projects.healthcheck.entity.User;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HealthcheckApplicationTests {

    @LocalServerPort
    private int port;

    private String baseUrl;

    @Autowired
    private PasswordEncoder bCryptPasswordEncoder;

    private static TestRestTemplate restTemplate;

    @Autowired
    // private UserRepository userRepository;
    private TestUserRepository testUserRepository;

    @BeforeAll
    public static void init() {
        restTemplate = new TestRestTemplate();
    }

    @BeforeEach
    public void setUp() {
        baseUrl = "http://localhost:" + port + "/v1/user";
        // Assume a method to clean up the database before each test
        testUserRepository.deleteAllInBatch();
    }

    @Test
    public void createAndGetUserTest() {
        String userJson = "{\"username\":\"testUser@example.com\",\"password\":\"password\",\"first_name\":\"Test\",\"last_name\":\"User\"}";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>(userJson, headers);

        ResponseEntity<User> response = restTemplate.postForEntity(baseUrl, entity, User.class);
//        assertEquals(HttpStatus.CREATED.value(), response.getStatusCodeValue());

        User createdUser = response.getBody();
        assertNotNull(createdUser);

        // Manually verify the user
        Optional<User> optionalUser = testUserRepository.findByUsername("testUser@example.com");
        assertTrue(optionalUser.isPresent());
        User userToUpdate = optionalUser.get();
        userToUpdate.setStatus("Verified");
        testUserRepository.save(userToUpdate);

        // 设置 tokenExpirationTime 为当前时间之后的一段时间，例如1小时后
        userToUpdate.setTokenExpirationTime(LocalDateTime.now().plusHours(1));
        testUserRepository.save(userToUpdate);

        // Use credentials to perform GET request
        TestRestTemplate newRestTemplate = new TestRestTemplate("testUser@example.com", "password");
        ResponseEntity<String> newResponse = newRestTemplate.getForEntity(baseUrl + "/self", String.class);

        assertEquals(HttpStatus.OK.value(), newResponse.getStatusCodeValue());
        assertTrue(newResponse.getBody().contains("testUser@example.com"));
    }

    @Test
    public void updateSelfTest() {
        // 创建用户并设置密码
        User user = new User("a", "a", "a@example.com", "a", LocalDateTime.now(), LocalDateTime.now(), "Verified", LocalDateTime.now().plusHours(1));
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));

        // 保存用户到数据库
        testUserRepository.save(user);

        // 准备更新用户信息的 JSON 数据
        String updateInfoJson = "{\"username\":\"a@example.com\", \"password\":\"a\", \"first_name\":\"new\",\"last_name\":\"new\"}";

        // 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 创建 HttpEntity 对象，包含请求体和请求头
        HttpEntity<String> entity = new HttpEntity<>(updateInfoJson, headers);
        TestRestTemplate restTemplate = new TestRestTemplate("a@example.com", "a");

        // 发送 PUT 请求以更新用户信息
        restTemplate.put(baseUrl + "/self", entity, UserInfoDto.class);

        // 从数据库中获取更新后的用户信息，验证更改
        User updatedUser = testUserRepository.findByUsername("a@example.com").orElseThrow();
        assertEquals("new", updatedUser.getFirstName());

        // 使用经过认证的 restTemplate 发起 GET 请求，验证更新是否成功
        TestRestTemplate newRestTemplate = new TestRestTemplate("a@example.com", "a");
        ResponseEntity<String> newResponse = newRestTemplate.getForEntity(baseUrl + "/self", String.class);

        assertEquals(HttpStatus.OK.value(), newResponse.getStatusCodeValue());
        assertTrue(newResponse.getBody().contains("new"));
    }


}