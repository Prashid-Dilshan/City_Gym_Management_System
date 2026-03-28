<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 3/28/2026
  Time: 3:30 PM
  To change this template use File | Settings | File Templates.
--%>

<%
  String role = (String) session.getAttribute("userRole");
  if (role == null || !role.equals("admin")) {
    response.sendRedirect("login.jsp");
  }
%>


<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>
<h1> Admin Dashboard </h1>
</body>
</html>
