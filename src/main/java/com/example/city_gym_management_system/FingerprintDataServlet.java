package com.example.city_gym_management_system;

import com.jacob.activeX.ActiveXComponent;
import com.jacob.com.Variant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/fingerprint-data")
public class FingerprintDataServlet extends HttpServlet {

    private static Map<String, String> userMap        = new HashMap<>();
    private static Map<String, String> dbUserMap      = new HashMap<>();
    private static Map<String, String> dbAdmissionMap = new HashMap<>();
    private static Map<String, String> dbDaysLeftMap  = new HashMap<>();

    static {
        try {
            System.load("C:\\Windows\\System32\\jacob-1.21-x64.dll");
        } catch (UnsatisfiedLinkError e) {
            System.out.println("JACOB already loaded");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<String>              statusLogs     = new ArrayList<>();
        List<Map<String, String>> attendanceLogs = new ArrayList<>();
        List<String>              users          = new ArrayList<>();
        Set<String>               savedMembers   = new HashSet<>();

        String page = request.getParameter("page");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gym_system", "root", "1234");

            String sql = "SELECT md.fingerprint_id, md.full_name, md.admission_no, ms.end_date " +
                    "FROM member_details md " +
                    "LEFT JOIN membership_details ms ON md.id = ms.member_id";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet         rs = ps.executeQuery();

            dbUserMap.clear();
            dbAdmissionMap.clear();
            dbDaysLeftMap.clear();

            while (rs.next()) {
                String fid     = rs.getString("fingerprint_id");
                String name    = rs.getString("full_name");
                String admNo   = rs.getString("admission_no");
                String endDate = rs.getString("end_date");

                savedMembers.add(fid);
                dbUserMap.put(fid, name);
                dbAdmissionMap.put(fid, admNo != null ? admNo : "-");

                if (endDate != null) {
                    try {
                        java.time.LocalDate end   = java.time.LocalDate.parse(endDate);
                        java.time.LocalDate today = java.time.LocalDate.now();
                        long days = java.time.temporal.ChronoUnit.DAYS.between(today, end);
                        dbDaysLeftMap.put(fid, days >= 0 ? days + " days" : "Expired");
                    } catch (Exception ex) {
                        dbDaysLeftMap.put(fid, "-");
                    }
                } else {
                    dbDaysLeftMap.put(fid, "-");
                }
            }

            rs.close();
            ps.close();
            con.close();

            // =========================
            // 🔥 CONNECT DEVICE
            // =========================
            ActiveXComponent zk = new ActiveXComponent("zkemkeeper.ZKEM");

            boolean isConnected = zk.invoke("Connect_Net",
                    new Variant("192.168.8.201"),
                    new Variant(4370)).getBoolean();

            if (!isConnected) {
                statusLogs.add("❌ Device connection failed!");
            } else {
                statusLogs.add("✅ Device Connected Successfully!");
                userMap.clear();

                if (page == null || "users".equals(page)) {
                    readUsers(zk, users, statusLogs);
                }

                if ("logs".equals(page)) {
                    readUsers(zk, users, statusLogs);
                    readLogs(zk, attendanceLogs);
                }

                zk.invoke("Disconnect");
            }

        } catch (Exception e) {
            statusLogs.add("❌ Error: " + e.getMessage());
        }

        request.setAttribute("statusLogs",     statusLogs);
        request.setAttribute("attendanceLogs", attendanceLogs);
        request.setAttribute("users",          users);
        request.setAttribute("savedMembers",   savedMembers);

        if ("logs".equals(page)) {
            request.getRequestDispatcher("attendance.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("members.jsp").forward(request, response);
        }
    }

    // =========================
    // 🔥 READ USERS FROM DEVICE
    // =========================
    private void readUsers(ActiveXComponent zk, List<String> users, List<String> statusLogs) {
        try {
            zk.invoke("ReadAllUserID", new Variant(1));

            Variant userId    = new Variant("", true);
            Variant name      = new Variant("", true);
            Variant password  = new Variant("", true);
            Variant privilege = new Variant(0, true);
            Variant enabled   = new Variant(false, true);

            while (true) {
                Variant result = zk.invoke("SSR_GetAllUserInfo",
                        new Variant(1), userId, name, password, privilege, enabled);

                if (!result.getBoolean()) break;

                String id       = userId.toString().trim();
                String userName = name.toString().trim();

                userMap.put(id, userName);
                users.add("👤 ID: " + id + " | Name: " + userName);
            }

        } catch (Exception e) {
            statusLogs.add("❌ Error reading users: " + e.getMessage());
        }
    }

    // =========================
    // 🔥 READ LOGS + SAVE TO DB
    // =========================
    private void readLogs(ActiveXComponent zk, List<Map<String, String>> attendanceLogs) {

        Connection con = null;

        try {
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gym_system", "root", "1234");

            zk.invoke("ReadGeneralLogData", new Variant(1));

            // INSERT IGNORE — same fingerprint_id + scan_time duplicates skip
            String insertSql = "INSERT IGNORE INTO attendance_log (fingerprint_id, scan_time) VALUES (?, ?)";
            PreparedStatement insertPs = con.prepareStatement(insertSql);

            while (true) {
                Variant userID     = new Variant("", true);
                Variant verifyMode = new Variant(0, true);
                Variant ioMode     = new Variant(0, true);
                Variant year       = new Variant(0, true);
                Variant month      = new Variant(0, true);
                Variant day        = new Variant(0, true);
                Variant hour       = new Variant(0, true);
                Variant minute     = new Variant(0, true);
                Variant second     = new Variant(0, true);
                Variant workCode   = new Variant(0, true);

                Variant result = zk.invoke("SSR_GetGeneralLogData",
                        new Variant(1), userID, verifyMode, ioMode,
                        year, month, day, hour, minute, second, workCode);

                if (!result.getBoolean()) break;

                String id        = userID.toString().trim();
                String name      = dbUserMap.getOrDefault(id, userMap.getOrDefault(id, "Unknown"));
                String admission = dbAdmissionMap.getOrDefault(id, "-");
                String daysLeft  = dbDaysLeftMap.getOrDefault(id, "-");

                String date     = String.format("%04d-%02d-%02d", parseInt(year), parseInt(month), parseInt(day));
                String time     = String.format("%02d:%02d:%02d", parseInt(hour), parseInt(minute), parseInt(second));
                String scanTime = date + " " + time;

                // 🔥 SAVE TO DB
                insertPs.setString(1, id);
                insertPs.setString(2, scanTime);
                insertPs.executeUpdate();

                // 🔥 ADD TO DISPLAY LIST
                Map<String, String> entry = new LinkedHashMap<>();
                entry.put("id",        id);
                entry.put("name",      name);
                entry.put("admission", admission);
                entry.put("date",      date);
                entry.put("time",      time);
                entry.put("daysLeft",  daysLeft);

                attendanceLogs.add(entry);
            }

            insertPs.close();

        } catch (Exception e) {
            Map<String, String> err = new HashMap<>();
            err.put("error", "❌ Log error: " + e.getMessage());
            attendanceLogs.add(err);
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }

    private int parseInt(Variant v) {
        try {
            return Integer.parseInt(v.toString().trim());
        } catch (Exception e) {
            return 0;
        }
    }

    // =========================
    // 🔥 DO POST — DELETE DEVICE USER
    // =========================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("deleteDeviceUser".equals(action)) {

            String fid = request.getParameter("fid");

            try {
                ActiveXComponent zk = new ActiveXComponent("zkemkeeper.ZKEM");

                boolean isConnected = zk.invoke("Connect_Net",
                        new Variant("192.168.8.201"),
                        new Variant(4370)).getBoolean();

                if (isConnected) {
                    zk.invoke("SSR_DeleteEnrollData", new Variant(1), new Variant(fid), new Variant(12));
                    zk.invoke("DeleteUserInfo",        new Variant(1), new Variant(fid));
                    zk.invoke("RefreshData",           new Variant(1));
                    zk.invoke("Disconnect");
                    System.out.println("✅ Deleted from device: " + fid);
                } else {
                    System.out.println("❌ Device not connected!");
                }

            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("fingerprint-data?page=users");
        }
    }
}
