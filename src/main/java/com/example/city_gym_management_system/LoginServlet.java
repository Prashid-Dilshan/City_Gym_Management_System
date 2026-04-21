package com.example.city_gym_management_system;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect("login.jsp");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = trimToEmpty(request.getParameter("username"));
        String password = trimToEmpty(request.getParameter("password"));
        String role = trimToEmpty(request.getParameter("role"));

        if (username.isEmpty() || password.isEmpty() || role.isEmpty()) {
            request.setAttribute("error", "Please enter username, password, and role.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);

        // Admin check
        if ("admin".equals(role) && "admin".equals(username) && "12345".equals(password)) {

            session.setAttribute("userRole", "admin");
            response.sendRedirect("admin_dashboard.jsp");

        }
        // Staff check
        else if ("staff".equals(role) && "s".equals(username) && "1".equals(password)) {

            session.setAttribute("userRole", "staff");
            response.sendRedirect("staff_dashboard.jsp");

        }
        // Invalid login
        else {
            request.setAttribute("error", "Invalid credentials!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}