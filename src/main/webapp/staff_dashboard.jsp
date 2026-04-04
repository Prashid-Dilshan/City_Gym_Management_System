<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String role = (String) session.getAttribute("userRole");
  if (role == null || !role.equals("staff")) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<html>
<head>
    <title>Staff Dashboard</title>
    <style>
      body { margin:0; font-family: Arial, sans-serif; background:#101010; color:#efefef; }
      .container { padding:18px; }
      .card { background:#171717; border:1px solid #2c2c2c; border-radius:10px; padding:16px; margin-top:12px; max-width:520px; }
      a { color:#7dff8f; text-decoration:none; }
      .footer { margin-top:18px; color:#9a9a9a; }
    </style>
</head>
<body>
<%@ include file="nav.jsp" %>
<div class="container">
  <h1>Staff Dashboard</h1>
  <div class="card">
    Use the modules from the top navigation to view members and daily activity.
  </div>
  <div class="footer">Powered by AGNOX</div>
</div>
</body>
</html>
