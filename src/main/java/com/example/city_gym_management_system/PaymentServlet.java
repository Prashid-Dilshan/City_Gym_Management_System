package com.example.city_gym_management_system;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/record-payment")
public class PaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int mid = Integer.parseInt(request.getParameter("memberId"));
            double amt = Double.parseDouble(request.getParameter("amount"));
            int mon = Integer.parseInt(request.getParameter("months"));
            String sd = request.getParameter("startDate");
            String ed = request.getParameter("endDate");

            try (Connection con = DatabaseUtil.getConnection()) {
                String q1 = "SELECT full_name, whatsapp FROM member_details WHERE id = ?";
                String name = null, wa = null;
                try (PreparedStatement p1 = con.prepareStatement(q1)) {
                    p1.setInt(1, mid);
                    try (ResultSet r = p1.executeQuery()) {
                        if (r.next()) { name = r.getString(1); wa = r.getString(2); }
                    }
                }
                String q2 = "INSERT INTO membership_details (member_id,months,start_date,end_date,status,amount) VALUES (?,?,?,?,?,?) ON DUPLICATE KEY UPDATE months=?,start_date=?,end_date=?,amount=?";
                try (PreparedStatement p2 = con.prepareStatement(q2)) {
                    p2.setInt(1, mid); p2.setInt(2, mon); p2.setString(3, sd); p2.setString(4, ed); p2.setString(5, "ACTIVE"); p2.setDouble(6, amt);
                    p2.setInt(7, mon); p2.setString(8, sd); p2.setString(9, ed); p2.setDouble(10, amt);
                    p2.executeUpdate();
                }
                if (wa != null && !wa.isEmpty()) WhatsAppService.sendPaymentReceipt(name, wa, amt, mon);
                response.getWriter().write("OK");
            }
        } catch (Exception e) { response.getWriter().write("ERROR: " + e.getMessage()); }
    }
}

