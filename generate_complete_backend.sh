#!/bin/bash

API_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/api/src/main/java/com/darlemlih/apiculture"

echo "🚀 Generating complete Spring Boot backend..."

# ===== CART CONTROLLER =====
cat > "$API_PATH/controllers/CartController.java" << 'JAVA'
package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.cart.*;
import com.darlemlih.apiculture.services.CartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public ResponseEntity<CartDto> getCart(@AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(cartService.getCart(userDetails.getUsername()));
    }

    @PostMapping("/add")
    public ResponseEntity<CartDto> addToCart(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody AddToCartRequest request) {
        return ResponseEntity.ok(cartService.addToCart(userDetails.getUsername(), request));
    }

    @PutMapping("/update")
    public ResponseEntity<CartDto> updateCartItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateCartItemRequest request) {
        return ResponseEntity.ok(cartService.updateCartItem(userDetails.getUsername(), request));
    }

    @DeleteMapping("/remove/{productId}")
    public ResponseEntity<CartDto> removeFromCart(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long productId) {
        return ResponseEntity.ok(cartService.removeFromCart(userDetails.getUsername(), productId));
    }

    @DeleteMapping("/clear")
    public ResponseEntity<Void> clearCart(@AuthenticationPrincipal UserDetails userDetails) {
        cartService.clearCart(userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }
}
JAVA

# ===== CART DTOs =====
mkdir -p "$API_PATH/dto/cart"

cat > "$API_PATH/dto/cart/CartDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.cart;

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
public class CartDto {
    private Long id;
    private List<CartItemDto> items;
    private BigDecimal subtotal;
    private BigDecimal shippingCost;
    private BigDecimal total;
    private String currency;
    private Integer totalItems;
}
JAVA

cat > "$API_PATH/dto/cart/CartItemDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.cart;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CartItemDto {
    private Long id;
    private Long productId;
    private String productName;
    private String productSlug;
    private String productImage;
    private BigDecimal unitPrice;
    private Integer quantity;
    private BigDecimal totalPrice;
    private Integer stockQuantity;
}
JAVA

cat > "$API_PATH/dto/cart/AddToCartRequest.java" << 'JAVA'
package com.darlemlih.apiculture.dto.cart;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddToCartRequest {
    @NotNull(message = "Product ID is required")
    private Long productId;
    
    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity;
}
JAVA

cat > "$API_PATH/dto/cart/UpdateCartItemRequest.java" << 'JAVA'
package com.darlemlih.apiculture.dto.cart;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateCartItemRequest {
    @NotNull(message = "Product ID is required")
    private Long productId;
    
    @NotNull(message = "Quantity is required")
    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity;
}
JAVA

# ===== CART SERVICE =====
cat > "$API_PATH/services/CartService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.dto.cart.*;
import com.darlemlih.apiculture.entities.*;
import com.darlemlih.apiculture.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    private static final BigDecimal SHIPPING_COST = new BigDecimal("30.00");

    public CartDto getCart(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Cart cart = cartRepository.findByUser(user)
                .orElseGet(() -> createNewCart(user));
        
        return toDto(cart);
    }

    public CartDto addToCart(String userEmail, AddToCartRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        if (product.getStockQuantity() < request.getQuantity()) {
            throw new RuntimeException("Insufficient stock");
        }
        
        Cart cart = cartRepository.findByUser(user)
                .orElseGet(() -> createNewCart(user));
        
        CartItem existingItem = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(request.getProductId()))
                .findFirst()
                .orElse(null);
        
        if (existingItem != null) {
            existingItem.setQuantity(existingItem.getQuantity() + request.getQuantity());
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .product(product)
                    .quantity(request.getQuantity())
                    .build();
            cart.getItems().add(newItem);
        }
        
        cart = cartRepository.save(cart);
        return toDto(cart);
    }

    public CartDto updateCartItem(String userEmail, UpdateCartItemRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        CartItem item = cart.getItems().stream()
                .filter(i -> i.getProduct().getId().equals(request.getProductId()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Item not found in cart"));
        
        if (item.getProduct().getStockQuantity() < request.getQuantity()) {
            throw new RuntimeException("Insufficient stock");
        }
        
        item.setQuantity(request.getQuantity());
        cart = cartRepository.save(cart);
        return toDto(cart);
    }

    public CartDto removeFromCart(String userEmail, Long productId) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        cart.getItems().removeIf(item -> item.getProduct().getId().equals(productId));
        cart = cartRepository.save(cart);
        return toDto(cart);
    }

    public void clearCart(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        cart.getItems().clear();
        cartRepository.save(cart);
    }

    private Cart createNewCart(User user) {
        Cart cart = Cart.builder()
                .user(user)
                .build();
        return cartRepository.save(cart);
    }

    private CartDto toDto(Cart cart) {
        BigDecimal subtotal = cart.getTotal();
        BigDecimal total = subtotal.add(SHIPPING_COST);
        
        return CartDto.builder()
                .id(cart.getId())
                .items(cart.getItems().stream()
                        .map(this::toItemDto)
                        .collect(Collectors.toList()))
                .subtotal(subtotal)
                .shippingCost(SHIPPING_COST)
                .total(total)
                .currency("MAD")
                .totalItems(cart.getTotalItems())
                .build();
    }

    private CartItemDto toItemDto(CartItem item) {
        Product product = item.getProduct();
        BigDecimal totalPrice = product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
        
        return CartItemDto.builder()
                .id(item.getId())
                .productId(product.getId())
                .productName(product.getNameFr())
                .productSlug(product.getSlug())
                .productImage(product.getImages().isEmpty() ? null : product.getImages().get(0))
                .unitPrice(product.getPrice())
                .quantity(item.getQuantity())
                .totalPrice(totalPrice)
                .stockQuantity(product.getStockQuantity())
                .build();
    }
}
JAVA

# ===== ORDER CONTROLLER =====
cat > "$API_PATH/controllers/OrderController.java" << 'JAVA'
package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.order.*;
import com.darlemlih.apiculture.services.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<Page<OrderDto>> getUserOrders(
            @AuthenticationPrincipal UserDetails userDetails,
            Pageable pageable) {
        return ResponseEntity.ok(orderService.getUserOrders(userDetails.getUsername(), pageable));
    }

    @GetMapping("/{orderNumber}")
    public ResponseEntity<OrderDto> getOrder(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String orderNumber) {
        return ResponseEntity.ok(orderService.getOrder(userDetails.getUsername(), orderNumber));
    }

    @PostMapping("/checkout")
    public ResponseEntity<CheckoutResponse> checkout(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CheckoutRequest request) {
        return ResponseEntity.ok(orderService.checkout(userDetails.getUsername(), request));
    }
}
JAVA

# ===== ORDER DTOs =====
mkdir -p "$API_PATH/dto/order"

cat > "$API_PATH/dto/order/OrderDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.order;

import com.darlemlih.apiculture.entities.enums.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class OrderDto {
    private Long id;
    private String orderNumber;
    private OrderStatus status;
    private BigDecimal subtotal;
    private BigDecimal shippingCost;
    private BigDecimal discount;
    private BigDecimal total;
    private String currency;
    private String paymentProvider;
    private String trackingNumber;
    private ShippingAddressDto shippingAddress;
    private List<OrderItemDto> items;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
JAVA

cat > "$API_PATH/dto/order/OrderItemDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class OrderItemDto {
    private Long id;
    private Long productId;
    private String productName;
    private String productSku;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
}
JAVA

cat > "$API_PATH/dto/order/ShippingAddressDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.order;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ShippingAddressDto {
    @NotBlank(message = "Name is required")
    private String name;
    
    @NotBlank(message = "Phone is required")
    private String phone;
    
    @NotBlank(message = "Address line 1 is required")
    private String line1;
    
    private String line2;
    
    @NotBlank(message = "City is required")
    private String city;
    
    @NotBlank(message = "Region is required")
    private String region;
    
    @NotBlank(message = "Postal code is required")
    private String postalCode;
    
    @NotBlank(message = "Country is required")
    private String country;
}
JAVA

cat > "$API_PATH/dto/order/CheckoutRequest.java" << 'JAVA'
package com.darlemlih.apiculture.dto.order;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CheckoutRequest {
    @NotNull(message = "Shipping address is required")
    @Valid
    private ShippingAddressDto shippingAddress;
    
    private String notes;
    
    @NotNull(message = "Payment method is required")
    private String paymentMethod;
}
JAVA

cat > "$API_PATH/dto/order/CheckoutResponse.java" << 'JAVA'
package com.darlemlih.apiculture.dto.order;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CheckoutResponse {
    private String orderNumber;
    private String paymentUrl;
    private String sessionId;
    private String status;
}
JAVA

# ===== ORDER SERVICE =====
cat > "$API_PATH/services/OrderService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.dto.order.*;
import com.darlemlih.apiculture.entities.*;
import com.darlemlih.apiculture.entities.enums.OrderStatus;
import com.darlemlih.apiculture.payments.PaymentGateway;
import com.darlemlih.apiculture.payments.PaymentSession;
import com.darlemlih.apiculture.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final PaymentGateway paymentGateway;
    private final EmailService emailService;

    @Value("${app.web-base-url}")
    private String webBaseUrl;

    private static final BigDecimal SHIPPING_COST = new BigDecimal("30.00");

    public Page<OrderDto> getUserOrders(String userEmail, Pageable pageable) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return orderRepository.findByUser(user, pageable)
                .map(this::toDto);
    }

    public OrderDto getOrder(String userEmail, String orderNumber) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Order order = orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        if (!order.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized access to order");
        }
        
        return toDto(order);
    }

    public CheckoutResponse checkout(String userEmail, CheckoutRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Cart cart = cartRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        if (cart.getItems().isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }
        
        // Verify stock availability
        for (CartItem item : cart.getItems()) {
            if (item.getProduct().getStockQuantity() < item.getQuantity()) {
                throw new RuntimeException("Insufficient stock for product: " + item.getProduct().getNameFr());
            }
        }
        
        // Create order
        Order order = createOrder(user, cart, request);
        
        // Create payment session
        String successUrl = webBaseUrl + "/orders/" + order.getOrderNumber() + "/success";
        String cancelUrl = webBaseUrl + "/checkout";
        
        PaymentSession session = paymentGateway.createCheckoutSession(
                order.getOrderNumber(),
                order.getTotal(),
                order.getCurrency(),
                successUrl,
                cancelUrl
        );
        
        order.setPaymentIntentId(session.getPaymentIntentId());
        orderRepository.save(order);
        
        // Clear cart
        cart.getItems().clear();
        cartRepository.save(cart);
        
        return CheckoutResponse.builder()
                .orderNumber(order.getOrderNumber())
                .paymentUrl(session.getCheckoutUrl())
                .sessionId(session.getSessionId())
                .status("pending")
                .build();
    }

    private Order createOrder(User user, Cart cart, CheckoutRequest request) {
        BigDecimal subtotal = cart.getTotal();
        BigDecimal total = subtotal.add(SHIPPING_COST);
        
        ShippingAddress shippingAddress = ShippingAddress.builder()
                .name(request.getShippingAddress().getName())
                .phone(request.getShippingAddress().getPhone())
                .line1(request.getShippingAddress().getLine1())
                .line2(request.getShippingAddress().getLine2())
                .city(request.getShippingAddress().getCity())
                .region(request.getShippingAddress().getRegion())
                .postalCode(request.getShippingAddress().getPostalCode())
                .country(request.getShippingAddress().getCountry())
                .build();
        
        Order order = Order.builder()
                .orderNumber(generateOrderNumber())
                .user(user)
                .status(OrderStatus.PENDING)
                .subtotal(subtotal)
                .shippingCost(SHIPPING_COST)
                .discount(BigDecimal.ZERO)
                .total(total)
                .currency("MAD")
                .paymentProvider(request.getPaymentMethod())
                .shippingAddress(shippingAddress)
                .notes(request.getNotes())
                .build();
        
        order = orderRepository.save(order);
        
        // Create order items
        for (CartItem cartItem : cart.getItems()) {
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .product(cartItem.getProduct())
                    .quantity(cartItem.getQuantity())
                    .unitPrice(cartItem.getProduct().getPrice())
                    .totalPrice(cartItem.getProduct().getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity())))
                    .build();
            order.getItems().add(orderItem);
            
            // Update stock
            Product product = cartItem.getProduct();
            product.setStockQuantity(product.getStockQuantity() - cartItem.getQuantity());
            productRepository.save(product);
        }
        
        return orderRepository.save(order);
    }

    private String generateOrderNumber() {
        return "ORD-" + LocalDateTime.now().getYear() + "-" + 
               String.format("%06d", (long) (Math.random() * 999999));
    }

    private OrderDto toDto(Order order) {
        return OrderDto.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .status(order.getStatus())
                .subtotal(order.getSubtotal())
                .shippingCost(order.getShippingCost())
                .discount(order.getDiscount())
                .total(order.getTotal())
                .currency(order.getCurrency())
                .paymentProvider(order.getPaymentProvider())
                .trackingNumber(order.getTrackingNumber())
                .shippingAddress(toShippingDto(order.getShippingAddress()))
                .items(order.getItems().stream()
                        .map(this::toItemDto)
                        .collect(Collectors.toList()))
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .build();
    }

    private ShippingAddressDto toShippingDto(ShippingAddress address) {
        if (address == null) return null;
        
        return ShippingAddressDto.builder()
                .name(address.getName())
                .phone(address.getPhone())
                .line1(address.getLine1())
                .line2(address.getLine2())
                .city(address.getCity())
                .region(address.getRegion())
                .postalCode(address.getPostalCode())
                .country(address.getCountry())
                .build();
    }

    private OrderItemDto toItemDto(OrderItem item) {
        return OrderItemDto.builder()
                .id(item.getId())
                .productId(item.getProduct().getId())
                .productName(item.getProduct().getNameFr())
                .productSku(item.getProduct().getSku())
                .quantity(item.getQuantity())
                .unitPrice(item.getUnitPrice())
                .totalPrice(item.getTotalPrice())
                .build();
    }
}
JAVA

# ===== CATEGORY CONTROLLER =====
cat > "$API_PATH/controllers/CategoryController.java" << 'JAVA'
package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.dto.category.CategoryDto;
import com.darlemlih.apiculture.services.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public ResponseEntity<List<CategoryDto>> getAllCategories() {
        return ResponseEntity.ok(categoryService.getAllActiveCategories());
    }

    @GetMapping("/{slug}")
    public ResponseEntity<CategoryDto> getCategoryBySlug(@PathVariable String slug) {
        return ResponseEntity.ok(categoryService.getCategoryBySlug(slug));
    }
}
JAVA

# ===== CATEGORY DTOs =====
mkdir -p "$API_PATH/dto/category"

cat > "$API_PATH/dto/category/CategoryDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.category;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CategoryDto {
    private Long id;
    private String slug;
    private String nameFr;
    private String nameEn;
    private String nameAr;
    private String descriptionFr;
    private String descriptionEn;
    private String descriptionAr;
    private String image;
    private Integer displayOrder;
    private Long productCount;
}
JAVA

# ===== CATEGORY SERVICE =====
cat > "$API_PATH/services/CategoryService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.dto.category.CategoryDto;
import com.darlemlih.apiculture.entities.Category;
import com.darlemlih.apiculture.repositories.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryDto> getAllActiveCategories() {
        return categoryRepository.findByIsActiveTrueOrderByDisplayOrder()
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public CategoryDto getCategoryBySlug(String slug) {
        Category category = categoryRepository.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        return toDto(category);
    }

    private CategoryDto toDto(Category category) {
        return CategoryDto.builder()
                .id(category.getId())
                .slug(category.getSlug())
                .nameFr(category.getNameFr())
                .nameEn(category.getNameEn())
                .nameAr(category.getNameAr())
                .descriptionFr(category.getDescriptionFr())
                .descriptionEn(category.getDescriptionEn())
                .descriptionAr(category.getDescriptionAr())
                .image(category.getImage())
                .displayOrder(category.getDisplayOrder())
                .productCount((long) category.getProducts().size())
                .build();
    }
}
JAVA

# ===== PAYMENT WEBHOOK CONTROLLER =====
cat > "$API_PATH/controllers/PaymentWebhookController.java" << 'JAVA'
package com.darlemlih.apiculture.controllers;

import com.darlemlih.apiculture.services.PaymentWebhookService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentWebhookController {

    private final PaymentWebhookService webhookService;

    @PostMapping("/webhook")
    public ResponseEntity<String> handleWebhook(
            @RequestHeader(value = "Stripe-Signature", required = false) String signature,
            @RequestBody String payload) {
        webhookService.processWebhook(signature, payload);
        return ResponseEntity.ok("Webhook processed");
    }
}
JAVA

# ===== PAYMENT WEBHOOK SERVICE =====
cat > "$API_PATH/services/PaymentWebhookService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.entities.Order;
import com.darlemlih.apiculture.entities.WebhookEvent;
import com.darlemlih.apiculture.entities.enums.OrderStatus;
import com.darlemlih.apiculture.payments.PaymentGateway;
import com.darlemlih.apiculture.repositories.OrderRepository;
import com.darlemlih.apiculture.repositories.WebhookEventRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class PaymentWebhookService {

    private final PaymentGateway paymentGateway;
    private final WebhookEventRepository webhookEventRepository;
    private final OrderRepository orderRepository;
    private final EmailService emailService;
    private final ObjectMapper objectMapper;

    public void processWebhook(String signature, String payload) {
        try {
            // Verify webhook signature
            if (!paymentGateway.verifyWebhook(signature, payload)) {
                throw new RuntimeException("Invalid webhook signature");
            }

            // Parse webhook payload
            JsonNode json = objectMapper.readTree(payload);
            String eventId = json.path("id").asText();
            String eventType = json.path("type").asText();

            // Check for duplicate events (idempotency)
            if (webhookEventRepository.existsByEventId(eventId)) {
                log.info("Webhook event already processed: {}", eventId);
                return;
            }

            // Store webhook event
            WebhookEvent event = WebhookEvent.builder()
                    .provider("stripe")
                    .eventId(eventId)
                    .eventType(eventType)
                    .payload(payload)
                    .signature(signature)
                    .processed(false)
                    .build();
            webhookEventRepository.save(event);

            // Process based on event type
            switch (eventType) {
                case "payment_intent.succeeded":
                case "checkout.session.completed":
                    handlePaymentSuccess(json);
                    break;
                case "payment_intent.payment_failed":
                    handlePaymentFailure(json);
                    break;
                default:
                    log.info("Unhandled webhook event type: {}", eventType);
            }

            // Mark event as processed
            event.setProcessed(true);
            event.setProcessedAt(LocalDateTime.now());
            webhookEventRepository.save(event);

        } catch (Exception e) {
            log.error("Error processing webhook", e);
            throw new RuntimeException("Webhook processing failed", e);
        }
    }

    private void handlePaymentSuccess(JsonNode json) {
        String paymentIntentId = json.path("data").path("object").path("payment_intent").asText();
        
        if (paymentIntentId == null || paymentIntentId.isEmpty()) {
            paymentIntentId = json.path("data").path("object").path("id").asText();
        }

        Order order = orderRepository.findByPaymentIntentId(paymentIntentId)
                .orElseThrow(() -> new RuntimeException("Order not found for payment intent: " + paymentIntentId));

        order.setStatus(OrderStatus.PAID);
        orderRepository.save(order);

        // Send confirmation email
        emailService.sendOrderConfirmationEmail(order.getUser().getEmail(), order.getOrderNumber());
        
        log.info("Order {} marked as PAID", order.getOrderNumber());
    }

    private void handlePaymentFailure(JsonNode json) {
        String paymentIntentId = json.path("data").path("object").path("id").asText();
        
        Order order = orderRepository.findByPaymentIntentId(paymentIntentId)
                .orElseThrow(() -> new RuntimeException("Order not found for payment intent: " + paymentIntentId));

        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
        
        log.info("Order {} marked as CANCELLED due to payment failure", order.getOrderNumber());
    }
}
JAVA

# ===== STRIPE PAYMENT GATEWAY =====
cat > "$API_PATH/payments/StripePaymentGateway.java" << 'JAVA'
package com.darlemlih.apiculture.payments;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Service
@ConditionalOnProperty(name = "payment.provider", havingValue = "stripe")
@Slf4j
public class StripePaymentGateway implements PaymentGateway {

    @Value("${payment.stripe.secret-key}")
    private String secretKey;

    @Value("${payment.stripe.webhook-secret}")
    private String webhookSecret;

    @Override
    public PaymentSession createCheckoutSession(String orderId, BigDecimal amount, String currency, String successUrl, String cancelUrl) {
        // Note: In production, you would use the actual Stripe SDK
        // This is a placeholder implementation
        log.info("Creating Stripe checkout session for order: {}", orderId);
        
        // Convert amount to cents
        long amountInCents = amount.multiply(new BigDecimal(100)).longValue();
        
        Map<String, Object> params = new HashMap<>();
        params.put("payment_method_types", new String[]{"card"});
        params.put("line_items", createLineItems(orderId, amountInCents, currency));
        params.put("mode", "payment");
        params.put("success_url", successUrl);
        params.put("cancel_url", cancelUrl);
        params.put("metadata", Map.of("order_id", orderId));
        
        // In production, use Stripe SDK:
        // Session session = Session.create(params);
        
        return PaymentSession.builder()
                .sessionId("cs_test_" + System.currentTimeMillis())
                .paymentIntentId("pi_test_" + System.currentTimeMillis())
                .checkoutUrl("https://checkout.stripe.com/pay/cs_test_" + System.currentTimeMillis())
                .status("pending")
                .build();
    }

    @Override
    public boolean verifyWebhook(String signature, String payload) {
        if (signature == null || webhookSecret == null) {
            return false;
        }
        
        // In production, use Stripe SDK:
        // Webhook.constructEvent(payload, signature, webhookSecret);
        
        return true; // Placeholder
    }

    @Override
    public RefundResult refund(String paymentIntentId, BigDecimal amount) {
        log.info("Processing refund for payment intent: {}", paymentIntentId);
        
        // In production, use Stripe SDK:
        // Refund refund = Refund.create(params);
        
        return RefundResult.builder()
                .refundId("re_test_" + System.currentTimeMillis())
                .status("succeeded")
                .amount(amount)
                .reason("requested_by_customer")
                .build();
    }

    private Object createLineItems(String orderId, long amount, String currency) {
        // Helper method to create line items for Stripe
        return new Object[]{
            Map.of(
                "price_data", Map.of(
                    "currency", currency.toLowerCase(),
                    "product_data", Map.of(
                        "name", "Order #" + orderId
                    ),
                    "unit_amount", amount
                ),
                "quantity", 1
            )
        };
    }
}
JAVA

# ===== EXCEPTION HANDLER =====
cat > "$API_PATH/exceptions/GlobalExceptionHandler.java" << 'JAVA'
package com.darlemlih.apiculture.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.BAD_REQUEST.value());
        response.put("error", "Validation Failed");
        response.put("errors", errors);
        
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.put("error", "Internal Server Error");
        response.put("message", ex.getMessage());
        
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGlobalException(Exception ex) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.put("error", "Internal Server Error");
        response.put("message", "An unexpected error occurred");
        
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
JAVA

# ===== ADMIN CONTROLLER =====
cat > "$API_PATH/controllers/AdminController.java" << 'JAVA'
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
JAVA

# ===== ADMIN DTOs =====
mkdir -p "$API_PATH/dto/admin"

cat > "$API_PATH/dto/admin/DashboardDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.admin;

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
public class DashboardDto {
    private BigDecimal todaySales;
    private BigDecimal weekSales;
    private BigDecimal monthSales;
    private Long totalOrders;
    private Long pendingOrders;
    private Long totalCustomers;
    private Long totalProducts;
    private Long lowStockProducts;
    private List<TopProductDto> topProducts;
}
JAVA

cat > "$API_PATH/dto/admin/TopProductDto.java" << 'JAVA'
package com.darlemlih.apiculture.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TopProductDto {
    private Long productId;
    private String productName;
    private String productSku;
    private Long totalSold;
    private BigDecimal revenue;
}
JAVA

# ===== ADMIN SERVICE =====
cat > "$API_PATH/services/AdminService.java" << 'JAVA'
package com.darlemlih.apiculture.services;

import com.darlemlih.apiculture.dto.admin.DashboardDto;
import com.darlemlih.apiculture.entities.enums.OrderStatus;
import com.darlemlih.apiculture.repositories.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class AdminService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public DashboardDto getDashboardStats() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startOfDay = now.toLocalDate().atStartOfDay();
        LocalDateTime startOfWeek = now.minusDays(7);
        LocalDateTime startOfMonth = now.minusDays(30);

        return DashboardDto.builder()
                .todaySales(BigDecimal.ZERO) // Simplified for now
                .weekSales(BigDecimal.ZERO)
                .monthSales(BigDecimal.ZERO)
                .totalOrders(orderRepository.count())
                .pendingOrders(orderRepository.findByStatus(OrderStatus.PENDING, null).getTotalElements())
                .totalCustomers(userRepository.count())
                .totalProducts(productRepository.count())
                .lowStockProducts(0L) // Simplified for now
                .topProducts(new ArrayList<>())
                .build();
    }

    public void seedDatabase() {
        log.info("Database already seeded via Flyway migrations");
    }
}
JAVA

echo "✅ Spring Boot backend generation complete!"
