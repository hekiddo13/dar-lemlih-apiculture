#!/bin/bash

API_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/api/src/main/java/com/darlemlih/apiculture"

echo "Creating missing DTOs..."

# Create auth DTOs
cat > "$API_PATH/dto/auth/RegisterRequest.java" << 'JAVA'
package com.darlemlih.apiculture.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Name is required")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
    
    private String phone;
}
JAVA

cat > "$API_PATH/dto/auth/LoginRequest.java" << 'JAVA'
package com.darlemlih.apiculture.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @NotBlank(message = "Password is required")
    private String password;
}
JAVA

cat > "$API_PATH/dto/auth/AuthResponse.java" << 'JAVA'
package com.darlemlih.apiculture.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType = "Bearer";
    private Long expiresIn;
    private UserDto user;
}
JAVA

cat > "$API_PATH/dto/auth/UserDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.auth;

import com.darlemlih.apiculture.entities.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserDto {
    private Long id;
    private String name;
    private String email;
    private String phone;
    private UserRole role;
    private Boolean emailVerified;
}
JAVA

# Create Product DTOs
mkdir -p "$API_PATH/dto/product"

cat > "$API_PATH/dto/product/ProductDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ProductDto {
    private Long id;
    private String sku;
    private String slug;
    private String nameFr;
    private String nameEn;
    private String nameAr;
    private String descriptionFr;
    private String descriptionEn;
    private String descriptionAr;
    private BigDecimal price;
    private String currency;
    private Integer stockQuantity;
    private Integer weightGrams;
    private String ingredients;
    private String origin;
    private Boolean isHalal;
    private Boolean isActive;
    private Boolean isFeatured;
    private List<String> images;
    private Long categoryId;
    private String categoryName;
}
JAVA

# Create Payment Gateway Interface
cat > "$API_PATH/payments/PaymentGateway.java" << 'JAVA'
package com.darlemlih.apiculture.payments;

import java.math.BigDecimal;

public interface PaymentGateway {
    PaymentSession createCheckoutSession(String orderId, BigDecimal amount, String currency, String successUrl, String cancelUrl);
    boolean verifyWebhook(String signature, String payload);
    RefundResult refund(String paymentIntentId, BigDecimal amount);
}
JAVA

cat > "$API_PATH/payments/PaymentSession.java" << 'JAVA'
package com.darlemlih.apiculture.payments;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PaymentSession {
    private String sessionId;
    private String paymentIntentId;
    private String checkoutUrl;
    private String status;
}
JAVA

cat > "$API_PATH/payments/RefundResult.java" << 'JAVA'
package com.darlemlih.apiculture.payments;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RefundResult {
    private String refundId;
    private String status;
    private BigDecimal amount;
    private String reason;
}
JAVA

# Mock Payment Gateway
cat > "$API_PATH/payments/MockPaymentGateway.java" << 'JAVA'
package com.darlemlih.apiculture.payments;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@ConditionalOnProperty(name = "payment.provider", havingValue = "mock")
public class MockPaymentGateway implements PaymentGateway {

    @Override
    public PaymentSession createCheckoutSession(String orderId, BigDecimal amount, String currency, String successUrl, String cancelUrl) {
        return PaymentSession.builder()
                .sessionId("mock_session_" + UUID.randomUUID())
                .paymentIntentId("pi_mock_" + UUID.randomUUID())
                .checkoutUrl(successUrl + "?mock=true")
                .status("pending")
                .build();
    }

    @Override
    public boolean verifyWebhook(String signature, String payload) {
        return true;
    }

    @Override
    public RefundResult refund(String paymentIntentId, BigDecimal amount) {
        return RefundResult.builder()
                .refundId("refund_mock_" + UUID.randomUUID())
                .status("succeeded")
                .amount(amount)
                .reason("requested_by_customer")
                .build();
    }
}
JAVA

# Product Controller
cat > "$API_PATH/controllers/ProductController.java" << 'JAVA'
package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.product.ProductDto;
import com.darlemlih.apiculture.services.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<Page<ProductDto>> getProducts(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            Pageable pageable) {
        return ResponseEntity.ok(productService.searchProducts(search, categoryId, minPrice, maxPrice, pageable));
    }

    @GetMapping("/{slug}")
    public ResponseEntity<ProductDto> getProductBySlug(@PathVariable String slug) {
        return ResponseEntity.ok(productService.getProductBySlug(slug));
    }

    @GetMapping("/featured")
    public ResponseEntity<Page<ProductDto>> getFeaturedProducts(Pageable pageable) {
        return ResponseEntity.ok(productService.getFeaturedProducts(pageable));
    }
}
JAVA

# Product Service
cat > "$API_PATH/services/ProductService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.dto.product.ProductDto;
import com.darlemlih.apiculture.entities.Product;
import com.darlemlih.apiculture.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;

    public Page<ProductDto> searchProducts(String search, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice, Pageable pageable) {
        return productRepository.searchProducts(search, categoryId, minPrice, maxPrice, pageable)
                .map(this::toDto);
    }

    public ProductDto getProductBySlug(String slug) {
        Product product = productRepository.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return toDto(product);
    }

    public Page<ProductDto> getFeaturedProducts(Pageable pageable) {
        return productRepository.findByIsFeaturedTrueAndIsActiveTrue(pageable)
                .map(this::toDto);
    }

    private ProductDto toDto(Product product) {
        return ProductDto.builder()
                .id(product.getId())
                .sku(product.getSku())
                .slug(product.getSlug())
                .nameFr(product.getNameFr())
                .nameEn(product.getNameEn())
                .nameAr(product.getNameAr())
                .descriptionFr(product.getDescriptionFr())
                .descriptionEn(product.getDescriptionEn())
                .descriptionAr(product.getDescriptionAr())
                .price(product.getPrice())
                .currency(product.getCurrency())
                .stockQuantity(product.getStockQuantity())
                .weightGrams(product.getWeightGrams())
                .ingredients(product.getIngredients())
                .origin(product.getOrigin())
                .isHalal(product.getIsHalal())
                .isActive(product.getIsActive())
                .isFeatured(product.getIsFeatured())
                .images(product.getImages())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .categoryName(product.getCategory() != null ? product.getCategory().getNameFr() : null)
                .build();
    }
}
JAVA

echo "Backend setup complete!"
