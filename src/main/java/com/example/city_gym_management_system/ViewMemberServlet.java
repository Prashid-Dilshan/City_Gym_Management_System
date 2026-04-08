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
                Connection con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/gym_system",
                        "root",
                        "1234"
                );

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
                e.printStackTrace();
            }
        }

        String name = "";
        String phone = "";
        String gender = "";
        int age = 0;
        String whatsapp = "";
        String address = "";
        int months = 0;
        String startDate = "";
        String endDate = "";
        double amount = 0;
        double regFee = 0;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gym_system",
                    "root",
                    "1234"
            );

            String sql = "SELECT * FROM member_details md " +
                    "LEFT JOIN membership_details ms ON md.id = ms.member_id " +
                    "WHERE md.fingerprint_id=?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, fid);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                name = rs.getString("full_name");
                phone = rs.getString("phone");
                gender = rs.getString("gender");
                age = rs.getInt("age");
                whatsapp = rs.getString("whatsapp");
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
            e.printStackTrace();
        }

        request.setAttribute("fid", fid);
        request.setAttribute("name", name);
        request.setAttribute("phone", phone);
        request.setAttribute("gender", gender);
        request.setAttribute("age", age);
        request.setAttribute("whatsapp", whatsapp);
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String action = request.getParameter("action");
        String fid = request.getParameter("fid");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/gym_system",
                    "root",
                    "1234"
            );

            // ======================
            // 🔥 DELETE (DEVICE + DB)
            // ======================
            if ("delete".equals(action)) {

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
                    e.printStackTrace();
                }

                String q1 = "DELETE ms FROM membership_details ms " +
                        "JOIN member_details md ON ms.member_id=md.id " +
                        "WHERE md.fingerprint_id=?";
                PreparedStatement ps1 = con.prepareStatement(q1);
                ps1.setString(1, fid);
                ps1.executeUpdate();

                String q2 = "DELETE FROM member_details WHERE fingerprint_id=?";
                PreparedStatement ps2 = con.prepareStatement(q2);
                ps2.setString(1, fid);
                ps2.executeUpdate();

                response.sendRedirect("fingerprint-data?page=users");
                return;
            }

            // ======================
            // 🔥 UPDATE
            // ======================
            if ("update".equals(action)) {


                // 🔥 PHOTO UPDATE PART
                Part filePart = request.getPart("photo");
                InputStream photoStream = null;

                boolean hasNewPhoto = false;

                if (filePart != null && filePart.getSize() > 0) {
                    photoStream = filePart.getInputStream();
                    hasNewPhoto = true;
                }

                String name = request.getParameter("name");
                String phone = request.getParameter("phone");
                String gender = request.getParameter("gender");
                int age = Integer.parseInt(request.getParameter("age"));
                String whatsapp = request.getParameter("whatsapp");
                String address = request.getParameter("address");

                int months = Integer.parseInt(request.getParameter("months"));
                String start = request.getParameter("startDate");
                String end = request.getParameter("endDate");

                double amount = Double.parseDouble(request.getParameter("amount"));
                double regFee = Double.parseDouble(request.getParameter("regFee"));

                // 🔥 update member
                String q1;

                if (hasNewPhoto) {
                    q1 = "UPDATE member_details SET full_name=?, phone=?, gender=?, age=?, whatsapp=?, address=?, photo=? WHERE fingerprint_id=?";
                } else {
                    q1 = "UPDATE member_details SET full_name=?, phone=?, gender=?, age=?, whatsapp=?, address=? WHERE fingerprint_id=?";
                }

                PreparedStatement ps1 = con.prepareStatement(q1);

                ps1.setString(1, name);
                ps1.setString(2, phone);
                ps1.setString(3, gender);
                ps1.setInt(4, age);
                ps1.setString(5, whatsapp);
                ps1.setString(6, address);

                if (hasNewPhoto) {
                    ps1.setBlob(7, photoStream);
                    ps1.setString(8, fid);
                } else {
                    ps1.setString(7, fid);
                }

                ps1.executeUpdate();

                // 🔥 update membership
                String q2 = "UPDATE membership_details ms " +
                        "JOIN member_details md ON ms.member_id=md.id " +
                        "SET ms.months=?, ms.start_date=?, ms.end_date=?, ms.amount=?, ms.registration_fee=? " +
                        "WHERE md.fingerprint_id=?";

                PreparedStatement ps2 = con.prepareStatement(q2);

                ps2.setInt(1, months);
                ps2.setString(2, start);
                ps2.setString(3, end);
                ps2.setDouble(4, amount);
                ps2.setDouble(5, regFee);
                ps2.setString(6, fid);

                ps2.executeUpdate();

                response.sendRedirect("view-member?fid=" + fid);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}