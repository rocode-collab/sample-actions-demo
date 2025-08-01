package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * REST controller providing endpoints for the sample application.
 */
@RestController
public class HelloController {

    /**
     * Default welcome endpoint.
     * 
     * @return welcome message
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Welcome to Sample Java Application!");
        response.put("timestamp", LocalDateTime.now());
        response.put("status", "running");
        return ResponseEntity.ok(response);
    }

    /**
     * Hello endpoint with optional name parameter.
     * 
     * @param name optional name parameter
     * @return personalized greeting
     */
    @GetMapping("/hello")
    public ResponseEntity<Map<String, Object>> hello(@RequestParam(value = "name", defaultValue = "World") String name) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello, " + name + "!");
        response.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint.
     * 
     * @return health status
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("timestamp", LocalDateTime.now());
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }

    /**
     * Info endpoint with application details.
     * 
     * @return application information
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", "Sample Java Application");
        response.put("version", "1.0.0");
        response.put("java_version", System.getProperty("java.version"));
        response.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(response);
    }
} 