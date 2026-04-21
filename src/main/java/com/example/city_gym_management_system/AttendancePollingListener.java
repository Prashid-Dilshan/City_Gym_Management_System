package com.example.city_gym_management_system;

import com.jacob.activeX.ActiveXComponent;
import com.jacob.com.Variant;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.*;

@WebListener
public class AttendancePollingListener implements ServletContextListener {

    private Thread pollingThread;
    private volatile boolean running = false;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        running = true;

        pollingThread = new Thread(() -> {
            try {
                System.load("C:\\Windows\\System32\\jacob-1.21-x64.dll");
            } catch (UnsatisfiedLinkError e) {
                System.out.println("JACOB already loaded");
            }

            System.out.println("✅ ZK Attendance Poller Started");

            while (running) {
                try {
                    pollDevice();
                } catch (Exception e) {
                    System.out.println("❌ Poll error: " + e.getMessage());
                }

                try {
                    Thread.sleep(10000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });

        pollingThread.setDaemon(true);
        pollingThread.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        running = false;
        if (pollingThread != null) pollingThread.interrupt();
    }

    private void pollDevice() {

        ActiveXComponent zk = null;
        Connection con = null;

        try {
            con = DatabaseUtil.getConnection();

            zk = new ActiveXComponent("zkemkeeper.ZKEM");

            boolean connected = zk.invoke("Connect_Net",
                    new Variant("192.168.8.201"),
                    new Variant(4370)).getBoolean();

            if (!connected) {
                System.out.println("⚠️ Device not connected");
                return;
            }

            // 🔥 ================= MIDNIGHT RESET (FIXED) =================
            try {

                String todayStr = java.time.LocalDate.now().toString();
                String lastClean = "";

                // 🔹 GET last clean date from DB
                PreparedStatement psGet = con.prepareStatement(
                        "SELECT setting_value FROM system_settings WHERE setting_key='last_clean_date'"
                );

                ResultSet rs = psGet.executeQuery();

                if (rs.next()) {
                    lastClean = rs.getString("setting_value");
                }

                rs.close();
                psGet.close();

                // 🔹 ONLY CLEAN ONCE PER DAY
                if (!todayStr.equals(lastClean)) {

                    zk.invoke("ClearGLog", new Variant(1));
                    System.out.println("🧹 Device logs cleared");

                    // 🔹 UPDATE DB
                    PreparedStatement psUpdate = con.prepareStatement(
                            "REPLACE INTO system_settings (setting_key, setting_value) VALUES ('last_clean_date', ?)"
                    );

                    psUpdate.setString(1, todayStr);
                    psUpdate.executeUpdate();
                    psUpdate.close();
                }

            } catch (Exception e) {
                System.err.println("[ATTENDANCE POLL WARNING] Midnight reset failed: " + e.getMessage());
            }


            // 🔥 READ LOGS AFTER CLEAN
            zk.invoke("ReadGeneralLogData", new Variant(1));

            String insertSql =
                    "INSERT IGNORE INTO attendance_log (fingerprint_id, scan_time) " +
                            "SELECT ?, ? FROM member_details WHERE fingerprint_id = ? LIMIT 1";

            PreparedStatement ps = con.prepareStatement(insertSql);

            while (true) {

                Variant userID = new Variant("", true), vm = new Variant(0, true),
                        io = new Variant(0, true),
                        yr = new Variant(0, true), mo = new Variant(0, true),
                        dy = new Variant(0, true), hr = new Variant(0, true),
                        mn = new Variant(0, true), sc = new Variant(0, true),
                        wc = new Variant(0, true);

                Variant res = zk.invoke("SSR_GetGeneralLogData",
                        new Variant(1), userID, vm, io, yr, mo, dy, hr, mn, sc, wc);

                if (!res.getBoolean()) break;

                String fid = userID.toString().trim();

                if (fid.isEmpty() || fid.equals("0")) continue;

                String date = String.format("%04d-%02d-%02d",
                        si(yr), si(mo), si(dy));

                String time = String.format("%02d:%02d:%02d",
                        si(hr), si(mn), si(sc));

                ps.setString(1, fid);
                ps.setString(2, date + " " + time);
                ps.setString(3, fid);

                ps.executeUpdate();
            }

            ps.close();
            zk.invoke("Disconnect");

        } catch (Exception e) {
            System.out.println("❌ Poll error: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    private int si(Variant v) {
        try { return Integer.parseInt(v.toString().trim()); }
        catch (Exception e) { return 0; }
    }
}