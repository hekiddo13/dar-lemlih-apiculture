package com.darlemlih.apiculture.services;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.web-base-url}")
    private String webBaseUrl;

    public void sendPasswordResetEmail(String to, String token) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(to);
        message.setSubject("Réinitialisation de votre mot de passe - Dar Lemlih Apiculture");
        message.setText("Bonjour,\n\n" +
                "Vous avez demandé la réinitialisation de votre mot de passe.\n" +
                "Cliquez sur le lien suivant pour réinitialiser votre mot de passe:\n" +
                webBaseUrl + "/reset-password?token=" + token + "\n\n" +
                "Ce lien expirera dans 24 heures.\n\n" +
                "Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.\n\n" +
                "Cordialement,\n" +
                "L'équipe Dar Lemlih Apiculture");
        
        mailSender.send(message);
    }

    public void sendOrderConfirmationEmail(String to, String orderNumber) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(to);
        message.setSubject("Confirmation de commande #" + orderNumber + " - Dar Lemlih Apiculture");
        message.setText("Bonjour,\n\n" +
                "Merci pour votre commande!\n\n" +
                "Votre commande #" + orderNumber + " a été confirmée et sera bientôt expédiée.\n" +
                "Vous pouvez suivre votre commande sur: " + webBaseUrl + "/orders/" + orderNumber + "\n\n" +
                "Cordialement,\n" +
                "L'équipe Dar Lemlih Apiculture");
        
        mailSender.send(message);
    }
}
