package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

/**
 * Test class for the main Spring Boot application.
 */
@SpringBootTest
@TestPropertySource(properties = {
    "spring.main.web-application-type=servlet",
    "server.port=0"
})
class SampleApplicationTests {

    @Test
    void contextLoads() {
        // This test verifies that the Spring context loads successfully
    }
} 