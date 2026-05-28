package com.example.city_gym_management_system;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.api.v2010.account.MessageCreator;
import com.twilio.type.PhoneNumber;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * WhatsApp Messaging Service using Twilio
 * Handles sending WhatsApp messages for:
 * - Payment receipts
 * - Payment reminders (3 days before expiry)
 * - Expired membership notifications
 * - Birthday wishes
 *
 * ⚠️ IMPORTANT: Set environment variables before running:
 * - TWILIO_ACCOUNT_SID
 * - TWILIO_AUTH_TOKEN
 */
public class WhatsAppService {

    // Set this in production to your WhatsApp-enabled Twilio sender number.
    // The sandbox number is kept as a local fallback so development still works.
    private static final String DEFAULT_TWILIO_WHATSAPP_NUMBER = "whatsapp:+14155238886";

    // Template SIDs are optional during development. When they are set, the app sends
    // approved WhatsApp templates for proactive messages.
    private static final String TEMPLATE_WELCOME = "TWILIO_WHATSAPP_TEMPLATE_WELCOME";
    private static final String TEMPLATE_PAYMENT_RECEIPT = "TWILIO_WHATSAPP_TEMPLATE_PAYMENT_RECEIPT";
    private static final String TEMPLATE_PAYMENT_REMINDER = "TWILIO_WHATSAPP_TEMPLATE_PAYMENT_REMINDER";
    private static final String TEMPLATE_MEMBERSHIP_EXPIRED = "TWILIO_WHATSAPP_TEMPLATE_MEMBERSHIP_EXPIRED";
    private static final String TEMPLATE_BIRTHDAY_WISH = "TWILIO_WHATSAPP_TEMPLATE_BIRTHDAY_WISH";
    private static final String TWILIO_MESSAGING_SERVICE_SID = "TWILIO_MESSAGING_SERVICE_SID";

    private static volatile boolean twilioReady = false;

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
                twilioReady = true;
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
            if (!twilioReady) {
                System.err.println("[WHATSAPP ERROR] Twilio is not initialized. Check environment variables.");
                return false;
            }

            // ✅ Validate inputs
            if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Phone number is null or empty");
                return false;
            }

            if (messageText == null || messageText.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Message text is null or empty");
                return false;
            }

            // ✅ Ensure phone number is clean and formatted for WhatsApp
            String formattedPhone = normalizeWhatsAppNumber(phoneNumber);
            if (formattedPhone == null) {
                System.err.println("[WHATSAPP ERROR] Invalid phone number format: " + phoneNumber);
                return false;
            }

            // ✅ Send message using Twilio
            Message message = Message.creator(
                    new PhoneNumber(formattedPhone),        // To number (WhatsApp)
                    new PhoneNumber(getTwilioWhatsAppNumber()), // From number (sandbox or paid sender)
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
     * Send the welcome message after member registration.
     */
    public static boolean sendWelcomeMessage(String memberName, String phoneNumber) {
        try {
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            String fallbackText = String.format(
                    "*Welcome to City Gym*\n\nHello %s,\nYour member profile has been created successfully.\n\nWe are happy to have you with us.",
                    memberName
            );

            Map<String, String> variables = new LinkedHashMap<>();
            variables.put("1", memberName);

            return sendTemplateOrFallback(phoneNumber, TEMPLATE_WELCOME, fallbackText, variables);
        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send welcome message: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send payment receipt to member.
     * Backward-compatible wrapper that omits period dates.
     */
    public static boolean sendPaymentReceipt(String memberName, String phoneNumber, double amount, int membershipMonths) {
        return sendPaymentReceipt(memberName, phoneNumber, amount, membershipMonths, null, null);
    }

    /**
     * Send payment receipt to member.
     *
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @param amount Amount paid
     * @param membershipMonths Membership duration in months
     * @param startDate Membership start date (YYYY-MM-DD)
     * @param endDate Membership end date (YYYY-MM-DD)
     * @return true if sent successfully
     */
    public static boolean sendPaymentReceipt(
            String memberName,
            String phoneNumber,
            double amount,
            int membershipMonths,
            String startDate,
            String endDate) {
        try {
            // ✅ Validate inputs
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            String safeStartDate = (startDate == null || startDate.trim().isEmpty()) ? "-" : startDate.trim();
            String safeEndDate = (endDate == null || endDate.trim().isEmpty()) ? "-" : endDate.trim();

            String fallbackText = String.format(
                    "*City Gym - Payment Receipt*\n\n" +
                            "Hello %s,\n\n" +
                            "We have received your membership payment successfully.\n\n" +
                            "*Payment Details*\n" +
                            "- Amount: Rs. %.2f\n" +
                            "- Package: %d month(s)\n" +
                            "- Start Date: %s\n" +
                            "- End Date: %s\n\n" +
                            "Thank you for training with City Gym.",
                    memberName, amount, membershipMonths, safeStartDate, safeEndDate
            );

            Map<String, String> variables = new LinkedHashMap<>();
            variables.put("1", memberName);
            variables.put("2", String.format("%.2f", amount));
            variables.put("3", String.valueOf(membershipMonths));
            variables.put("4", safeStartDate);
            variables.put("5", safeEndDate);

            return sendTemplateOrFallback(phoneNumber, TEMPLATE_PAYMENT_RECEIPT, fallbackText, variables);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send payment receipt: " + e.getMessage());
            return false;
        }
    }

    /**
     * Send payment reminder before membership expires.
     * This is the only pre-expiry alert so billing stays simple and low-cost.
     *
     * @param memberName Member's name
     * @param phoneNumber Member's WhatsApp number
     * @param dueDate Membership due date (e.g., "2026-04-20")
     * @return true if sent successfully
     */
    public static boolean sendPaymentReminder(String memberName, String phoneNumber, String dueDate) {
        try {
            if (memberName == null || memberName.trim().isEmpty()) {
                System.err.println("[WHATSAPP ERROR] Member name is null or empty");
                return false;
            }

            String fallbackText = String.format(
                    "*City Gym - Renewal Reminder*\n\n" +
                            "Hi %s,\n\n" +
                            "Your membership is due for renewal on %s.\n" +
                            "Please complete the payment before this date to keep your access active.\n\n" +
                            "For assistance, contact City Gym Fitness:\n" +
                            "0701234717 - Coach M.F",
                    memberName, dueDate
            );

            Map<String, String> variables = new LinkedHashMap<>();
            variables.put("1", memberName);
            variables.put("2", dueDate);

            return sendTemplateOrFallback(phoneNumber, TEMPLATE_PAYMENT_REMINDER, fallbackText, variables);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send payment reminder: " + e.getMessage());
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

            String fallbackText = String.format(
                    "*City Gym - Membership Expired*\n\n" +
                            "Hi %s,\n\n" +
                            "Your membership has expired.\n" +
                            "Please renew your package to continue using gym services.\n\n" +
                            "We look forward to seeing you back at City Gym.\n\n" +
                            "For assistance, contact City Gym Fitness:\n" +
                            "0701234717 - Coach M.F",
                    memberName
            );

            Map<String, String> variables = new LinkedHashMap<>();
            variables.put("1", memberName);

            return sendTemplateOrFallback(phoneNumber, TEMPLATE_MEMBERSHIP_EXPIRED, fallbackText, variables);

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

            String fallbackText = String.format(
                    "*Happy Birthday from City Gym*\n\n" +
                            "Dear %s,\n\n" +
                            "Wishing you a healthy and joyful birthday.\n" +
                            "Thank you for being a valued member of City Gym.\n\n" +
                            "Have a great year ahead!",
                    memberName
            );

            Map<String, String> variables = new LinkedHashMap<>();
            variables.put("1", memberName);

            return sendTemplateOrFallback(phoneNumber, TEMPLATE_BIRTHDAY_WISH, fallbackText, variables);

        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send birthday wish: " + e.getMessage());
            return false;
        }
    }

    /**
     * Normalize a phone number to Twilio WhatsApp format.
     * Accepts values like:
     * - +947XXXXXXXX
     * - 947XXXXXXXX
     * - whatsapp:+947XXXXXXXX
     *
     * @param phoneNumber raw phone number from DB or form
     * @return formatted WhatsApp number or null if invalid
     */
    private static String normalizeWhatsAppNumber(String phoneNumber) {
        if (phoneNumber == null) {
            return null;
        }

        String cleaned = phoneNumber.trim();
        if (cleaned.isEmpty()) {
            return null;
        }

        if (cleaned.startsWith("whatsapp:")) {
            cleaned = cleaned.substring("whatsapp:".length()).trim();
        }

        // Keep only digits and a leading plus sign.
        cleaned = cleaned.replaceAll("[^0-9+]", "");

        if (cleaned.isEmpty()) {
            return null;
        }

        if (!cleaned.startsWith("+")) {
            cleaned = "+" + cleaned;
        }

        // Twilio WhatsApp requires E.164 style numbers after whatsapp:
        if (!cleaned.matches("\\+[1-9]\\d{7,14}")) {
            return null;
        }

        return "whatsapp:" + cleaned;
    }

    /**
     * Resolve the WhatsApp sender number.
     *
     * In paid Twilio accounts, set TWILIO_WHATSAPP_NUMBER to your approved WhatsApp sender.
     * For local testing, the sandbox number is used if the environment variable is missing.
     */
    private static String getTwilioWhatsAppNumber() {
        String configuredNumber = System.getenv("TWILIO_WHATSAPP_NUMBER");
        if (configuredNumber == null || configuredNumber.trim().isEmpty()) {
            return DEFAULT_TWILIO_WHATSAPP_NUMBER;
        }

        String cleaned = configuredNumber.trim();
        if (!cleaned.startsWith("whatsapp:")) {
            cleaned = "whatsapp:" + cleaned;
        }

        return cleaned;
    }

    private static boolean sendTemplateOrFallback(
            String phoneNumber,
            String templateSidEnvVar,
            String fallbackText,
            Map<String, String> variables) {
        String contentSid = readEnv(templateSidEnvVar);
        String messagingServiceSid = readEnv(TWILIO_MESSAGING_SERVICE_SID);

        if (contentSid == null || messagingServiceSid == null) {
            if (contentSid == null) {
                System.out.println("[WHATSAPP] Template SID not set for " + templateSidEnvVar + ", using fallback text.");
            } else {
                System.out.println("[WHATSAPP] Messaging Service SID not set, using fallback text for template " + templateSidEnvVar + ".");
            }
            return sendMessage(phoneNumber, fallbackText);
        }

        try {
            if (!twilioReady) {
                System.err.println("[WHATSAPP ERROR] Twilio is not initialized. Check environment variables.");
                return false;
            }

            String formattedPhone = normalizeWhatsAppNumber(phoneNumber);
            if (formattedPhone == null) {
                System.err.println("[WHATSAPP ERROR] Invalid phone number format: " + phoneNumber);
                return false;
            }

            MessageCreator creator = Message.creator(
                            new PhoneNumber(formattedPhone),
                            new PhoneNumber(getTwilioWhatsAppNumber()),
                            (String) null
                    )
                    .setMessagingServiceSid(messagingServiceSid)
                    .setContentSid(contentSid)
                    .setContentVariables(toJsonVariables(variables));

            Message message = creator.create();

            System.out.println("[WHATSAPP SUCCESS] Template sent to: " + formattedPhone);
            System.out.println("[WHATSAPP SUCCESS] Template SID: " + contentSid);
            System.out.println("[WHATSAPP SUCCESS] Message SID: " + message.getSid());
            System.out.println("[WHATSAPP SUCCESS] Status: " + message.getStatus());

            return true;
        } catch (Exception e) {
            System.err.println("[WHATSAPP ERROR] Failed to send template " + templateSidEnvVar + ": " + e.getMessage());
            return false;
        }
    }

    private static String readEnv(String name) {
        String value = System.getenv(name);
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static String toJsonVariables(Map<String, String> variables) {
        StringBuilder builder = new StringBuilder("{");
        boolean first = true;

        for (Map.Entry<String, String> entry : variables.entrySet()) {
            if (!first) {
                builder.append(',');
            }
            first = false;
            builder.append('"').append(escapeJson(entry.getKey())).append('"');
            builder.append(':');
            builder.append('"').append(escapeJson(entry.getValue())).append('"');
        }

        builder.append('}');
        return builder.toString();
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '\\' -> builder.append("\\\\");
                case '"' -> builder.append("\\\"");
                case '\b' -> builder.append("\\b");
                case '\f' -> builder.append("\\f");
                case '\n' -> builder.append("\\n");
                case '\r' -> builder.append("\\r");
                case '\t' -> builder.append("\\t");
                default -> builder.append(ch);
            }
        }
        return builder.toString();
    }
}