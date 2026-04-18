package com.example.city_gym_management_system;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/attendance-stream")
public class AttendanceStreamServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        // Cache prevent
        response.setHeader("Cache-Control", "no-store");

        // 🔥 JS එකෙන් lastSeen = UNIX timestamp of inserted_at
        String lastSeenStr = request.getParameter("lastSeen");
        long lastSeen = 0;
        if (lastSeenStr != null) {
            try { lastSeen = Long.parseLong(lastSeenStr); } catch (Exception ignored) {}
        }

        PrintWriter out = response.getWriter();

        try (Connection con = DatabaseUtil.getConnection()) {

            // 🔥 KEY FIX: scan_time නෙමෙයි — inserted_at use කරනවා
            // inserted_at = server DB insert කළ real time
            // ඒ නිසා restart කළාත් page load time ට පස්සේ
            // insert වූ records විතරයි popup වෙන්නේ
            String sql =
                    "SELECT md.full_name, md.admission_no, ms.end_date, " +
                            "       al.scan_time, " +
                            "       UNIX_TIMESTAMP(al.inserted_at) AS ts " +
                            "FROM attendance_log al " +
                            "JOIN member_details md ON al.fingerprint_id = md.fingerprint_id " +
                            "LEFT JOIN membership_details ms ON md.id = ms.member_id " +
                            "WHERE UNIX_TIMESTAMP(al.inserted_at) > ? " +
                            "ORDER BY al.inserted_at DESC LIMIT 1";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setLong(1, lastSeen);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String name     = rs.getString("full_name");
                        String admNo    = rs.getString("admission_no");
                        String scanTime = rs.getString("scan_time");
                        long   ts       = rs.getLong("ts");
                        String endDate  = rs.getString("end_date");

                        // Days remaining
                        String daysLeft = "-";
                        if (endDate != null) {
                            try {
                                java.time.LocalDate end   = java.time.LocalDate.parse(endDate);
                                java.time.LocalDate today = java.time.LocalDate.now();
                                long days = java.time.temporal.ChronoUnit.DAYS.between(today, end);
                                daysLeft = days >= 0 ? days + " days" : "Expired";
                            } catch (Exception ignored) {
                                System.err.println("[APP WARNING] Error parsing end date: " + endDate);
                            }
                        }

                        // Time only HH:mm:ss
                        String timeOnly = (scanTime != null && scanTime.length() >= 19)
                                ? scanTime.substring(11, 19) : (scanTime != null ? scanTime : "");

                        // Safe JSON
                        name  = safe(name);
                        admNo = safe(admNo);

                        out.print("{" +
                                "\"found\":true,"          +
                                "\"name\":\""     + name     + "\"," +
                                "\"admNo\":\""    + admNo    + "\"," +
                                "\"time\":\""     + timeOnly + "\"," +
                                "\"daysLeft\":\"" + daysLeft + "\"," +
                                "\"ts\":"         + ts       +
                                "}");

                    } else {
                        out.print("{\"found\":false}");
                    }
                }
            }

        } catch (SQLException e) {
            System.err.println("[DB ERROR] Attendance stream query failed: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"found\":false,\"error\":\"" + safe(e.getMessage()) + "\"}");
        } catch (Exception e) {
            System.err.println("[APP ERROR] Attendance stream error: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"found\":false}");
        }
    }

    private String safe(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}