package com.projects.healthcheck.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import jakarta.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class HealthRestController {
    private static final Logger logger = LoggerFactory.getLogger(HealthRestController.class);

    @Autowired
    private DataSource dataSource;

    public HealthRestController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @RequestMapping(value = "/healthz", method = { RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT,
            RequestMethod.DELETE, RequestMethod.PATCH, RequestMethod.HEAD, RequestMethod.OPTIONS })
    public ResponseEntity<Void> checkHealth(HttpServletRequest request) {
        try (Connection connection = dataSource.getConnection()) {
            // If the method is not allowed, return 405
            if (!request.getMethod().equals("GET")) {
                logger.error("Method Not Allowed - Only GET method is allowed");
                return ResponseEntity.status(405)
                        .header("Cache-Control", "no-cache, no-store, must-revalidate")
                        .header("Pragma", "no-cache")
                        .header("X-Content-Type-Options", "nosniff")
                        .build();
            }

            // If there are query parameters or a request body, return 400
            if (request.getQueryString() != null || request.getContentLengthLong() > 0) {
                logger.error("Bad Request - Query Parameters or Request Body is not allowed");
                return ResponseEntity.status(400)
                        .header("Cache-Control", "no-cache, no-store, must-revalidate")
                        .header("Pragma", "no-cache")
                        .header("X-Content-Type-Options", "nosniff")
                        .build();
            }

            // If no errors, return 200
            logger.info("Health Check Successful");
            return ResponseEntity.status(200)
                    .header("Cache-Control", "no-cache, no-store, must-revalidate")
                    .header("Pragma", "no-cache")
                    .header("X-Content-Type-Options", "nosniff")
                    .build();
        } catch (Exception e) {
            // If database connection fails, return 503
            logger.error("Service Unavailable - Database Connection Failed");
            return ResponseEntity.status(503)
                    .header("Cache-Control", "no-cache, no-store, must-revalidate")
                    .header("Pragma", "no-cache")
                    .header("X-Content-Type-Options", "nosniff")
                    .build();
        }
    }
}
