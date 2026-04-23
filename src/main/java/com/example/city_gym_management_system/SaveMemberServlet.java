package com.example.city_gym_management_system;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.ServletException;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

@MultipartConfig
@WebServlet("/save-member")
public class SaveMemberServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        // ======================
        // 🔥 GET + CLEAN FID
        // ======================
        String fid = request.getParameter("userId");

        if (fid != null) {
            fid = fid.replaceAll("[^0-9]", "").trim();
        }

        if (fid == null || fid.isEmpty()) {
            response.sendRedirect("fingerprint-data?page=users");
            return;
        }

        // ======================
        // 🔥 FORM DATA
        // ======================
        String name = request.getParameter("name");
        String admissionNo = request.getParameter("admissionNo");
        String phone = request.getParameter("phone");
        String gender = request.getParameter("gender");
        String whatsapp = request.getParameter("whatsapp");
        String birthdayDate = request.getParameter("birthdayDate");
        String address = request.getParameter("address");

        int age = Integer.parseInt(request.getParameter("age"));
        int months = Integer.parseInt(request.getParameter("months"));

        String start = request.getParameter("startDate");
        String end = request.getParameter("endDate");

        double amount = Double.parseDouble(request.getParameter("amount"));
        double regFee = Double.parseDouble(request.getParameter("regFee"));

        // ======================
        // 🔥 PHOTO (BLOB)
        // ======================
        Part filePart = request.getPart("photo");
        InputStream photoStream = null;

        if (filePart != null && filePart.getSize() > 0) {
            photoStream = filePart.getInputStream();
        }

        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;
        ResultSet keyRs = null;

        try {
            con = DatabaseUtil.getConnection();
            con.setAutoCommit(false);

            boolean hasBirthdayColumn = hasColumn(con, "member_details", "birthday_date");

            // ======================
            // 🔥 DUPLICATE CHECK
            // ======================
            String checkSql = "SELECT id FROM member_details WHERE fingerprint_id=?";
            psCheck = con.prepareStatement(checkSql);
            psCheck.setString(1, fid);

            rs = psCheck.executeQuery();

            if (rs.next()) {
                response.sendRedirect("fingerprint-data?page=users");
                return;
            }

            // ======================
            // 🔥 INSERT MEMBER
            // ======================
            String q1 = hasBirthdayColumn
                    ? "INSERT INTO member_details " +
                    "(fingerprint_id,admission_no, full_name, phone, gender, age, whatsapp, birthday_date, address, photo) " +
                    "VALUES (?,?,?,?,?,?,?,?,?,?)"
                    : "INSERT INTO member_details " +
                    "(fingerprint_id,admission_no, full_name, phone, gender, age, whatsapp, address, photo) " +
                    "VALUES (?,?,?,?,?,?,?,?,?)";

            ps1 = con.prepareStatement(q1, Statement.RETURN_GENERATED_KEYS);

            ps1.setString(1, fid);
            ps1.setString(2, admissionNo);
            ps1.setString(3, name);
            ps1.setString(4, phone);
            ps1.setString(5, gender);
            ps1.setInt(6, age);
            ps1.setString(7, whatsapp);
            if (hasBirthdayColumn) {
                ps1.setString(8, birthdayDate != null && !birthdayDate.isBlank() ? birthdayDate : null);
                ps1.setString(9, address);
                if (photoStream != null) {
                    ps1.setBlob(10, photoStream);
                } else {
                    ps1.setNull(10, Types.BLOB);
                }
            } else {
                ps1.setString(8, address);
                if (photoStream != null) {
                    ps1.setBlob(9, photoStream);
                } else {
                    ps1.setNull(9, Types.BLOB);
                }
            }

            ps1.executeUpdate();

            int memberId = 0;
            keyRs = ps1.getGeneratedKeys();
            if (keyRs.next()) {
                memberId = keyRs.getInt(1);
            }

            if (memberId == 0) {
                throw new SQLException("Member ID not generated!");
            }

            // ======================
            // 🔥 INSERT MEMBERSHIP
            // ======================
            String q2 = "INSERT INTO membership_details " +
                    "(member_id, months, start_date, end_date, amount, registration_fee) " +
                    "VALUES (?,?,?,?,?,?)";

            ps2 = con.prepareStatement(q2);

            ps2.setInt(1, memberId);
            ps2.setInt(2, months);
            ps2.setString(3, start);
            ps2.setString(4, end);
            ps2.setDouble(5, amount);
            ps2.setDouble(6, regFee);

            ps2.executeUpdate();

            con.commit();

            if (whatsapp != null && !whatsapp.isBlank()) {
                WhatsAppService.sendMessage(
                        whatsapp,
                        String.format(
                                "*Welcome to City Gym*\n\nHello %s,\nYour member profile has been created successfully.\n\nWe are happy to have you with us.",
                                name)
                );
            }
        } catch (SQLException e) {
            System.err.println("[SAVE MEMBER ERROR] " + e.getMessage());
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    System.err.println("[SAVE MEMBER ERROR] Rollback failed: " + rollbackError.getMessage());
                }
            }
        } finally {
            closeQuietly(rs);
            closeQuietly(psCheck);
            closeQuietly(ps1);
            closeQuietly(ps2);
            closeQuietly(keyRs);
            closeQuietly(photoStream);
            closeQuietly(con);
        }

        response.sendRedirect("fingerprint-data?page=users");
    }

    private boolean hasColumn(Connection con, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = con.getMetaData();
        try (ResultSet columns = metaData.getColumns(con.getCatalog(), null, tableName, columnName)) {
            return columns.next();
        }
    }

    private void closeQuietly(AutoCloseable resource) {
        if (resource == null) {
            return;
        }

        try {
            resource.close();
        } catch (Exception e) {
            System.err.println("[SAVE MEMBER WARNING] Error closing resource: " + e.getMessage());
        }
    }
}