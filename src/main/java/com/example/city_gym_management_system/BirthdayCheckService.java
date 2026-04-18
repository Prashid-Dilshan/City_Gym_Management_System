package com.example.city_gym_management_system;
import java.sql.*;
import java.time.LocalDate;
import java.util.Timer;
import java.util.TimerTask;

public class BirthdayCheckService {
    private static Timer timer;

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

            String query = "SELECT full_name, whatsapp FROM member_details WHERE DATE_FORMAT(created_at, '%m-%d') = ?";
            String datePattern = month + "-" + day;

            try (PreparedStatement ps = con.prepareStatement(query)) {
                ps.setString(1, datePattern);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String name = rs.getString(1);
                        String wa = rs.getString(2);
                        if (wa != null && !wa.isEmpty()) {
                            WhatsAppService.sendBirthdayWish(name, wa);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[BIRTHDAY ERROR] " + e.getMessage());
        }
    }

    public static void stopService() {
        if (timer != null) { timer.cancel(); timer = null; }
    }
}

