package com.projects.healthcheck;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = { "com.projects.healthcheck" })
public class HealthcheckApplication {

	public static void main(String[] args) {
		SpringApplication.run(HealthcheckApplication.class, args);
	}

}