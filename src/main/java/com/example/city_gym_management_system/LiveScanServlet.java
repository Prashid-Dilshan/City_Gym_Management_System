package com.example.city_gym_management_system;

import com.example.city_gym_management_system.util.AuthUtil;
import com.example.city_gym_management_system.util.BackendApiService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet(urlPatterns = {"/live-scan", "/api/scan/latest"})
public class LiveScanServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        String servletPath = request.getServletPath();
        if ("/api/scan/latest".equals(servletPath)) {
            handleLatestScanApi(response);
            return;
        }

        BackendApiService backendApi = new BackendApiService(getServletContext());
        try {
            JsonObject checkins = backendApi.getObject("/api/checkins/today");
            request.setAttribute("todayDate", LocalDate.now());
            request.setAttribute("checkinCount", checkins.has("count") ? checkins.get("count").getAsInt() : 0);
            request.setAttribute("recentActivity", checkins.has("events") ? checkins.getAsJsonArray("events") : new JsonArray());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Live feed refresh was interrupted.");
            request.setAttribute("checkinCount", 0);
            request.setAttribute("recentActivity", new JsonArray());
        } catch (Exception e) {
            request.setAttribute("error", "Unable to load today's check-ins right now.");
            request.setAttribute("checkinCount", 0);
            request.setAttribute("recentActivity", new JsonArray());
        }

        request.getRequestDispatcher("live_scan.jsp").forward(request, response);
    }

    private void handleLatestScanApi(HttpServletResponse response) throws IOException {
        BackendApiService backendApi = new BackendApiService(getServletContext());
        response.setContentType("application/json");

        try {
            JsonObject latest = backendApi.getObject("/api/scan/latest");
            addStatusIfPossible(latest);
            response.getWriter().write(latest.toString());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            JsonObject payload = new JsonObject();
            payload.addProperty("error", "Scan polling interrupted");
            response.getWriter().write(payload.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_GATEWAY);
            JsonObject payload = new JsonObject();
            payload.addProperty("error", "Unable to fetch latest scan");
            response.getWriter().write(payload.toString());
        }
    }

    private void addStatusIfPossible(JsonObject latest) {
        if (!latest.has("expiryDate")) {
            return;
        }

        String expiryValue = latest.get("expiryDate").getAsString();
        if (expiryValue == null || expiryValue.isBlank()) {
            return;
        }

        LocalDate expiryDate = LocalDate.parse(expiryValue);
        LocalDate now = LocalDate.now();
        if (expiryDate.isBefore(now)) {
            latest.addProperty("membershipStatus", "EXPIRED");
            latest.addProperty("statusLabel", "Membership Expired");
        } else if (!expiryDate.isAfter(now.plusDays(3))) {
            latest.addProperty("membershipStatus", "EXPIRING_SOON");
            latest.addProperty("statusLabel", "Expiring Soon");
        } else {
            latest.addProperty("membershipStatus", "ACTIVE");
            latest.addProperty("statusLabel", "Access Granted");
        }
    }
}
