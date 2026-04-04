package com.example.city_gym_management_system;

import com.example.city_gym_management_system.util.AuthUtil;
import com.example.city_gym_management_system.util.BackendApiService;
import com.example.city_gym_management_system.util.WhatsAppService;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@WebServlet(urlPatterns = {"/alerts", "/alert/send-reminder"})
public class AlertServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        moveFlashMessage(request);

        BackendApiService backendApi = new BackendApiService(getServletContext());
        try {
            JsonArray members = backendApi.getArray("/api/members");
            List<JsonObject> expiringSoon = new ArrayList<>();
            List<JsonObject> expired = new ArrayList<>();

            for (JsonElement element : members) {
                JsonObject member = element.getAsJsonObject();
                LocalDate expiryDate = LocalDate.parse(getString(member, "expiryDate"));
                if (expiryDate.isBefore(LocalDate.now())) {
                    expired.add(member);
                } else if (!expiryDate.isAfter(LocalDate.now().plusDays(7))) {
                    expiringSoon.add(member);
                }
            }

            expiringSoon.sort(Comparator.comparing(o -> LocalDate.parse(getString(o, "expiryDate"))));
            request.setAttribute("expiringSoon", expiringSoon);
            request.setAttribute("expiredMembers", expired);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Alerts loading interrupted.");
            request.setAttribute("expiringSoon", new ArrayList<>());
            request.setAttribute("expiredMembers", new ArrayList<>());
        } catch (Exception e) {
            request.setAttribute("error", "Unable to load alerts right now.");
            request.setAttribute("expiringSoon", new ArrayList<>());
            request.setAttribute("expiredMembers", new ArrayList<>());
        }

        request.getRequestDispatcher("alerts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        String memberId = request.getParameter("memberId");
        BackendApiService backendApi = new BackendApiService(getServletContext());
        WhatsAppService whatsAppService = new WhatsAppService(getServletContext());

        try {
            JsonObject member = backendApi.getObject("/api/members/" + BackendApiService.encode(memberId));
            String message = whatsAppService.expiryReminderMessage(
                    getString(member, "name"),
                    getString(member, "expiryDate")
            );

            boolean sent = whatsAppService.sendMessage(getString(member, "whatsappNumber"), message);
            if (sent) {
                request.getSession().setAttribute("successMessage", "Reminder sent successfully.");
            } else {
                request.getSession().setAttribute("whatsappError", "Could not send reminder via WhatsApp.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.getSession().setAttribute("error", "Reminder operation interrupted.");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Unable to send reminder: " + e.getMessage());
        }

        response.sendRedirect("alerts");
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

    private String getString(JsonObject obj, String key) {
        return obj.has(key) && !obj.get(key).isJsonNull() ? obj.get(key).getAsString() : "";
    }
}
