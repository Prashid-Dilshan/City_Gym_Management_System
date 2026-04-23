package com.example.city_gym_management_system;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@MultipartConfig
@WebServlet("/record-payment")
public class PaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");

        Connection con = null;
        boolean committed = false;
        try {
            int memberId = parseRequiredInt(request.getParameter("memberId"), "Member is required");
            double amount = parseRequiredDouble(request.getParameter("amount"), "Amount is required");
            int months = parseRequiredInt(request.getParameter("months"), "Months are required");
            String startDate = requireText(request.getParameter("startDate"), "Start date is required");
            String endDate = requireText(request.getParameter("endDate"), "End date is required");

            con = DatabaseUtil.getConnection();
            con.setAutoCommit(false);

            MemberSnapshot member = loadMember(con, memberId);
            if (member == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("ERROR: Member not found");
                return;
            }

            upsertMembership(con, memberId, months, startDate, endDate, amount);
            recordPaymentHistory(con, memberId, amount, months);

            con.commit();
            committed = true;

            boolean whatsappSent = false;
            if (member.whatsapp != null && !member.whatsapp.isBlank()) {
                whatsappSent = WhatsAppService.sendPaymentReceipt(
                        member.name,
                        member.whatsapp,
                        amount,
                        months,
                        startDate,
                        endDate
                );
            }

            response.getWriter().write(whatsappSent ? "OK" : "OK: saved but whatsapp not sent");
        } catch (Exception e) {
            if (con != null && !committed) {
                try {
                    con.rollback();
                } catch (SQLException ignored) {
                }
            }
            response.getWriter().write("ERROR: " + e.getMessage());
        }
        finally {
            if (con != null) {
                try {
                    con.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    private MemberSnapshot loadMember(Connection con, int memberId) throws SQLException {
        String sql = "SELECT full_name, whatsapp FROM member_details WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new MemberSnapshot(rs.getString("full_name"), rs.getString("whatsapp"));
                }
            }
        }
        return null;
    }

    private void upsertMembership(Connection con, int memberId, int months, String startDate, String endDate, double amount) throws SQLException {
        Integer membershipId = null;
        String findSql = "SELECT id FROM membership_details WHERE member_id = ? ORDER BY id DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(findSql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    membershipId = rs.getInt("id");
                }
            }
        }

        if (membershipId == null) {
            String insertSql = "INSERT INTO membership_details (member_id, months, start_date, end_date, status, amount, registration_fee) VALUES (?,?,?,?,?,?,?)";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setInt(2, months);
                ps.setString(3, startDate);
                ps.setString(4, endDate);
                ps.setString(5, "ACTIVE");
                ps.setDouble(6, amount);
                ps.setDouble(7, 0.0d);
                ps.executeUpdate();
            }
        } else {
            String updateSql = "UPDATE membership_details SET months = ?, start_date = ?, end_date = ?, status = ?, amount = ? WHERE id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, months);
                ps.setString(2, startDate);
                ps.setString(3, endDate);
                ps.setString(4, "ACTIVE");
                ps.setDouble(5, amount);
                ps.setInt(6, membershipId);
                ps.executeUpdate();
            }
        }
    }

    private void recordPaymentHistory(Connection con, int memberId, double amount, int months) throws SQLException {
        String sql = "INSERT INTO payment_history (member_id, amount, months, status) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.setDouble(2, amount);
            ps.setInt(3, months);
            ps.setString(4, "COMPLETED");
            ps.executeUpdate();
        }
    }

    private int parseRequiredInt(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
        return Integer.parseInt(value.trim());
    }

    private double parseRequiredDouble(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
        return Double.parseDouble(value.trim());
    }

    private String requireText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
        return value.trim();
    }

    private record MemberSnapshot(String name, String whatsapp) {}
}

