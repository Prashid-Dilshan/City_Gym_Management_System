<%@ page import="java.sql.*" %>
<%@ page import="com.example.city_gym_management_system.DatabaseUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
  String role = (String) session.getAttribute("userRole");
  if (!"admin".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html>
<head>
  <title>Dashboard</title>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    body {
      font-family: Arial;
      background-color: #f4f6f9;
      margin: 0;
    }

    .content {
      padding: 30px;
    }

    .card {
      background: white;
      padding: 20px;
      margin-bottom: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }
  </style>
</head>

<body>

<div class="content">

  <%
    int todayCount = 0;

    String[] days = new String[7];
    int[] counts = new int[7];

    try (Connection con = DatabaseUtil.getConnection()) {

      // 🔥 TODAY ATTENDANCE (DEVICE = DB SYNC)
      String q1 = "SELECT COUNT(DISTINCT fingerprint_id) FROM attendance_log WHERE DATE(scan_time)=CURDATE()";
      try (PreparedStatement ps1 = con.prepareStatement(q1);
           ResultSet rs1 = ps1.executeQuery()) {
        if(rs1.next()){
          todayCount = rs1.getInt(1);
        }
      }

      // 🔥 LAST 7 DAYS
      String q2 = "SELECT DATE(scan_time) as day, COUNT(*) as total " +
              "FROM attendance_log " +
              "WHERE scan_time >= CURDATE() - INTERVAL 7 DAY " +
              "GROUP BY DATE(scan_time)";

      try (PreparedStatement ps2 = con.prepareStatement(q2);
           ResultSet rs2 = ps2.executeQuery()) {
        int i = 0;
        while(rs2.next() && i < 7){
          days[i] = rs2.getString("day");
          counts[i] = rs2.getInt("total");
          i++;
        }
      }

    } catch(Exception e){
  %>
  <div class="card">Dashboard load error: <%= e.getMessage() %></div>
  <%
    }
  %>

  <!-- TODAY -->
  <div class="card">
    <h3>📊 Today Attendance Members</h3>
    <h1><%= todayCount %></h1>
  </div>

  <!-- CHART -->
  <div class="card">
    <h3>📈 Last 7 Days Attendance</h3>
    <canvas id="chart"></canvas>
  </div>

</div>

<script>
  const labels = [
    <% for(int i=0;i<7;i++){ %>
    "<%= days[i] != null ? days[i] : "" %>",
    <% } %>
  ];

  const data = [
    <% for(int i=0;i<7;i++){ %>
    <%= counts[i] %>,
    <% } %>
  ];

  new Chart(document.getElementById('chart'), {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Attendance',
        data: data
      }]
    }
  });
</script>

<!-- popup -->
<script src="attendance-popup.js"></script>

</body>
</html>