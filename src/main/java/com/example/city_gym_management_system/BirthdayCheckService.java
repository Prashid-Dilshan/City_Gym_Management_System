package com.example.city_gym_management_system;
import java.sql.*;
import java.time.LocalDate;
import java.util.Timer;
import java.util.TimerTask;

public class BirthdayCheckService {
    private static Timer timer;
    private static final String NOTIFICATION_BIRTHDAY = "BIRTHDAY_WISH";

    public static void startService() {
        if (timer == null) {
            timer = new Timer("BirthdayCheckService", true);
            timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() { checkBirthdays(); }
            }, 0, 86400000); // Daily
            System.out.println("[BIRTHDAY SERVICE] Started");
        }
    }

    private static void checkBirthdays() {
        try (Connection con = DatabaseUtil.getConnection()) {
            LocalDate today = LocalDate.now();
            String month = String.format("%02d", today.getMonthValue());
            String day = String.format("%02d", today.getDayOfMonth());

            if (!hasBirthdayDateColumn(con)) {
                System.out.println("[BIRTHDAY SERVICE] Skipping: member_details.birthday_date column is missing");
                return;
            }

            String query = "SELECT id, full_name, whatsapp FROM member_details WHERE DATE_FORMAT(birthday_date, '%m-%d') = ?";
            String datePattern = month + "-" + day;

            try (PreparedStatement ps = con.prepareStatement(query)) {
                ps.setString(1, datePattern);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int memberId = rs.getInt(1);
                        String name = rs.getString(2);
                        String wa = rs.getString(3);

                        if (wa != null && !wa.isEmpty() && tryReserveNotification(con, memberId, NOTIFICATION_BIRTHDAY, today)) {
                            boolean sent = WhatsAppService.sendBirthdayWish(name, wa);
                            updateReservedNotificationStatus(con, memberId, NOTIFICATION_BIRTHDAY, today, sent ? "SENT" : "FAILED");
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[BIRTHDAY ERROR] " + e.getMessage());
        }
    }

    private static boolean hasBirthdayDateColumn(Connection con) throws SQLException {
        DatabaseMetaData metaData = con.getMetaData();
        try (ResultSet columns = metaData.getColumns(con.getCatalog(), null, "member_details", "birthday_date")) {
            return columns.next();
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
        if (timer != null) { timer.cancel(); timer = null; }
    }
}

