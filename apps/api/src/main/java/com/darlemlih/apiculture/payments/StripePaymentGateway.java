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
