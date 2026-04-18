package com.example.city_gym_management_system;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;

/**
 * WhatsApp Messaging Service using Twilio
 * Handles sending WhatsApp messages for:
 * - Payment receipts
 * - Membership expiry warnings
 * - Expired membership notifications
 * - Birthday wishes
 * 
 * ⚠️ IMPORTANT: Set environment variables before running:
 * - TWILIO_ACCOUNT_SID
 * - TWILIO_AUTH_TOKEN
 */
public class WhatsAppService {

    // Twilio WhatsApp Sandbox number (provided by Twilio)
    private static final String TWILIO_WHATSAPP_NUMBER = "whatsapp:+14155238886";
    
    // Initialize Twilio with credentials from environment variables
    static {
        try {
            String accountSid = System.getenv("TWILIO_ACCOUNT_SID");
            String authToken = System.getenv("TWILIO_AUTH_TOKEN");
            
            // Validate credentials are set
            if (accountSid == null || authToken == null || accountSid.isEmpty() || authToken.isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Twilio credentials not found in environment variables!");
                System.err.println("[WHATSAPP ERROR] Please set TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN");
            } else {
                Twilio.init(accountSid, authToken);
                System.out.println("[WHATSAPP] Twilio initialized successfully");
            }
        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to initialize Twilio: " + e.getMessage());
        }
    }

    /**
     * Send a WhatsApp message to a member
     * 
     * @param phoneNumber Member's WhatsApp number (format: +947XXXXXXXX for Pakistan)
     * @param messageText The message to send
     * @return true if message sent successfully, false otherwise
     */
    public static boolean sendMessage(String phoneNumber, String messageText) {
        try {
            // ✅ Validate inputs
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Phone number is null or empty");
                return false;
            }

            if (messageText == null || messageText.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Message text is null or empty");
                return false;
            }

            // ✅ Ensure phone number has WhatsApp prefix
            String formattedPhone = phoneNumber.trim();
            if (!formattedPhone.startsWith("whatsapp:")) {
                // Add whatsapp: prefix if not present
                if (formattedPhone.startsWith("+")) {
                    formattedPhone = "whatsapp:" + formattedPhone;
                } else if (formattedPhone.startsWith("92")) {
                    // Handle Pakistan number without +
                    formattedPhone = "whatsapp:+" + formattedPhone;
                } else {
                    formattedPhone = "whatsapp:+" + formattedPhone;
                }
            }

            // ✅ Send message using Twilio
            Message message = Message.creator(
                    new PhoneNumber(formattedPhone),        // To number (WhatsApp)
                    new PhoneNumber(TWILIO_WHATSAPP_NUMBER), // From number (Twilio WhatsApp Sandbox)
                    messageText                              // Message content
            ).create();

            // ✅ Log success
            System.out.println("[WHATSAPP SUCCESS] Message sent to: " + formattedPhone);
            System.out.println("[WHATSAPP SUCCESS] Message SID: " + message.getSid());
            System.out.println("[WHATSAPP SUCCESS] Status: " + message.getStatus());
            
            return true;

        } catch (Exception e) {
            // ❌ Log failure
            System.err.println("[WHATSAPP ERROR] Failed to send message to " + phoneNumber);
            System.err.println("[WHATSAPP ERROR] Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Send payment receipt to member
     * 
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @param amount Amount paid
     * @param membershipMonths Membership duration in months
     * @return true if sent successfully
     */
    public static boolean sendPaymentReceipt(String memberName, String phoneNumber, double amount, int membershipMonths) {
        try {
            // ✅ Validate inputs
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            // ✅ Format message with member details
            String messageText = String.format(
                "🎉 *Payment Receipt* 🎉\n\n" +
                "Hello %s,\n\n" +
                "Your payment has been received successfully! 💰\n\n" +
                "📋 *Payment Details:*\n" +
                "• Amount: Rs. %.2f\n" +
                "• Membership: %d months\n\n" +
                "Thank you for being part of City Gym! 💪\n" +
                "Stay fit, stay healthy! 🏋️",
                memberName, amount, membershipMonths
            );

            return sendMessage(phoneNumber, messageText);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send payment receipt: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send membership expiry warning (7 days before expiration)
     * 
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @param expiryDate Membership expiry date (e.g., "2026-04-20")
     * @return true if sent successfully
     */
    public static boolean sendExpiryWarning(String memberName, String phoneNumber, String expiryDate) {
        try {
            // ✅ Validate inputs
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            // ✅ Format warning message
            String messageText = String.format(
                "⏰ *Membership Expiry Alert* ⏰\n\n" +
                "Hi %s,\n\n" +
                "Your gym membership is expiring soon! 📅\n\n" +
                "📋 *Renewal Details:*\n" +
                "• Expiry Date: %s\n" +
                "• Status: Expiring in 7 days ⚠️\n\n" +
                "👉 Please renew your membership to continue enjoying\n" +
                "our facilities!\n\n" +
                "Contact us at City Gym for renewal. 💪",
                memberName, expiryDate
            );

            return sendMessage(phoneNumber, messageText);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send expiry warning: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send membership expired notification
     * 
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @return true if sent successfully
     */
    public static boolean sendExpiredNotification(String memberName, String phoneNumber) {
        try {
            // ✅ Validate inputs
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            // ✅ Format expired message
            String messageText = String.format(
                "❌ *Membership Expired* ❌\n\n" +
                "Hi %s,\n\n" +
                "Your gym membership has expired. 😢\n\n" +
                "📋 *Next Steps:*\n" +
                "• Renew your membership to regain access\n" +
                "• Contact City Gym for special renewal offers\n" +
                "• We miss you! Come back soon 💪\n\n" +
                "Tap to renew or call us for details.",
                memberName
            );

            return sendMessage(phoneNumber, messageText);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send expired notification: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send birthday wish to member
     * 
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @return true if sent successfully
     */
    public static boolean sendBirthdayWish(String memberName, String phoneNumber) {
        try {
            // ✅ Validate inputs
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            // ✅ Format birthday message
            String messageText = String.format(
                "🎂 *Happy Birthday!* 🎂\n\n" +
                "Dearest %s,\n\n" +
                "🎉 Wishing you a fantastic birthday!\n\n" +
                "Thank you for being part of the City Gym family! 💪\n\n" +
                "💝 *Special Birthday Offer:*\n" +
                "• Get 10%% off on renewal\n" +
                "• Free personal training session\n" +
                "• Birthday month free locker facility\n\n" +
                "Visit us today to claim your gifts! 🏋️\n" +
                "Have an amazing day! 🥳",
                memberName
            );

            return sendMessage(phoneNumber, messageText);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send birthday wish: " + e.getMessage());
            return false;
        }
    }
}

