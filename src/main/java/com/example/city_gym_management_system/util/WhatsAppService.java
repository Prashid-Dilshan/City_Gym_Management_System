package com.example.city_gym_management_system.util;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletContext;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class WhatsAppService {

    private final HttpClient client;
    private final String token;
    private final String phoneNumberId;
    private final Gson gson;

    public WhatsAppService(ServletContext context) {
        this.client = HttpClient.newHttpClient();
        this.token = valueOrEmpty(context.getInitParameter("whatsapp.token"));
        this.phoneNumberId = valueOrEmpty(context.getInitParameter("whatsapp.phone_number_id"));
        this.gson = new Gson();
    }

    public boolean sendMessage(String toNumber, String messageBody) {
        if (token.isBlank() || phoneNumberId.isBlank()) {
            System.err.println("WhatsApp config missing: token or phone_number_id is blank");
            return false;
        }

        JsonObject payload = new JsonObject();
        payload.addProperty("messaging_product", "whatsapp");
        payload.addProperty("to", sanitizePhoneNumber(toNumber));
        payload.addProperty("type", "text");

        JsonObject textNode = new JsonObject();
        textNode.addProperty("body", messageBody);
        payload.add("text", textNode);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://graph.facebook.com/v18.0/" + phoneNumberId + "/messages"))
                .header("Authorization", "Bearer " + token)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(payload)))
                .build();

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                return true;
            }
            System.err.println("WhatsApp API error: status=" + response.statusCode() + " body=" + response.body());
            return false;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("WhatsApp API call interrupted: " + e.getMessage());
            return false;
        } catch (IOException e) {
            System.err.println("WhatsApp API call failed: " + e.getMessage());
            return false;
        }
    }

    public String paymentConfirmationMessage(String memberName, String planName, String expiryDate) {
        return "Hi " + memberName + "! \uD83C\uDFCB\uFE0F\n"
                + "Your City GYM Hambantota membership has been renewed.\n"
                + "\u2705 Plan: " + planName + "\n"
                + "\uD83D\uDCC5 Valid Until: " + expiryDate + "\n"
                + "Thank you!\n"
                + "- City GYM Hambantota";
    }

    public String expiryReminderMessage(String memberName, String expiryDate) {
        return "Hi " + memberName + "! \u23F0\n"
                + "Your City GYM Hambantota membership expires on " + expiryDate + ".\n"
                + "Please renew to keep your access.\n"
                + "- City GYM Hambantota";
    }

    private String sanitizePhoneNumber(String input) {
        return input == null ? "" : input.replaceAll("[^0-9]", "");
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
