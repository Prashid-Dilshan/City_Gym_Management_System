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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = trimToEmpty(request.getParameter("username"));
        String password = trimToEmpty(request.getParameter("password"));

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Please enter username and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(30 * 60);

        if ("citygym".equals(username) && "gym123".equals(password)) {
            session.setAttribute("userRole", "admin");
            response.sendRedirect("admin_dashboard.jsp");
        }
        else if ("s".equals(username) && "1".equals(password)) {
            session.setAttribute("userRole", "staff");
            response.sendRedirect("staff_dashboard.jsp");
        }
        else {
            request.setAttribute("error", "Invalid credentials!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}