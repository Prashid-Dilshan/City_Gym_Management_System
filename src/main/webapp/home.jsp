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

<%
  int todayCount   = 0;
  int totalMembers = 0;
  int activeMemberships = 0;
  double weeklyAvg = 0.0;

  String[] days   = new String[7];
  int[]    counts = new int[7];

  try (Connection con = DatabaseUtil.getConnection()) {

    // Today attendance
    String q1 = "SELECT COUNT(DISTINCT fingerprint_id) FROM attendance_log WHERE DATE(scan_time)=CURDATE()";
    try (PreparedStatement ps = con.prepareStatement(q1); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) todayCount = rs.getInt(1);
    }

    // Last 7 days
    String q2 = "SELECT DATE(scan_time) as day, COUNT(*) as total " +
            "FROM attendance_log WHERE scan_time >= CURDATE() - INTERVAL 7 DAY " +
            "GROUP BY DATE(scan_time) ORDER BY day DESC";
    try (PreparedStatement ps = con.prepareStatement(q2); ResultSet rs = ps.executeQuery()) {
      int i = 0;
      while (rs.next() && i < 7) {
        days[i]   = rs.getString("day");
        counts[i] = rs.getInt("total");
        i++;
      }
    }

    // Total members
    String q3 = "SELECT COUNT(*) FROM members";
    try (PreparedStatement ps = con.prepareStatement(q3); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) totalMembers = rs.getInt(1);
    }

    // Active memberships
    String q4 = "SELECT COUNT(*) FROM memberships WHERE status='active'";
    try (PreparedStatement ps = con.prepareStatement(q4); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) activeMemberships = rs.getInt(1);
    }

    // Weekly average attendance
    String q5 = "SELECT AVG(daily_count) FROM " +
            "(SELECT COUNT(*) as daily_count FROM attendance_log " +
            "WHERE scan_time >= CURDATE() - INTERVAL 7 DAY GROUP BY DATE(scan_time)) t";
    try (PreparedStatement ps = con.prepareStatement(q5); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) weeklyAvg = rs.getDouble(1);
    }

  } catch (Exception e) {
    out.println("<!-- DB Error: " + e.getMessage() + " -->");
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Home – Dashboard</title>
  <meta http-equiv="refresh" content="30">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

  <style>
    :root {
      --red:      #e8000d;
      --red-dim:  #9a0008;
      --red-glow: rgba(232,0,13,0.22);
      --bg:       #0a0a0a;
      --surface:  #111111;
      --surface2: #161616;
      --border:   rgba(255,255,255,0.07);
      --text:     #f0f0f0;
      --muted:    #5a5a5a;
    }

    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

    body {
      font-family: 'Outfit', sans-serif;
      background: var(--bg);
      color: var(--text);
      padding: 24px 28px;
      min-height: 100vh;
      overflow-y: auto;
    }

    /* ── TODAY ATTENDANCE BANNER ── */
    .today-banner {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 22px 28px;
      display: flex;
      align-items: center;
      gap: 20px;
      margin-bottom: 22px;
      position: relative;
      overflow: hidden;
      animation: fadeUp 0.5s ease both;
    }

    /* Watermark logo inside banner */
    .today-banner::after {
      content: '';
      position: absolute;
      right: 28px; top: 50%;
      transform: translateY(-50%);
      width: 180px; height: 90px;
      background: url('img/logo.png') no-repeat center / contain;
      opacity: 0.06;
      pointer-events: none;
    }

    .banner-icon {
      width: 62px; height: 62px;
      border-radius: 50%;
      background: rgba(232,0,13,0.15);
      border: 2px solid rgba(232,0,13,0.35);
      display: flex; align-items: center; justify-content: center;
      color: var(--red);
      font-size: 24px;
      flex-shrink: 0;
      box-shadow: 0 0 18px rgba(232,0,13,0.18);
    }

    .banner-divider {
      width: 1px;
      height: 56px;
      background: var(--border);
      margin: 0 10px;
    }

    .banner-info .label {
      font-size: 14px;
      color: #888;
      font-weight: 500;
      margin-bottom: 4px;
      letter-spacing: 0.3px;
    }
    .banner-info .value {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 48px;
      line-height: 1;
      color: var(--red);
      letter-spacing: 2px;
    }

    /* ── CHART CARD ── */
    .chart-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 22px 28px;
      margin-bottom: 22px;
      position: relative;
      overflow: hidden;
      animation: fadeUp 0.5s 0.1s ease both;
    }

    /* Watermark inside chart */
    .chart-watermark {
      position: absolute;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 320px; height: 160px;
      background: url('img/logo.png') no-repeat center / contain;
      opacity: 0.04;
      pointer-events: none;
      z-index: 0;
    }

    .chart-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
      position: relative; z-index: 1;
    }

    .chart-title {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 17px;
      font-weight: 600;
    }
    .chart-title i { color: var(--red); }

    .period-select {
      display: flex;
      align-items: center;
      gap: 8px;
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 8px 14px;
      color: #aaa;
      font-family: 'Outfit', sans-serif;
      font-size: 13px;
      cursor: pointer;
      outline: none;
      transition: 0.2s;
    }
    .period-select:hover { border-color: rgba(232,0,13,0.4); color: #fff; }

    .chart-wrap {
      position: relative; z-index: 1;
      height: 280px;
    }

    /* ── STAT CARDS ── */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
      animation: fadeUp 0.5s 0.2s ease both;
    }

    .stat-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 20px 22px;
      display: flex;
      align-items: center;
      gap: 16px;
      position: relative;
      overflow: hidden;
      transition: border-color 0.25s, transform 0.25s;
    }
    .stat-card:hover {
      border-color: rgba(232,0,13,0.35);
      transform: translateY(-2px);
    }

    /* Faint watermark per card */
    .stat-card::after {
      content: '';
      position: absolute;
      right: 10px; bottom: 8px;
      width: 64px; height: 64px;
      background: url('img/logo.png') no-repeat center / contain;
      opacity: 0.05;
      pointer-events: none;
    }

    .stat-icon {
      width: 52px; height: 52px;
      border-radius: 12px;
      background: linear-gradient(135deg, var(--red) 0%, var(--red-dim) 100%);
      display: flex; align-items: center; justify-content: center;
      color: #fff;
      font-size: 20px;
      flex-shrink: 0;
      box-shadow: 0 6px 18px rgba(232,0,13,0.28);
    }

    .stat-info .stat-label {
      font-size: 12px;
      color: #666;
      font-weight: 500;
      margin-bottom: 4px;
      text-transform: uppercase;
      letter-spacing: 0.4px;
    }
    .stat-info .stat-value {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 34px;
      letter-spacing: 1px;
      line-height: 1;
    }

    /* ── ANIMATIONS ── */
    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(18px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* ── RESPONSIVE ── */
    @media (max-width: 900px) {
      .stats-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 560px) {
      body { padding: 16px; }
      .stats-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
    }
  </style>
</head>
<body>

<!-- TODAY BANNER -->
<div class="today-banner">
  <div class="banner-icon">
    <i class="fa-solid fa-users"></i>
  </div>
  <div class="banner-divider"></div>
  <div class="banner-info">
    <div class="label">Today Attendance Members</div>
    <div class="value"><%= todayCount %></div>
  </div>
</div>

<!-- CHART -->
<div class="chart-card">
  <div class="chart-watermark"></div>
  <div class="chart-header">
    <div class="chart-title">
      <i class="fa-solid fa-chart-bar"></i>
      Last 7 Days Attendance
    </div>
    <select class="period-select">
      <option>&#128197; Last 7 Days</option>
      <option>&#128197; Last 30 Days</option>
    </select>
  </div>
  <div class="chart-wrap">
    <canvas id="attendanceChart"></canvas>
  </div>
</div>

<!-- STAT CARDS -->
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-icon"><i class="fa-solid fa-users"></i></div>
    <div class="stat-info">
      <div class="stat-label">Total Members</div>
      <div class="stat-value"><%= totalMembers %></div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-icon"><i class="fa-solid fa-circle-check"></i></div>
    <div class="stat-info">
      <div class="stat-label">Today Attendance</div>
      <div class="stat-value" style="color:var(--red);"><%= todayCount %></div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-icon"><i class="fa-solid fa-chart-line"></i></div>
    <div class="stat-info">
      <div class="stat-label">Weekly Avg Attendance</div>
      <div class="stat-value"><%= String.format("%.2f", weeklyAvg) %></div>
    </div>
  </div>
  <div class="stat-card">
    <div class="stat-icon"><i class="fa-solid fa-id-card"></i></div>
    <div class="stat-info">
      <div class="stat-label">Active Memberships</div>
      <div class="stat-value"><%= activeMemberships %></div>
    </div>
  </div>
</div>

<script>
  const labels = [
    <% for(int i = 0; i < 7; i++) { %>
    "<%= (days[i] != null ? days[i] : "") %>",
    <% } %>
  ];
  const dataPoints = [
    <% for(int i = 0; i < 7; i++) { %>
    <%= counts[i] %>,
    <% } %>
  ];

  const ctx = document.getElementById('attendanceChart').getContext('2d');

  // Red gradient fill under bars
  const gradient = ctx.createLinearGradient(0, 0, 0, 280);
  gradient.addColorStop(0,   'rgba(232,0,13,0.85)');
  gradient.addColorStop(1,   'rgba(232,0,13,0.25)');

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Attendance',
        data: dataPoints,
        backgroundColor: gradient,
        borderColor: 'rgba(232,0,13,0.9)',
        borderWidth: 0,
        borderRadius: 6,
        borderSkipped: false,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'top',
          align: 'end',
          labels: {
            color: '#888',
            font: { family: 'Outfit', size: 12 },
            boxWidth: 28,
            boxHeight: 12,
            usePointStyle: false,
          }
        },
        tooltip: {
          backgroundColor: '#1a1a1a',
          borderColor: 'rgba(232,0,13,0.4)',
          borderWidth: 1,
          titleColor: '#fff',
          bodyColor: '#aaa',
          titleFont: { family: 'Outfit', weight: '600' },
          bodyFont:  { family: 'Outfit' },
        }
      },
      scales: {
        x: {
          grid: { color: 'rgba(255,255,255,0.04)' },
          ticks: { color: '#666', font: { family: 'Outfit', size: 12 } },
          border: { display: false }
        },
        y: {
          beginAtZero: true,
          grid: { color: 'rgba(255,255,255,0.06)' },
          ticks: { color: '#666', font: { family: 'Outfit', size: 12 }, stepSize: 2 },
          border: { display: false }
        }
      }
    }
  });
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
