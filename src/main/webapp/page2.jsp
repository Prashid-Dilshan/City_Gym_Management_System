<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<html>
<head>
    <title>Page 2</title>
</head>
<body>

<div class="content">
  <h2>Page 2 </h2>
  <p>Welcome</p>
</div>
<script src="attendance-popup.js"></script>
</body>
</html>
