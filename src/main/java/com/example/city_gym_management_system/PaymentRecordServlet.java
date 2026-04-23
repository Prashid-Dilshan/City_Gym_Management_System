package com.example.city_gym_management_system;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/member-payment")
public class PaymentRecordServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException {
		try (Connection con = DatabaseUtil.getConnection()) {
			List<Map<String, Object>> recentPayments = loadRecentPayments(con);
			request.setAttribute("recentPayments", recentPayments);
			request.getRequestDispatcher("member_payment.jsp").forward(request, response);
		} catch (Exception e) {
			throw new ServletException("Unable to load member payment page", e);
		}
	}

	private List<Map<String, Object>> loadRecentPayments(Connection con) throws SQLException {
		String sql = "SELECT ph.id, ph.amount, ph.months, ph.payment_date, ph.status, " +
				"md.full_name, md.whatsapp " +
				"FROM payment_history ph " +
				"JOIN member_details md ON md.id = ph.member_id " +
				"ORDER BY ph.payment_date DESC, ph.id DESC LIMIT 10";

		List<Map<String, Object>> payments = new ArrayList<>();
		try (PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Map<String, Object> row = new LinkedHashMap<>();
				row.put("id", rs.getInt("id"));
				row.put("fullName", rs.getString("full_name"));
				row.put("whatsapp", rs.getString("whatsapp"));
				row.put("amount", rs.getDouble("amount"));
				row.put("months", rs.getInt("months"));
				row.put("paymentDate", rs.getString("payment_date"));
				row.put("status", rs.getString("status"));
				payments.add(row);
			}
		}
		return payments;
	}

}


