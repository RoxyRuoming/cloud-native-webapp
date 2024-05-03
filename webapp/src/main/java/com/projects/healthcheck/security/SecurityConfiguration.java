package com.projects.healthcheck.security;

import com.projects.healthcheck.service.CustomUserDetailsService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;


@Configuration
@EnableWebSecurity
public class SecurityConfiguration {

    private final CustomUserDetailsService userDetailsService;

    public SecurityConfiguration(CustomUserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.authorizeHttpRequests(configurer ->
                configurer
                        .requestMatchers(HttpMethod.GET, "/v1/user/self").authenticated()
                        .requestMatchers(HttpMethod.GET, "/v1/user/self").authenticated()
//                        .requestMatchers(HttpMethod.GET, "/v1/user/self").hasRole("ROLE_USER")
//                        .requestMatchers(HttpMethod.GET, "/v1/user/self").hasRole("ROLE_USER")
                        .anyRequest().permitAll()
        );

        // use HTTP Basic authentication
        http.httpBasic(Customizer.withDefaults());

        // disable Cross Site Request Forgery (CSRF)
        http.csrf(csrf -> csrf.disable());

        return http.build();
    }
}

