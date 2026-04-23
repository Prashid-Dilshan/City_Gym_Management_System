package com.example.city_gym_management_system;

import com.jacob.activeX.ActiveXComponent;
import com.jacob.com.Variant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import java.io.InputStream;

@MultipartConfig
@WebServlet("/view-member")
public class ViewMemberServlet extends HttpServlet {

    // ======================
    // 🔥 VIEW (GET)
    // ======================
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fid = request.getParameter("fid");


// 🔥 IMAGE MODE (ADD THIS ONLY)
        if ("image".equals(request.getParameter("type"))) {

            try {
                Connection con = DatabaseUtil.getConnection();

                String sql = "SELECT photo FROM member_details WHERE fingerprint_id=?";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, fid);

                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    byte[] img = rs.getBytes("photo");

                    if (img != null) {
                        response.setContentType("image/jpeg");
                        response.getOutputStream().write(img);
                    }
                }

                con.close();
                return; // 🔥 VERY IMPORTANT

            } catch (Exception e) {
                System.err.println("[VIEW MEMBER ERROR] Image load failed: " + e.getMessage());
            }
        }

        String admissionNo = "";
        String name = "";
        String phone = "";
        String gender = "";
        int age = 0;
        int memberId = 0;
        String whatsapp = "";
        String birthdayDate = "";
        String address = "";
        int months = 0;
        String startDate = "";
        String endDate = "";
        double amount = 0;
        double regFee = 0;

        try {
            Connection con = DatabaseUtil.getConnection();

            boolean hasBirthdayColumn = hasColumn(con, "member_details", "birthday_date");

            String sql = "SELECT * FROM member_details md " +
                    "LEFT JOIN membership_details ms ON md.id = ms.member_id " +
                    "WHERE md.fingerprint_id=?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, fid);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                memberId = rs.getInt("id");
                name = rs.getString("full_name");
                admissionNo = rs.getString("admission_no");
                phone = rs.getString("phone");
                gender = rs.getString("gender");
                age = rs.getInt("age");
                whatsapp = rs.getString("whatsapp");
                if (hasBirthdayColumn) {
                    birthdayDate = rs.getString("birthday_date");
                }
                address = rs.getString("address");

                months = rs.getInt("months");
                startDate = rs.getString("start_date");
                endDate = rs.getString("end_date");

                amount = rs.getDouble("amount");
                regFee = rs.getDouble("registration_fee");
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            System.err.println("[VIEW MEMBER ERROR] Load failed: " + e.getMessage());
        }

        request.setAttribute("fid", fid);
        request.setAttribute("memberId", memberId);
        request.setAttribute("name", name);
        request.setAttribute("admissionNo", admissionNo);
        request.setAttribute("phone", phone);
        request.setAttribute("gender", gender);
        request.setAttribute("age", age);
        request.setAttribute("whatsapp", whatsapp);
        request.setAttribute("birthdayDate", birthdayDate);
        request.setAttribute("address", address);
        request.setAttribute("months", months);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("amount", amount);
        request.setAttribute("regFee", regFee);

        request.getRequestDispatcher("view_member.jsp").forward(request, response);
    }

    // ======================
    // 🔥 UPDATE + DELETE
    // ======================
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {

        String action = request.getParameter("action");
        String fid = request.getParameter("fid");

        try {
            Connection con = DatabaseUtil.getConnection();

            boolean hasBirthdayColumn = hasColumn(con, "member_details", "birthday_date");

            // ======================
            // 🔥 DELETE (DEVICE + DB)
            // ======================
            if ("delete".equals(action)) {

                // ZK device delete (existing code)
                try {
                    ActiveXComponent zk = new ActiveXComponent("zkemkeeper.ZKEM");
                    boolean isConnected = zk.invoke("Connect_Net",
                            new Variant("192.168.8.201"),
                            new Variant(4370)).getBoolean();
                    if (isConnected) {
                        zk.invoke("SSR_DeleteEnrollData", new Variant(1), new Variant(fid), new Variant(12));
                        zk.invoke("DeleteUserInfo", new Variant(1), new Variant(fid));
                        zk.invoke("RefreshData", new Variant(1));
                        zk.invoke("Disconnect");
                    }
                } catch (Exception e) {
                    System.err.println("[VIEW MEMBER ERROR] Device delete failed: " + e.getMessage());
                }

                // 🔥 1. Delete attendance_log FIRST (fingerprint_id direct)
                String q0 = "DELETE FROM attendance_log WHERE fingerprint_id=?";
                PreparedStatement ps0 = con.prepareStatement(q0);
                ps0.setString(1, fid);
                ps0.executeUpdate();
                ps0.close();

                // 2. Delete membership_details
                String q1 = "DELETE ms FROM membership_details ms " +
                        "JOIN member_details md ON ms.member_id=md.id " +
                        "WHERE md.fingerprint_id=?";
                PreparedStatement ps1 = con.prepareStatement(q1);
                ps1.setString(1, fid);
                ps1.executeUpdate();
                ps1.close();

                // 3. Delete member_details
                String q2 = "DELETE FROM member_details WHERE fingerprint_id=?";
                PreparedStatement ps2 = con.prepareStatement(q2);
                ps2.setString(1, fid);
                ps2.executeUpdate();
                ps2.close();

                response.sendRedirect("fingerprint-data?page=users");
                return;
            }

                // ======================
                // 🔥 UPDATE PERSONAL INFO
                // ======================
                if ("update".equals(action) || "updatePersonal".equals(action)) {

        // 🔥 PHOTO UPDATE PART
                Part filePart = request.getPart("photo");
                InputStream photoStream = null;

                boolean hasNewPhoto = false;

                if (filePart != null && filePart.getSize() > 0) {
                    photoStream = filePart.getInputStream();
                    hasNewPhoto = true;
                }

                String admissionNo = request.getParameter("admissionNo");
                String name = request.getParameter("name");
                String phone = request.getParameter("phone");
                String gender = request.getParameter("gender");
                int age = Integer.parseInt(request.getParameter("age"));
                String whatsapp = request.getParameter("whatsapp");
                        String birthdayDate = request.getParameter("birthdayDate");
                        String address = request.getParameter("address");

                // 🔥 update member
                String q1;

                if (hasBirthdayColumn) {
                    if (hasNewPhoto) {
                        q1 = "UPDATE member_details SET admission_no=?, full_name=?, phone=?, gender=?, age=?, whatsapp=?, birthday_date=?, address=?, photo=? WHERE fingerprint_id=?";
                    } else {
                        q1 = "UPDATE member_details SET admission_no=?, full_name=?, phone=?, gender=?, age=?, whatsapp=?, birthday_date=?, address=? WHERE fingerprint_id=?";
                    }
                } else {
                    if (hasNewPhoto) {
                        q1 = "UPDATE member_details SET admission_no=?, full_name=?, phone=?, gender=?, age=?, whatsapp=?, address=?, photo=? WHERE fingerprint_id=?";
                    } else {
                        q1 = "UPDATE member_details SET admission_no=?, full_name=?, phone=?, gender=?, age=?, whatsapp=?, address=? WHERE fingerprint_id=?";
                    }
                }

                PreparedStatement ps1 = con.prepareStatement(q1);

                ps1.setString(1, admissionNo); // 🔥 FIX
                ps1.setString(2, name);
                ps1.setString(3, phone);
                ps1.setString(4, gender);
                ps1.setInt(5, age);
                ps1.setString(6, whatsapp);
                if (hasBirthdayColumn) {
                    ps1.setString(7, birthdayDate);
                    ps1.setString(8, address);
                    if (hasNewPhoto) {
                        ps1.setBlob(9, photoStream);
                        ps1.setString(10, fid);
                    } else {
                        ps1.setString(9, fid);
                    }
                } else {
                    ps1.setString(7, address);
                    if (hasNewPhoto) {
                        ps1.setBlob(8, photoStream);
                        ps1.setString(9, fid);
                    } else {
                        ps1.setString(8, fid);
                    }
                }

                ps1.executeUpdate();


                response.sendRedirect("view-member?fid=" + fid);
            }

        } catch (Exception e) {
            System.err.println("[VIEW MEMBER ERROR] Update/delete failed: " + e.getMessage());
        }
    }

    private boolean hasColumn(Connection con, String tableName, String columnName) throws SQLException {
        DatabaseMetaData metaData = con.getMetaData();
        try (ResultSet columns = metaData.getColumns(con.getCatalog(), null, tableName, columnName)) {
            return columns.next();
        }
    }
}