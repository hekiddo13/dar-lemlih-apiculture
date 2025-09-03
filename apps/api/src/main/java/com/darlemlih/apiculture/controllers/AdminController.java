package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.admin.*;
import com.darlemlih.apiculture.dto.product.ProductDto;
import com.darlemlih.apiculture.entities.User;
import com.darlemlih.apiculture.entities.enums.UserRole;
import com.darlemlih.apiculture.repositories.UserRepository;
import com.darlemlih.apiculture.services.AdminService;
import com.darlemlih.apiculture.services.ProductService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final ProductService productService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/dashboard")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardDto> getDashboard() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }

    @PostMapping("/seed")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<String> seedDatabase() {
        adminService.seedDatabase();
        return ResponseEntity.ok("Database seeded successfully");
    }
    
    @PostMapping("/reset-passwords")
    public ResponseEntity<Map<String, Object>> resetPasswords() {
        Map<String, Object> result = new HashMap<>();
        
        // Reset admin password
        userRepository.findByEmail("admin@darlemlih.ma").ifPresent(user -> {
            user.setPassword(passwordEncoder.encode("Admin!234"));
            userRepository.save(user);
            result.put("admin", "Password reset to Admin!234");
        });
        
        // Reset customer password
        userRepository.findByEmail("customer@darlemlih.ma").ifPresent(user -> {
            user.setPassword(passwordEncoder.encode("Customer!234"));
            userRepository.save(user);
            result.put("customer", "Password reset to Customer!234");
        });
        
        // Create users if they don't exist
        if (!userRepository.existsByEmail("admin@darlemlih.ma")) {
            User admin = User.builder()
                    .name("Admin User")
                    .email("admin@darlemlih.ma")
                    .password(passwordEncoder.encode("Admin!234"))
                    .phone("+212600000001")
                    .role(UserRole.ADMIN)
                    .enabled(true)
                    .emailVerified(true)
                    .build();
            userRepository.save(admin);
            result.put("admin", "Admin user created with password Admin!234");
        }
        
        if (!userRepository.existsByEmail("customer@darlemlih.ma")) {
            User customer = User.builder()
                    .name("Customer User")
                    .email("customer@darlemlih.ma")
                    .password(passwordEncoder.encode("Customer!234"))
                    .phone("+212600000002")
                    .role(UserRole.CUSTOMER)
                    .enabled(true)
                    .emailVerified(true)
                    .build();
            userRepository.save(customer);
            result.put("customer", "Customer user created with password Customer!234");
        }
        
        result.put("message", "Passwords reset successfully");
        return ResponseEntity.ok(result);
    }

    // Basic product management for MVP
    @GetMapping("/products")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<ProductDto>> listProducts(Pageable pageable) {
        return ResponseEntity.ok(productService.listAll(pageable));
    }

    @PostMapping("/products")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductDto> createProduct(@RequestBody ProductDto dto) {
        return ResponseEntity.ok(productService.create(dto));
    }

    @DeleteMapping("/products/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
