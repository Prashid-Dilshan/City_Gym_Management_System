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
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
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
			List<Map<String, Object>> members = loadMembers(con);
			List<Map<String, Object>> recentPayments = loadRecentPayments(con);

			int selectedMemberId = parseIntOrZero(request.getParameter("memberId"));
			Map<String, Object> selectedMember = findSelectedMember(members, selectedMemberId);

			request.setAttribute("members", members);
			request.setAttribute("selectedMember", selectedMember);
			request.setAttribute("recentPayments", recentPayments);
			request.getRequestDispatcher("member_payment.jsp").forward(request, response);
		} catch (Exception e) {
			throw new ServletException("Unable to load member payment page", e);
		}
	}

	private List<Map<String, Object>> loadMembers(Connection con) throws SQLException {
		String sql = "SELECT md.id, md.fingerprint_id, md.full_name, md.whatsapp, " +
				"ms.months, ms.start_date, ms.end_date, ms.status " +
				"FROM member_details md " +
				"LEFT JOIN membership_details ms ON md.id = ms.member_id " +
				"ORDER BY md.full_name";

		List<Map<String, Object>> members = new ArrayList<>();
		try (PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Map<String, Object> row = new LinkedHashMap<>();
				row.put("id", rs.getInt("id"));
				row.put("fingerprintId", rs.getString("fingerprint_id"));
				row.put("fullName", rs.getString("full_name"));
				row.put("whatsapp", rs.getString("whatsapp"));
				row.put("months", rs.getObject("months"));
				row.put("startDate", rs.getString("start_date"));
				row.put("endDate", rs.getString("end_date"));
				row.put("status", rs.getString("status"));
				row.put("daysLeft", calculateDaysLeft(rs.getString("end_date")));
				members.add(row);
			}
		}
		return members;
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

	private Map<String, Object> findSelectedMember(List<Map<String, Object>> members, int memberId) {
		if (members.isEmpty()) {
			return null;
		}

		if (memberId > 0) {
			for (Map<String, Object> member : members) {
				if (((Integer) member.get("id")) == memberId) {
					return member;
				}
			}
		}

		return members.get(0);
	}

	private int parseIntOrZero(String value) {
		try {
			return value == null || value.isBlank() ? 0 : Integer.parseInt(value);
		} catch (Exception e) {
			return 0;
		}
	}

	private String calculateDaysLeft(String endDate) {
		if (endDate == null || endDate.isBlank()) {
			return "-";
		}

		try {
			LocalDate end = LocalDate.parse(endDate);
			long days = ChronoUnit.DAYS.between(LocalDate.now(), end);
			return days < 0 ? "Expired" : days + " days";
		} catch (Exception e) {
			return "-";
		}
	}
}


