package com.example.city_gym_management_system;

import com.jacob.activeX.ActiveXComponent;
import com.jacob.com.Variant;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.*;
import java.util.*;

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
                    Thread.sleep(10000); // 10s
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });

        pollingThread.setDaemon(true);
        pollingThread.setName("ZK-Poller");
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
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gym_system", "root", "1234");

            zk = new ActiveXComponent("zkemkeeper.ZKEM");
            boolean connected = zk.invoke("Connect_Net",
                    new Variant("192.168.8.201"),
                    new Variant(4370)).getBoolean();

            if (!connected) {
                System.out.println("⚠️ Poller: Device unreachable");
                return;
            }

            // Users read (fallback name lookup)
            Map<String, String> deviceUsers = new HashMap<>();
            zk.invoke("ReadAllUserID", new Variant(1));
            Variant uid = new Variant("", true), uname = new Variant("", true),
                    upwd = new Variant("", true), upriv = new Variant(0, true),
                    uena = new Variant(false, true);
            while (true) {
                Variant r = zk.invoke("SSR_GetAllUserInfo",
                        new Variant(1), uid, uname, upwd, upriv, uena);
                if (!r.getBoolean()) break;
                deviceUsers.put(uid.toString().trim(), uname.toString().trim());
            }

            // Logs read
            zk.invoke("ReadGeneralLogData", new Variant(1));

            // 🔥 INSERT IGNORE — duplicate skip, inserted_at = NOW() (server time)
            String insertSql =
                    "INSERT IGNORE INTO attendance_log (fingerprint_id, scan_time) " +
                            "VALUES (?, ?)";
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

                String fid  = userID.toString().trim();
                String date = String.format("%04d-%02d-%02d",
                        si(yr), si(mo), si(dy));
                String time = String.format("%02d:%02d:%02d",
                        si(hr), si(mn), si(sc));

                ps.setString(1, fid);
                ps.setString(2, date + " " + time);
                ps.executeUpdate(); // INSERT IGNORE — new rows get inserted_at = NOW()
            }

            ps.close();
            zk.invoke("Disconnect");

        } catch (Exception e) {
            System.out.println("❌ Poll exception: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    private int si(Variant v) {
        try { return Integer.parseInt(v.toString().trim()); }
        catch (Exception e) { return 0; }
    }
}