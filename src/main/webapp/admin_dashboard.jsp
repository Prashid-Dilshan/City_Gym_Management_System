<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String role = (String) session.getAttribute("userRole");
  if (role == null || !role.equals("admin")) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<html>
<head>
    <title>Admin Dashboard</title>
    <style>
      body { margin:0; font-family: Arial, sans-serif; background:#0f0f0f; color:#efefef; }
      .container { padding:18px; }
      .cards { display:flex; gap:12px; flex-wrap:wrap; margin-top:12px; }
      .card { background:#171717; border:1px solid #2d2d2d; border-radius:10px; padding:16px; min-width:220px; }
      a { color:#7dff8f; text-decoration:none; }
      .footer { margin-top:18px; color:#9a9a9a; }
    </style>
</head>
<body>
<%@ include file="nav.jsp" %>
<div class="container">
  <h1>Admin Dashboard</h1>
  <div class="cards">
    <div class="card"><a href="live-scan">Open Live Scan Monitor</a></div>
    <div class="card"><a href="members">Manage Members</a></div>
    <div class="card"><a href="payments">Record Payments</a></div>
    <div class="card"><a href="alerts">Send Expiry Alerts</a></div>
  </div>
  <div class="footer">Powered by AGNOX</div>
</div>
</body>
</html>
