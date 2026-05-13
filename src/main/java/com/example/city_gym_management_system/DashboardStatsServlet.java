package com.example.city_gym_management_system;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/dashboard-stats")
public class DashboardStatsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.setStatus(401);
            response.getWriter().print("{\"error\":\"unauthorized\"}");
            return;
        }

        PrintWriter out = response.getWriter();

        int    todayCount        = 0;
        int    totalMembers      = 0;
        int    activeMemberships = 0;
        int    endedMemberships  = 0;
        double weeklyAvg         = 0.0;
        double revToday          = 0.0;
        double rev7Days          = 0.0;
        double rev30Days         = 0.0;

        List<String> chartLabels7  = new ArrayList<>();
        List<Integer> chartData7   = new ArrayList<>();
        List<String> chartLabels30 = new ArrayList<>();
        List<Integer> chartData30  = new ArrayList<>();

        try (Connection con = DatabaseUtil.getConnection()) {

            // Today attendance
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(DISTINCT fingerprint_id) FROM attendance_log WHERE DATE(scan_time) = CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) todayCount = rs.getInt(1);
            }

            // Total members
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM member_details");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalMembers = rs.getInt(1);
            }

            // Active memberships
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM membership_details WHERE end_date >= CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) activeMemberships = rs.getInt(1);
            }

            // Ended memberships
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM membership_details WHERE end_date < CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) endedMemberships = rs.getInt(1);
            }

            // Weekly avg
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT AVG(daily_count) FROM (SELECT COUNT(*) as daily_count FROM attendance_log " +
                            "WHERE scan_time >= CURDATE() - INTERVAL 7 DAY GROUP BY DATE(scan_time)) t");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) weeklyAvg = rs.getDouble(1);
            }

            // Revenue today
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(amount + registration_fee), 0) FROM membership_details WHERE DATE(start_date) = CURDATE()");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) revToday = rs.getDouble(1);
            }

            // Revenue 7 days
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(amount + registration_fee), 0) FROM membership_details WHERE start_date >= CURDATE() - INTERVAL 7 DAY");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) rev7Days = rs.getDouble(1);
            }

            // Revenue 30 days
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(amount + registration_fee), 0) FROM membership_details WHERE start_date >= CURDATE() - INTERVAL 30 DAY");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) rev30Days = rs.getDouble(1);
            }

            // Chart 7 days
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT DATE(scan_time) as day, COUNT(*) as total FROM attendance_log " +
                            "WHERE scan_time >= CURDATE() - INTERVAL 7 DAY GROUP BY DATE(scan_time) ORDER BY day ASC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    chartLabels7.add(rs.getString("day"));
                    chartData7.add(rs.getInt("total"));
                }
            }

            // Chart 30 days
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT DATE(scan_time) as day, COUNT(*) as total FROM attendance_log " +
                            "WHERE scan_time >= CURDATE() - INTERVAL 30 DAY GROUP BY DATE(scan_time) ORDER BY day ASC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    chartLabels30.add(rs.getString("day"));
                    chartData30.add(rs.getInt("total"));
                }
            }

        } catch (Exception e) {
            response.setStatus(500);
            out.print("{\"error\":\"" + safe(e.getMessage()) + "\"}");
            return;
        }

        // Format revenue with commas — same format as JSP
        String fmtRevToday  = String.format("%,.0f", revToday);
        String fmtRev7Days  = String.format("%,.0f", rev7Days);
        String fmtRev30Days = String.format("%,.0f", rev30Days);
        String fmtWeeklyAvg = String.format("%.1f", weeklyAvg);

        // Build JSON manually (no external lib needed)
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"todayCount\":").append(todayCount).append(",");
        json.append("\"totalMembers\":").append(totalMembers).append(",");
        json.append("\"activeMemberships\":").append(activeMemberships).append(",");
        json.append("\"endedMemberships\":").append(endedMemberships).append(",");
        json.append("\"weeklyAvg\":\"").append(fmtWeeklyAvg).append("\",");
        json.append("\"revToday\":\"").append(fmtRevToday).append("\",");
        json.append("\"rev7Days\":\"").append(fmtRev7Days).append("\",");
        json.append("\"rev30Days\":\"").append(fmtRev30Days).append("\",");

        // Chart labels7
        json.append("\"chartLabels7\":[");
        for (int i = 0; i < chartLabels7.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(safe(chartLabels7.get(i))).append("\"");
        }
        json.append("],");

        // Chart data7
        json.append("\"chartData7\":[");
        for (int i = 0; i < chartData7.size(); i++) {
            if (i > 0) json.append(",");
            json.append(chartData7.get(i));
        }
        json.append("],");

        // Chart labels30
        json.append("\"chartLabels30\":[");
        for (int i = 0; i < chartLabels30.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(safe(chartLabels30.get(i))).append("\"");
        }
        json.append("],");

        // Chart data30
        json.append("\"chartData30\":[");
        for (int i = 0; i < chartData30.size(); i++) {
            if (i > 0) json.append(",");
            json.append(chartData30.get(i));
        }
        json.append("]");

        json.append("}");

        out.print(json.toString());
    }

    private String safe(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
