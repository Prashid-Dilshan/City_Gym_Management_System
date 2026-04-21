package com.example.city_gym_management_system;
import java.sql.*;
import java.time.LocalDate;
import java.util.Timer;
import java.util.TimerTask;

public class MembershipCheckService {
    private static Timer timer;
    private static final String NOTIFICATION_REMINDER = "PAYMENT_REMINDER";
    private static final String NOTIFICATION_EXPIRED = "MEMBERSHIP_EXPIRED";

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
            LocalDate reminderDate = today.plusDays(3);

            // 0. Payment reminder (only pre-expiry alert, sent 3 days before end date)
            String reminderQuery = "SELECT md.id, md.full_name, md.whatsapp, m.end_date FROM membership_details m " +
                "JOIN member_details md ON m.member_id = md.id " +
                "WHERE m.status = 'ACTIVE' AND m.end_date = ? " +
                "GROUP BY md.id, md.full_name, md.whatsapp, m.end_date";

            try (PreparedStatement ps = con.prepareStatement(reminderQuery)) {
                ps.setString(1, reminderDate.toString());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int memberId = rs.getInt(1);
                        String name = rs.getString(2);
                        String wa = rs.getString(3);
                        String date = rs.getString(4);

                        if (wa != null && !wa.isEmpty() && tryReserveNotification(con, memberId, NOTIFICATION_REMINDER, today)) {
                            boolean sent = WhatsAppService.sendPaymentReminder(name, wa, date);
                            updateReservedNotificationStatus(con, memberId, NOTIFICATION_REMINDER, today, sent ? "SENT" : "FAILED");
                        }
                    }
                }
            }

            // 1. Check for expired memberships
            String expiredQuery = "SELECT md.id, md.full_name, md.whatsapp FROM membership_details m " +
                "JOIN member_details md ON m.member_id = md.id " +
                "WHERE m.status = 'ACTIVE' AND m.end_date < ? " +
                "GROUP BY md.id, md.full_name, md.whatsapp";
            
            try (PreparedStatement ps = con.prepareStatement(expiredQuery)) {
                ps.setString(1, today.toString());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int memberId = rs.getInt(1);
                        String name = rs.getString(2);
                        String wa = rs.getString(3);

                        if (wa != null && !wa.isEmpty() && tryReserveNotification(con, memberId, NOTIFICATION_EXPIRED, today)) {
                            boolean sent = WhatsAppService.sendExpiredNotification(name, wa);
                            updateReservedNotificationStatus(con, memberId, NOTIFICATION_EXPIRED, today, sent ? "SENT" : "FAILED");
                        }

                        updateMembershipStatus(con, memberId, "EXPIRED", today);
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("[SERVICE ERROR] " + e.getMessage());
        }
    }

    private static void updateMembershipStatus(Connection con, int memberId, String status, LocalDate today) throws SQLException {
        String query = "UPDATE membership_details SET status = ? WHERE member_id = ? AND status = 'ACTIVE' AND end_date < ?";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, memberId);
            ps.setDate(3, Date.valueOf(today));
            ps.executeUpdate();
        }
    }

    private static boolean tryReserveNotification(Connection con, int memberId, String notificationType, LocalDate today) throws SQLException {
        String query = "INSERT INTO whatsapp_notifications (member_id, notification_type, status, sent_date) " +
                "SELECT ?, ?, 'PENDING', NOW() FROM DUAL " +
                "WHERE NOT EXISTS (" +
                "SELECT 1 FROM whatsapp_notifications WHERE member_id = ? AND notification_type = ? AND DATE(sent_date) = ?" +
                ")";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setInt(1, memberId);
            ps.setString(2, notificationType);
            ps.setInt(3, memberId);
            ps.setString(4, notificationType);
            ps.setDate(5, Date.valueOf(today));
            return ps.executeUpdate() > 0;
        }
    }

    private static void updateReservedNotificationStatus(Connection con, int memberId, String notificationType, LocalDate today, String status) throws SQLException {
        String query = "UPDATE whatsapp_notifications SET status = ? WHERE member_id = ? AND notification_type = ? AND DATE(sent_date) = ? ORDER BY id DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, memberId);
            ps.setString(3, notificationType);
            ps.setDate(4, Date.valueOf(today));
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

