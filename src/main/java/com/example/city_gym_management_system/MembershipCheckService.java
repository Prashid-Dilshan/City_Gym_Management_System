package com.example.city_gym_management_system;
import java.sql.*;
import java.time.LocalDate;
import java.util.Timer;
import java.util.TimerTask;

public class MembershipCheckService {
    private static Timer timer;

    public static void startService() {
        if (timer == null) {
            timer = new Timer("MembershipCheckService", true);
            timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    checkMembershipStatus();
                }
            }, 0, 3600000); // Run every hour
            System.out.println("[SERVICE] Membership Check Service started");
        }
    }

    private static void checkMembershipStatus() {
        try (Connection con = DatabaseUtil.getConnection()) {
            LocalDate today = LocalDate.now();
            LocalDate warningDate = today.plusDays(7);

            // 1. Check for expiry warnings (7 days before expiration)
            String warningQuery = "SELECT m.id, md.full_name, md.whatsapp, m.end_date FROM membership_details m " +
                "JOIN member_details md ON m.member_id = md.id " +
                "WHERE m.status = 'ACTIVE' AND m.end_date = ?";
            
            try (PreparedStatement ps = con.prepareStatement(warningQuery)) {
                ps.setString(1, warningDate.toString());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String name = rs.getString(2);
                        String wa = rs.getString(3);
                        String date = rs.getString(4);
                        if (wa != null) WhatsAppService.sendExpiryWarning(name, wa, date);
                    }
                }
            }

            // 2. Check for expired memberships
            String expiredQuery = "SELECT m.id, md.full_name, md.whatsapp FROM membership_details m " +
                "JOIN member_details md ON m.member_id = md.id " +
                "WHERE m.status = 'ACTIVE' AND m.end_date < ?";
            
            try (PreparedStatement ps = con.prepareStatement(expiredQuery)) {
                ps.setString(1, today.toString());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int id = rs.getInt(1);
                        String name = rs.getString(2);
                        String wa = rs.getString(3);
                        if (wa != null) WhatsAppService.sendExpiredNotification(name, wa);
                        updateMembershipStatus(con, id, "EXPIRED");
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("[SERVICE ERROR] " + e.getMessage());
        }
    }

    private static void updateMembershipStatus(Connection con, int membershipId, String status) throws SQLException {
        String query = "UPDATE membership_details SET status = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, membershipId);
            ps.executeUpdate();
        }
    }

    public static void stopService() {
        if (timer != null) {
            timer.cancel();
            timer = null;
            System.out.println("[SERVICE] Membership Check Service stopped");
        }
    }
}

