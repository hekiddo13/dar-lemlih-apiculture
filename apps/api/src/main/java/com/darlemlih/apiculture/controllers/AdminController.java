package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.admin.*;
import com.darlemlih.apiculture.services.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardDto> getDashboard() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    @PostMapping("/seed")
    public ResponseEntity<String> seedDatabase() {
        adminService.seedDatabase();
        return ResponseEntity.ok("Database seeded successfully");
    }
}
