package com.example.city_gym_management_system;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // Admin check
        if (role.equals("admin") && username.equals("addmin") && password.equals("123")) {

            request.getSession().setAttribute("userRole", "admin");
            response.sendRedirect("admin_dashboard.jsp");

        }
        // Staff check
        else if (role.equals("staff") && username.equals("staff") && password.equals("123")) {

            request.getSession().setAttribute("userRole", "staff");
            response.sendRedirect("staff_dashboard.jsp");

        }
        // Invalid login
        else {
            request.setAttribute("error", "Invalid credentials!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}