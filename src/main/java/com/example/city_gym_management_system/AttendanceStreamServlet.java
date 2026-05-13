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
        response.setHeader("Cache-Control", "no-store");

        String lastSeenStr = request.getParameter("lastSeen");
        long lastSeen = 0;

        if (lastSeenStr != null) {
            try {
                lastSeen = Long.parseLong(lastSeenStr);
            } catch (Exception ignored) {}
        }

        PrintWriter out = response.getWriter();

        try (Connection con = DatabaseUtil.getConnection()) {

            String sql =
                    "SELECT md.full_name, md.admission_no, md.fingerprint_id, ms.end_date, " +
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
                        String fid      = rs.getString("fingerprint_id");
                        String scanTime = rs.getString("scan_time");
                        long ts         = rs.getLong("ts");
                        String endDate  = rs.getString("end_date");

                        String daysLeft = "-";

                        if (endDate != null) {
                            try {
                                java.time.LocalDate end = java.time.LocalDate.parse(endDate);
                                java.time.LocalDate today = java.time.LocalDate.now();

                                long days = java.time.temporal.ChronoUnit.DAYS.between(today, end);

                                if (days < 0) {
                                    long expiredDays = Math.abs(days);
                                    daysLeft = "Expired " + expiredDays +
                                            (expiredDays == 1 ? " day ago" : " days ago");
                                } else if (days == 0) {
                                    daysLeft = "Expires Today";
                                } else {
                                    daysLeft = days + (days == 1 ? " day" : " days");
                                }

                            } catch (Exception ignored) {
                                System.err.println("[APP WARNING] Error parsing end date: " + endDate);
                            }
                        }

                        String timeOnly = "";

                        if (scanTime != null && scanTime.length() >= 19) {
                            timeOnly = scanTime.substring(11, 19);
                        } else if (scanTime != null) {
                            timeOnly = scanTime;
                        }

                        name = safe(name);
                        admNo = safe(admNo);
                        fid = safe(fid);
                        daysLeft = safe(daysLeft);
                        timeOnly = safe(timeOnly);

                        out.print("{" +
                                "\"found\":true," +
                                "\"fid\":\"" + fid + "\"," +
                                "\"fingerprintId\":\"" + fid + "\"," +
                                "\"fingerprint_id\":\"" + fid + "\"," +
                                "\"name\":\"" + name + "\"," +
                                "\"admNo\":\"" + admNo + "\"," +
                                "\"time\":\"" + timeOnly + "\"," +
                                "\"daysLeft\":\"" + daysLeft + "\"," +
                                "\"ts\":" + ts +
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