#!/bin/bash

# Create all entity files
API_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/api/src/main/java/com/darlemlih/apiculture"

# Base Entity
cat > "$API_PATH/entities/BaseEntity.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@MappedSuperclass
@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
JAVA

# User Entity
cat > "$API_PATH/entities/User.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import com.darlemlih.apiculture.entities.enums.UserRole;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.*;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity implements UserDetails {
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private String phone;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role = UserRole.CUSTOMER;
    
    @Column(nullable = false)
    private Boolean enabled = true;
    
    @Column(nullable = false)
    private Boolean emailVerified = false;
    
    private String resetPasswordToken;
    
    private LocalDateTime resetPasswordTokenExpiry;
    
    private String refreshToken;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Address> addresses = new ArrayList<>();
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
    
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Cart cart;
    
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
    
    @Override
    public String getUsername() {
        return email;
    }
    
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }
    
    @Override
    public boolean isAccountNonLocked() {
        return enabled;
    }
    
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }
    
    @Override
    public boolean isEnabled() {
        return enabled;
    }
}
JAVA

# UserRole Enum
mkdir -p "$API_PATH/entities/enums"
cat > "$API_PATH/entities/enums/UserRole.java" << 'JAVA'
package com.darlemlih.apiculture.entities.enums;

public enum UserRole {
    CUSTOMER,
    ADMIN
}
JAVA

# Category Entity
cat > "$API_PATH/entities/Category.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category extends BaseEntity {
    
    @Column(nullable = false, unique = true)
    private String slug;
    
    @Column(nullable = false)
    private String nameFr;
    
    @Column(nullable = false)
    private String nameEn;
    
    @Column(nullable = false)
    private String nameAr;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionFr;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionEn;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionAr;
    
    private String image;
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    private Integer displayOrder = 0;
    
    @OneToMany(mappedBy = "category", fetch = FetchType.LAZY)
    private List<Product> products = new ArrayList<>();
}
JAVA

# Product Entity
cat > "$API_PATH/entities/Product.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {
    
    @Column(nullable = false, unique = true)
    private String sku;
    
    @Column(nullable = false, unique = true)
    private String slug;
    
    @Column(nullable = false)
    private String nameFr;
    
    @Column(nullable = false)
    private String nameEn;
    
    @Column(nullable = false)
    private String nameAr;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionFr;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionEn;
    
    @Column(columnDefinition = "TEXT")
    private String descriptionAr;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;
    
    @Column(nullable = false)
    private String currency = "MAD";
    
    @Column(nullable = false)
    private Integer stockQuantity = 0;
    
    private Integer weightGrams;
    
    @Column(columnDefinition = "TEXT")
    private String ingredients;
    
    private String origin;
    
    @Column(nullable = false)
    private Boolean isHalal = true;
    
    @Column(nullable = false)
    private Boolean isActive = true;
    
    @Column(nullable = false)
    private Boolean isFeatured = false;
    
    @ElementCollection
    @CollectionTable(name = "product_images", joinColumns = @JoinColumn(name = "product_id"))
    @Column(name = "image_url")
    private List<String> images = new ArrayList<>();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;
    
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<CartItem> cartItems = new ArrayList<>();
    
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<OrderItem> orderItems = new ArrayList<>();
}
JAVA

# Address Entity
cat > "$API_PATH/entities/Address.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "addresses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Address extends BaseEntity {
    
    @Column(nullable = false)
    private String line1;
    
    private String line2;
    
    @Column(nullable = false)
    private String city;
    
    @Column(nullable = false)
    private String region;
    
    @Column(nullable = false)
    private String postalCode;
    
    @Column(nullable = false)
    private String country = "Morocco";
    
    @Column(nullable = false)
    private Boolean isDefault = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
JAVA

# Cart Entity
cat > "$API_PATH/entities/Cart.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "carts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Cart extends BaseEntity {
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", unique = true)
    private User user;
    
    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<CartItem> items = new ArrayList<>();
    
    private String sessionId; // For anonymous users
    
    public BigDecimal getTotal() {
        return items.stream()
                .map(item -> item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    public int getTotalItems() {
        return items.stream()
                .mapToInt(CartItem::getQuantity)
                .sum();
    }
}
JAVA

# CartItem Entity
cat > "$API_PATH/entities/CartItem.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "cart_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CartItem extends BaseEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;
    
    @Column(nullable = false)
    private Integer quantity = 1;
}
JAVA

# Order Entity
cat > "$API_PATH/entities/Order.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import com.darlemlih.apiculture.entities.enums.OrderStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order extends BaseEntity {
    
    @Column(nullable = false, unique = true)
    private String orderNumber;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status = OrderStatus.PENDING;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal shippingCost;
    
    @Column(precision = 10, scale = 2)
    private BigDecimal discount = BigDecimal.ZERO;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal total;
    
    @Column(nullable = false)
    private String currency = "MAD";
    
    private String paymentProvider;
    
    private String paymentIntentId;
    
    private String trackingNumber;
    
    @Embedded
    private ShippingAddress shippingAddress;
    
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<OrderItem> items = new ArrayList<>();
}
JAVA

# OrderStatus Enum
cat > "$API_PATH/entities/enums/OrderStatus.java" << 'JAVA'
package com.darlemlih.apiculture.entities.enums;

public enum OrderStatus {
    PENDING,
    CONFIRMED,
    PAID,
    PROCESSING,
    SHIPPED,
    DELIVERED,
    COMPLETED,
    CANCELLED,
    REFUNDED
}
JAVA

# ShippingAddress Embeddable
cat > "$API_PATH/entities/ShippingAddress.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShippingAddress {
    
    @Column(name = "shipping_name")
    private String name;
    
    @Column(name = "shipping_phone")
    private String phone;
    
    @Column(name = "shipping_line1")
    private String line1;
    
    @Column(name = "shipping_line2")
    private String line2;
    
    @Column(name = "shipping_city")
    private String city;
    
    @Column(name = "shipping_region")
    private String region;
    
    @Column(name = "shipping_postal_code")
    private String postalCode;
    
    @Column(name = "shipping_country")
    private String country;
}
JAVA

# OrderItem Entity
cat > "$API_PATH/entities/OrderItem.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem extends BaseEntity {
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;
    
    @Column(nullable = false)
    private Integer quantity;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;
}
JAVA

# WebhookEvent Entity
cat > "$API_PATH/entities/WebhookEvent.java" << 'JAVA'
package com.darlemlih.apiculture.entities;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "webhook_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WebhookEvent extends BaseEntity {
    
    @Column(nullable = false)
    private String provider;
    
    @Column(nullable = false, unique = true)
    private String eventId;
    
    @Column(nullable = false)
    private String eventType;
    
    @Column(columnDefinition = "TEXT", nullable = false)
    private String payload;
    
    private String signature;
    
    @Column(nullable = false)
    private Boolean processed = false;
    
    private LocalDateTime processedAt;
    
    @Column(columnDefinition = "TEXT")
    private String error;
}
JAVA

echo "Entities created successfully!"
