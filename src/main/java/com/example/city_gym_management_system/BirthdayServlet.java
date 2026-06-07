package com.example.city_gym_management_system;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet("/birthday-members")
public class BirthdayServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth check ──
        String role = (String) request.getSession().getAttribute("userRole");
        if (!"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String format = request.getParameter("format"); // "json" → dropdown call
        String month  = request.getParameter("month");  // "1"–"12" → month filter, null → today

        LocalDate today     = LocalDate.now();
        int todayMonth      = today.getMonthValue();   // 1-12
        int todayDay        = today.getDayOfMonth();   // 1-31

        // Zero-padded MM-DD for comparison  e.g. "06-06"
        String todayMMDD = String.format("%02d-%02d", todayMonth, todayDay);

        String todayDisplayDate = today.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));

        System.out.println("[BIRTHDAY] Today MMDD = " + todayMMDD);

        List<Map<String, Object>> allMembers  = new ArrayList<>();
        List<Map<String, Object>> todayList   = new ArrayList<>();
        List<Map<String, Object>> monthList   = new ArrayList<>();

        try (Connection con = DatabaseUtil.getConnection()) {

            // ── Check if birthday_date column exists ──
            boolean hasBdCol = columnExists(con, "member_details", "birthday_date");
            System.out.println("[BIRTHDAY] birthday_date column exists = " + hasBdCol);

            if (!hasBdCol) {
                // Column missing — return gracefully
                if ("json".equals(format)) {
                    writeJson(response, "[]");
                } else {
                    setPageAttributes(request, 0, 0, new ArrayList<>(), todayDisplayDate);
                    request.getRequestDispatcher("birthday.jsp").forward(request, response);
                }
                return;
            }

            // ── Fetch all members that have a birthday_date ──
            String sql =
                    "SELECT " +
                            "  md.fingerprint_id, " +
                            "  md.admission_no, " +
                            "  md.full_name, " +
                            "  md.phone, " +
                            "  md.birthday_date " +
                            "FROM member_details md " +
                            "WHERE md.birthday_date IS NOT NULL " +
                            "  AND TRIM(md.birthday_date) != '' " +
                            "ORDER BY " +
                            "  MONTH(STR_TO_DATE(md.birthday_date, '%Y-%m-%d')), " +
                            "  DAY(STR_TO_DATE(md.birthday_date, '%Y-%m-%d'))";

            System.out.println("[BIRTHDAY] Running SQL...");

            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String bdRaw = rs.getString("birthday_date");
                    System.out.println("[BIRTHDAY] Raw birthday_date = '" + bdRaw + "'");

                    if (bdRaw == null) continue;
                    bdRaw = bdRaw.trim();
                    if (bdRaw.isEmpty()) continue;

                    // ── Normalise to YYYY-MM-DD regardless of stored format ──
                    // Handles: "2004-06-06", "06/06/2004", "2004/06/06", "06-06-2004"
                    String normalised = normaliseDateStr(bdRaw);
                    if (normalised == null) {
                        System.out.println("[BIRTHDAY] Could not parse date: " + bdRaw);
                        continue;
                    }

                    // MM-DD portion for comparison
                    String mmdd = normalised.substring(5); // "06-06"

                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("fid",          rs.getString("fingerprint_id"));
                    row.put("admissionNo",  rs.getString("admission_no"));
                    row.put("name",         rs.getString("full_name"));
                    row.put("phone",        rs.getString("phone"));
                    row.put("birthdayDate", normalised);
                    row.put("isToday",      mmdd.equals(todayMMDD));

                    allMembers.add(row);

                    if (mmdd.equals(todayMMDD)) {
                        todayList.add(row);
                        System.out.println("[BIRTHDAY] TODAY match: " + rs.getString("full_name"));
                    }

                    // Month bucket (MM portion)
                    String mmPart = normalised.substring(5, 7); // "06"
                    if (Integer.parseInt(mmPart) == todayMonth) {
                        monthList.add(row);
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("[BIRTHDAY] DB error: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("[BIRTHDAY] todayList size = " + todayList.size());
        System.out.println("[BIRTHDAY] allMembers size = " + allMembers.size());

        // ── JSON mode → topbar dropdown ──
        if ("json".equals(format)) {
            String json = buildJson(todayList);
            writeJson(response, json);
            return;
        }

        // ── Page mode ──
        List<Map<String, Object>> displayMembers;

        if (month != null && !month.isEmpty()) {
            // Filter by selected month number
            int selectedM = Integer.parseInt(month);
            displayMembers = new ArrayList<>();
            for (Map<String, Object> m2 : allMembers) {
                String bd = (String) m2.get("birthdayDate");
                if (bd != null && bd.length() >= 7) {
                    int bdM = Integer.parseInt(bd.substring(5, 7));
                    if (bdM == selectedM) displayMembers.add(m2);
                }
            }
        } else {
            // Default: today's birthdays
            displayMembers = todayList;
        }

        setPageAttributes(request, todayList.size(), monthList.size(), displayMembers, todayDisplayDate);
        request.getRequestDispatcher("birthday.jsp").forward(request, response);
    }

    // ─────────────────────────────────────────────
    // Normalise various date string formats → YYYY-MM-DD
    // Handles: 2004-06-06 / 06/06/2004 / 2004/06/06 / 06-06-2004
    // ─────────────────────────────────────────────
    private String normaliseDateStr(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        raw = raw.trim();

        // Already YYYY-MM-DD
        if (raw.matches("\\d{4}-\\d{2}-\\d{2}")) {
            return raw;
        }

        // YYYY/MM/DD
        if (raw.matches("\\d{4}/\\d{2}/\\d{2}")) {
            return raw.replace("/", "-");
        }

        // DD/MM/YYYY  or  MM/DD/YYYY
        if (raw.matches("\\d{2}/\\d{2}/\\d{4}")) {
            String[] parts = raw.split("/");
            // Treat as DD/MM/YYYY (most common in Sri Lanka)
            return parts[2] + "-" + parts[1] + "-" + parts[0];
        }

        // DD-MM-YYYY
        if (raw.matches("\\d{2}-\\d{2}-\\d{4}")) {
            String[] parts = raw.split("-");
            return parts[2] + "-" + parts[1] + "-" + parts[0];
        }

        // Unrecognised
        return null;
    }

    // ─────────────────────────────────────────────
    // Build JSON string manually (no Gson needed)
    // ─────────────────────────────────────────────
    private String buildJson(List<Map<String, Object>> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            Map<String, Object> m = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{");
            sb.append("\"fid\":"         ).append(jsonStr(m.get("fid")));
            sb.append(",\"admissionNo\":").append(jsonStr(m.get("admissionNo")));
            sb.append(",\"name\":"       ).append(jsonStr(m.get("name")));
            sb.append(",\"phone\":"      ).append(jsonStr(m.get("phone")));
            sb.append(",\"birthdayDate\":").append(jsonStr(m.get("birthdayDate")));
            sb.append(",\"isToday\":"    ).append(m.get("isToday"));
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String jsonStr(Object val) {
        if (val == null) return "null";
        String s = val.toString()
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");
        return "\"" + s + "\"";
    }

    private void writeJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.write(json);
        }
    }

    private void setPageAttributes(HttpServletRequest req,
                                   int todayCount, int monthCount,
                                   List<Map<String, Object>> display,
                                   String todayDate) {
        req.setAttribute("todayCount",     todayCount);
        req.setAttribute("monthCount",     monthCount);
        req.setAttribute("displayMembers", display);
        req.setAttribute("todayDate",      todayDate);
    }

    private boolean columnExists(Connection con, String table, String column) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(
                con.getCatalog(), null, table, column)) {
            return rs.next();
        }
    }
}