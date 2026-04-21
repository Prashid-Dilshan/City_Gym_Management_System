<%
  String role = (String) session.getAttribute("userRole");
  if (!"staff".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>staff Dashboard</title>
</head>
<body>
<h1> staff Dashboard </h1>
<p><a href="logout">Logout</a></p>
</body>
</html>
