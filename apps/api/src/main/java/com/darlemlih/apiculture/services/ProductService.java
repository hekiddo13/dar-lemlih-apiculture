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
