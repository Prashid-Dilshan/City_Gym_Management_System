package com.example.city_gym_management_system;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/member-search")
public class MemberSearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String q = request.getParameter("q");
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (q == null || q.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        StringBuilder json = new StringBuilder("[");
        String like = "%" + q.trim() + "%";

        String sql = "SELECT fingerprint_id, full_name, admission_no, gender " +
                "FROM member_details " +
                "WHERE full_name LIKE ? OR admission_no LIKE ? " +
                "LIMIT 8";

        try (Connection con = DatabaseUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, like);
            ps.setString(2, like);

            ResultSet rs = ps.executeQuery();
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{")
                        .append("\"fid\":\"").append(rs.getString("fingerprint_id")).append("\",")
                        .append("\"name\":\"").append(rs.getString("full_name").replace("\"","\\\"")).append("\",")
                        .append("\"admNo\":\"").append(rs.getString("admission_no")).append("\",")
                        .append("\"gender\":\"").append(rs.getString("gender")).append("\"")
                        .append("}");
            }
        } catch (Exception e) {
            out.print("[]");
            return;
        }

        json.append("]");
        out.print(json.toString());
    }
}