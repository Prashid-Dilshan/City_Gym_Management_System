package com.example.city_gym_management_system;

import com.example.city_gym_management_system.util.AuthUtil;
import com.example.city_gym_management_system.util.BackendApiService;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@WebServlet("/members")
@MultipartConfig
public class MemberServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        moveFlashMessage(request);

        BackendApiService backendApi = new BackendApiService(getServletContext());
        try {
            JsonArray members = backendApi.getArray("/api/members");
            JsonArray membersWithStatus = new JsonArray();
            for (JsonElement element : members) {
                JsonObject member = element.getAsJsonObject();
                member.addProperty("status", calculateStatus(getString(member, "expiryDate")));
                membersWithStatus.add(member);
            }
            request.setAttribute("members", membersWithStatus);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("error", "Loading members was interrupted.");
            request.setAttribute("members", new JsonArray());
        } catch (Exception e) {
            request.setAttribute("error", "Unable to load members right now.");
            request.setAttribute("members", new JsonArray());
        }

        request.getRequestDispatcher("members.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!AuthUtil.requireSession(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        BackendApiService backendApi = new BackendApiService(getServletContext());

        try {
            if ("delete".equals(action)) {
                String memberId = request.getParameter("memberId");
                backendApi.delete("/api/members/" + BackendApiService.encode(memberId));
                request.getSession().setAttribute("successMessage", "Member deleted successfully.");
            } else if ("enroll".equals(action)) {
                String memberId = request.getParameter("memberId");
                backendApi.postJson("/api/members/" + BackendApiService.encode(memberId) + "/enroll", new JsonObject());
                request.getSession().setAttribute("successMessage", "Fingerprint enrollment triggered.");
            } else if ("update".equals(action)) {
                updateMember(request, backendApi);
                request.getSession().setAttribute("successMessage", "Member updated successfully.");
            } else {
                createMember(request, backendApi);
                request.getSession().setAttribute("successMessage", "Member added successfully.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.getSession().setAttribute("error", "Operation interrupted.");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Member operation failed: " + e.getMessage());
        }

        response.sendRedirect("members");
    }

    private void createMember(HttpServletRequest request, BackendApiService backendApi) throws Exception {
        String fullName = request.getParameter("fullName");
        String whatsapp = request.getParameter("whatsappNumber");
        LocalDate startDate = LocalDate.parse(request.getParameter("startDate"), DATE_FORMAT);
        String duration = request.getParameter("duration");
        LocalDate expiryDate = calculateExpiry(startDate, duration);

        JsonObject member = new JsonObject();
        member.addProperty("name", fullName);
        member.addProperty("whatsappNumber", sanitizePhone(whatsapp));
        member.addProperty("startDate", startDate.toString());
        member.addProperty("duration", duration);
        member.addProperty("expiryDate", expiryDate.toString());

        String photoPath = savePhotoIfPresent(request);
        if (!photoPath.isBlank()) {
            member.addProperty("photoUrl", photoPath);
        }

        backendApi.postJson("/api/members", member);
    }

    private void updateMember(HttpServletRequest request, BackendApiService backendApi) throws Exception {
        String memberId = request.getParameter("memberId");
        String fullName = request.getParameter("fullName");
        String whatsapp = request.getParameter("whatsappNumber");
        String expiryDate = request.getParameter("expiryDate");

        JsonObject member = new JsonObject();
        member.addProperty("name", fullName);
        member.addProperty("whatsappNumber", sanitizePhone(whatsapp));
        member.addProperty("expiryDate", expiryDate);

        String photoPath = savePhotoIfPresent(request);
        if (!photoPath.isBlank()) {
            member.addProperty("photoUrl", photoPath);
        }

        backendApi.putJson("/api/members/" + BackendApiService.encode(memberId), member);
    }

    private String savePhotoIfPresent(HttpServletRequest request) throws Exception {
        Part photo = request.getPart("photo");
        if (photo == null || photo.getSubmittedFileName() == null || photo.getSubmittedFileName().isBlank()) {
            return "";
        }

        String uploadsPath = getServletContext().getRealPath("/uploads");
        Path uploadDir = uploadsPath == null
                ? Path.of(System.getProperty("user.home"), "citygym-uploads")
                : Path.of(uploadsPath);

        Files.createDirectories(uploadDir);
        String originalName = new File(photo.getSubmittedFileName()).getName();
        String extension = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : "";
        String fileName = UUID.randomUUID() + extension;
        Path target = uploadDir.resolve(fileName);
        Files.copy(photo.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

        return "uploads/" + fileName;
    }

    private LocalDate calculateExpiry(LocalDate startDate, String duration) {
        if ("3_MONTHS".equals(duration)) {
            return startDate.plusMonths(3);
        }
        if ("6_MONTHS".equals(duration)) {
            return startDate.plusMonths(6);
        }
        if ("1_YEAR".equals(duration)) {
            return startDate.plusYears(1);
        }
        return startDate.plusMonths(1);
    }

    private String calculateStatus(String expiryDateRaw) {
        if (expiryDateRaw == null || expiryDateRaw.isBlank()) {
            return "EXPIRED";
        }

        LocalDate expiryDate = LocalDate.parse(expiryDateRaw, DATE_FORMAT);
        LocalDate now = LocalDate.now();
        if (expiryDate.isBefore(now)) {
            return "EXPIRED";
        }
        if (!expiryDate.isAfter(now.plusDays(3))) {
            return "EXPIRING_SOON";
        }
        return "ACTIVE";
    }

    private void moveFlashMessage(HttpServletRequest request) {
        Object success = request.getSession().getAttribute("successMessage");
        Object error = request.getSession().getAttribute("error");

        if (success != null) {
            request.setAttribute("successMessage", success);
            request.getSession().removeAttribute("successMessage");
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.getSession().removeAttribute("error");
        }
    }

    private String sanitizePhone(String value) {
        return value == null ? "" : value.replaceAll("[^0-9]", "");
    }

    private String getString(JsonObject obj, String key) {
        return obj.has(key) && !obj.get(key).isJsonNull() ? obj.get(key).getAsString() : "";
    }
}
