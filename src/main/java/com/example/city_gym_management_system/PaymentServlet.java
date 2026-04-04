package com.example.city_gym_management_system;

import com.example.city_gym_management_system.util.AuthUtil;
import com.example.city_gym_management_system.util.BackendApiService;
import com.example.city_gym_management_system.util.WhatsAppService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        moveFlashMessage(request);

        String searchTerm = request.getParameter("memberName");
        String memberId = request.getParameter("memberId");
        BackendApiService backendApi = new BackendApiService(getServletContext());

        try {
            if (memberId != null && !memberId.isBlank()) {
                JsonObject member = backendApi.getObject("/api/members/" + BackendApiService.encode(memberId));
                request.setAttribute("selectedMember", member);
                request.setAttribute("paymentHistory", member.has("paymentHistory") ? member.getAsJsonArray("paymentHistory") : new JsonArray());
                request.setAttribute("memberStatus", calculateStatus(getString(member, "expiryDate")));
            }

            if (searchTerm != null && !searchTerm.isBlank()) {
                JsonArray matches = backendApi.getArray("/api/members?name=" + BackendApiService.encode(searchTerm));
                request.setAttribute("searchResults", matches);
            } else {
                request.setAttribute("searchResults", new JsonArray());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Payment view loading interrupted.");
            request.setAttribute("searchResults", new JsonArray());
            request.setAttribute("paymentHistory", new JsonArray());
        } catch (Exception e) {
            request.setAttribute("error", "Unable to load payment information right now.");
            request.setAttribute("searchResults", new JsonArray());
            request.setAttribute("paymentHistory", new JsonArray());
        }

        request.getRequestDispatcher("payments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        String memberId = request.getParameter("memberId");
        String amount = request.getParameter("paymentAmount");
        String paymentMethod = request.getParameter("paymentMethod");
        String planDuration = request.getParameter("newPlanDuration");

        BackendApiService backendApi = new BackendApiService(getServletContext());
        WhatsAppService whatsAppService = new WhatsAppService(getServletContext());

        try {
            JsonObject member = backendApi.getObject("/api/members/" + BackendApiService.encode(memberId));
            LocalDate currentExpiry = LocalDate.parse(getString(member, "expiryDate"));
            LocalDate newExpiry = extendExpiry(currentExpiry, planDuration);

            JsonObject paymentPayload = new JsonObject();
            paymentPayload.addProperty("paymentAmount", amount);
            paymentPayload.addProperty("paymentMethod", paymentMethod);
            paymentPayload.addProperty("newPlanDuration", planDuration);
            paymentPayload.addProperty("expiryDate", newExpiry.toString());

            backendApi.putJson("/api/members/" + BackendApiService.encode(memberId), paymentPayload);

            String message = whatsAppService.paymentConfirmationMessage(
                    getString(member, "name"),
                    formatPlanLabel(planDuration),
                    newExpiry.toString()
            );
            boolean sent = whatsAppService.sendMessage(getString(member, "whatsappNumber"), message);

            request.getSession().setAttribute("successMessage", "Payment recorded successfully.");
            if (!sent) {
                request.getSession().setAttribute("whatsappError", "Payment was recorded, but WhatsApp message could not be sent.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.getSession().setAttribute("error", "Payment operation interrupted.");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Payment operation failed: " + e.getMessage());
        }

        response.sendRedirect("payments?memberId=" + BackendApiService.encode(memberId));
    }

    private void moveFlashMessage(HttpServletRequest request) {
        Object success = request.getSession().getAttribute("successMessage");
        Object error = request.getSession().getAttribute("error");
        Object whatsappError = request.getSession().getAttribute("whatsappError");

        if (success != null) {
            request.setAttribute("successMessage", success);
            request.getSession().removeAttribute("successMessage");
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.getSession().removeAttribute("error");
        }
        if (whatsappError != null) {
            request.setAttribute("whatsappError", whatsappError);
            request.getSession().removeAttribute("whatsappError");
        }
    }

    private LocalDate extendExpiry(LocalDate currentExpiry, String duration) {
        LocalDate baseDate = currentExpiry.isBefore(LocalDate.now()) ? LocalDate.now() : currentExpiry;
        if ("3_MONTHS".equals(duration)) {
            return baseDate.plusMonths(3);
        }
        if ("6_MONTHS".equals(duration)) {
            return baseDate.plusMonths(6);
        }
        if ("1_YEAR".equals(duration)) {
            return baseDate.plusYears(1);
        }
        return baseDate.plusMonths(1);
    }

    private String formatPlanLabel(String duration) {
        if ("3_MONTHS".equals(duration)) {
            return "3 Months";
        }
        if ("6_MONTHS".equals(duration)) {
            return "6 Months";
        }
        if ("1_YEAR".equals(duration)) {
            return "1 Year";
        }
        return "1 Month";
    }

    private String calculateStatus(String expiryDateRaw) {
        if (expiryDateRaw == null || expiryDateRaw.isBlank()) {
            return "EXPIRED";
        }

        LocalDate expiryDate = LocalDate.parse(expiryDateRaw);
        if (expiryDate.isBefore(LocalDate.now())) {
            return "EXPIRED";
        }
        if (!expiryDate.isAfter(LocalDate.now().plusDays(3))) {
            return "EXPIRING_SOON";
        }
        return "ACTIVE";
    }

    private String getString(JsonObject obj, String key) {
        return obj.has(key) && !obj.get(key).isJsonNull() ? obj.get(key).getAsString() : "";
    }
}

