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
  int    todayCount        = 0;
  int    totalMembers      = 0;
  int    activeMemberships = 0;
  int    endedMemberships  = 0;
  double weeklyAvg         = 0.0;

  String[] days7   = new String[7];
  int[]    counts7 = new int[7];
  String[] days30   = new String[30];
  int[]    counts30 = new int[30];

  try (Connection con = DatabaseUtil.getConnection()) {

    // Today attendance (distinct fingerprints)
    String q1 = "SELECT COUNT(DISTINCT fingerprint_id) FROM attendance_log WHERE DATE(scan_time) = CURDATE()";
    try (PreparedStatement ps = con.prepareStatement(q1); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) todayCount = rs.getInt(1);
    }

    // Total members
    String q2 = "SELECT COUNT(*) FROM member_details";
    try (PreparedStatement ps = con.prepareStatement(q2); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) totalMembers = rs.getInt(1);
    }

    // Active memberships (end_date >= today)
    String q3 = "SELECT COUNT(*) FROM membership_details WHERE end_date >= CURDATE()";
    try (PreparedStatement ps = con.prepareStatement(q3); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) activeMemberships = rs.getInt(1);
    }

    // Ended / Expired memberships
    String q4 = "SELECT COUNT(*) FROM membership_details WHERE end_date < CURDATE()";
    try (PreparedStatement ps = con.prepareStatement(q4); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) endedMemberships = rs.getInt(1);
    }

    // Weekly average attendance
    String q5 = "SELECT AVG(daily_count) FROM " +
            "(SELECT COUNT(*) as daily_count FROM attendance_log " +
            "WHERE scan_time >= CURDATE() - INTERVAL 7 DAY " +
            "GROUP BY DATE(scan_time)) t";
    try (PreparedStatement ps = con.prepareStatement(q5); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) weeklyAvg = rs.getDouble(1);
    }

    // Last 7 days chart
    String q6 = "SELECT DATE(scan_time) as day, COUNT(*) as total " +
            "FROM attendance_log WHERE scan_time >= CURDATE() - INTERVAL 7 DAY " +
            "GROUP BY DATE(scan_time) ORDER BY day ASC";
    try (PreparedStatement ps = con.prepareStatement(q6); ResultSet rs = ps.executeQuery()) {
      int i = 0;
      while (rs.next() && i < 7) { days7[i] = rs.getString("day"); counts7[i] = rs.getInt("total"); i++; }
    }

    // Last 30 days chart
    String q7 = "SELECT DATE(scan_time) as day, COUNT(*) as total " +
            "FROM attendance_log WHERE scan_time >= CURDATE() - INTERVAL 30 DAY " +
            "GROUP BY DATE(scan_time) ORDER BY day ASC";
    try (PreparedStatement ps = con.prepareStatement(q7); ResultSet rs = ps.executeQuery()) {
      int i = 0;
      while (rs.next() && i < 30) { days30[i] = rs.getString("day"); counts30[i] = rs.getInt("total"); i++; }
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
      --muted:    #555;
    }

    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

    body {
      font-family: 'Outfit', sans-serif;
      background: var(--bg);
      color: var(--text);
      padding: 22px 26px;
      min-height: 100vh;
      overflow-y: auto;
    }

    ::-webkit-scrollbar { width:6px; }
    ::-webkit-scrollbar-track { background:transparent; }
    ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

    /* ── ROWS ── */
    .row1 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      margin-bottom: 14px;
      animation: fadeUp 0.4s ease both;
    }
    .row2 {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 14px;
      margin-bottom: 18px;
      animation: fadeUp 0.4s 0.07s ease both;
    }

    /* ── STAT CARD ── */
    .stat-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 18px 20px;
      display: flex;
      align-items: center;
      gap: 15px;
      position: relative;
      overflow: hidden;
      transition: border-color 0.22s, transform 0.22s;
    }
    .stat-card:hover {
      border-color: rgba(232,0,13,0.30);
      transform: translateY(-2px);
    }
    .stat-card::after {
      content: '';
      position: absolute;
      right: 10px; bottom: 8px;
      width: 58px; height: 58px;
      background: url('img/logo.png') no-repeat center / contain;
      opacity: 0.05;
      pointer-events: none;
    }

    .stat-icon {
      width: 50px; height: 50px;
      border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      color: #fff; font-size: 19px;
      flex-shrink: 0;
    }
    .ic-red    { background: linear-gradient(135deg, #e8000d, #9a0008); box-shadow: 0 5px 16px rgba(232,0,13,0.28); }
    .ic-blue   { background: linear-gradient(135deg, #0088ff, #0050b3); box-shadow: 0 5px 16px rgba(0,136,255,0.22); }
    .ic-orange { background: linear-gradient(135deg, #ff6600, #b34400); box-shadow: 0 5px 16px rgba(255,102,0,0.22); }
    .ic-green  { background: linear-gradient(135deg, #00b846, #006e2a); box-shadow: 0 5px 16px rgba(0,184,70,0.22); }
    .ic-gray   { background: linear-gradient(135deg, #3a3a3a, #1a1a1a); box-shadow: 0 5px 16px rgba(0,0,0,0.3); }

    .stat-label {
      font-size: 11px;
      color: #666;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 5px;
    }
    .stat-value {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 34px;
      letter-spacing: 1px;
      line-height: 1;
    }
    .stat-sub { font-size: 11px; color: #444; margin-top: 4px; }

    .c-red    { color: var(--red); }
    .c-green  { color: #00c860; }
    .c-white  { color: #f0f0f0; }

    /* ── CHART CARD ── */
    .chart-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 20px 24px;
      position: relative;
      overflow: hidden;
      animation: fadeUp 0.4s 0.14s ease both;
    }
    .chart-watermark {
      position: absolute;
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 300px; height: 150px;
      background: url('img/logo.png') no-repeat center / contain;
      opacity: 0.035;
      pointer-events: none;
      z-index: 0;
    }
    .chart-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 18px;
      position: relative; z-index: 1;
    }
    .chart-title {
      display: flex;
      align-items: center;
      gap: 9px;
      font-size: 16px;
      font-weight: 600;
    }
    .chart-title i { color: var(--red); }

    /* Toggle buttons */
    .period-toggle {
      display: flex;
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 10px;
      overflow: hidden;
    }
    .period-btn {
      padding: 7px 16px;
      font-family: 'Outfit', sans-serif;
      font-size: 12px;
      font-weight: 600;
      color: #555;
      background: transparent;
      border: none;
      cursor: pointer;
      transition: 0.2s;
      letter-spacing: 0.3px;
    }
    .period-btn.active { background: var(--red); color: #fff; }
    .period-btn:hover:not(.active) { color: #bbb; }

    .chart-wrap { position: relative; z-index: 1; height: 260px; }

    @keyframes fadeUp {
      from { opacity:0; transform:translateY(16px); }
      to   { opacity:1; transform:translateY(0); }
    }

    @media (max-width: 800px) {
      .row1 { grid-template-columns: 1fr 1fr; }
      .row2 { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 480px) {
      body { padding: 12px; }
      .row1, .row2 { gap: 10px; }
      .stat-value { font-size: 28px; }
    }
  </style>
</head>
<body>

<!-- ══ ROW 1: Total Members | Today Attendance | Weekly Avg ══ -->
<div class="row1">

  <div class="stat-card">
    <div class="stat-icon ic-blue"><i class="fa-solid fa-users"></i></div>
    <div>
      <div class="stat-label">Total Members</div>
      <div class="stat-value c-white"><%= totalMembers %></div>
      <div class="stat-sub">All registered</div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon ic-red"><i class="fa-solid fa-fingerprint"></i></div>
    <div>
      <div class="stat-label">Today Attendance</div>
      <div class="stat-value c-red"><%= todayCount %></div>
      <div class="stat-sub">Scanned today</div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon ic-orange"><i class="fa-solid fa-chart-line"></i></div>
    <div>
      <div class="stat-label">Weekly Avg Attendance</div>
      <div class="stat-value c-white"><%= String.format("%.1f", weeklyAvg) %></div>
      <div class="stat-sub">Per day / last 7 days</div>
    </div>
  </div>

</div>

<!-- ══ ROW 2: Active Memberships | Ended Memberships ══ -->
<div class="row2">

  <div class="stat-card">
    <div class="stat-icon ic-green"><i class="fa-solid fa-id-card"></i></div>
    <div>
      <div class="stat-label">Active Memberships</div>
      <div class="stat-value c-green"><%= activeMemberships %></div>
      <div class="stat-sub">End date not reached</div>
    </div>
  </div>

  <div class="stat-card">
    <div class="stat-icon ic-gray"><i class="fa-solid fa-calendar-xmark"></i></div>
    <div>
      <div class="stat-label">Ended Memberships</div>
      <div class="stat-value c-red"><%= endedMemberships %></div>
      <div class="stat-sub">Expired memberships</div>
    </div>
  </div>

</div>

<!-- ══ ROW 3: Chart ══ -->
<div class="chart-card">
  <div class="chart-watermark"></div>
  <div class="chart-header">
    <div class="chart-title">
      <i class="fa-solid fa-chart-bar"></i>
      Attendance Overview
    </div>
    <div class="period-toggle">
      <button class="period-btn active" id="btn7"  onclick="switchPeriod(7)">Last 7 Days</button>
      <button class="period-btn"        id="btn30" onclick="switchPeriod(30)">Last 30 Days</button>
    </div>
  </div>
  <div class="chart-wrap">
    <canvas id="attendanceChart"></canvas>
  </div>
</div>

<script>
  const labels7 = [<% for(int i=0;i<7;i++){%>"<%= days7[i]!=null?days7[i]:"" %>",<%}%>];
  const data7   = [<% for(int i=0;i<7;i++){%><%= counts7[i] %>,<%}%>];

  const labels30 = [<% for(int i=0;i<30;i++){%>"<%= days30[i]!=null?days30[i]:"" %>",<%}%>];
  const data30   = [<% for(int i=0;i<30;i++){%><%= counts30[i] %>,<%}%>];

  const ctx = document.getElementById('attendanceChart').getContext('2d');

  function makeGrad() {
    const g = ctx.createLinearGradient(0, 0, 0, 260);
    g.addColorStop(0, 'rgba(232,0,13,0.88)');
    g.addColorStop(1, 'rgba(232,0,13,0.18)');
    return g;
  }

  const chart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: labels7,
      datasets: [{
        label: 'Attendance',
        data: data7,
        backgroundColor: makeGrad(),
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
          position: 'top', align: 'end',
          labels: { color:'#888', font:{ family:'Outfit', size:12 }, boxWidth:24, boxHeight:10 }
        },
        tooltip: {
          backgroundColor: '#1a1a1a',
          borderColor: 'rgba(232,0,13,0.4)', borderWidth: 1,
          titleColor: '#fff', bodyColor: '#aaa',
          titleFont: { family:'Outfit', weight:'600' },
          bodyFont:  { family:'Outfit' },
        }
      },
      scales: {
        x: {
          grid: { color:'rgba(255,255,255,0.04)' },
          ticks: { color:'#666', font:{ family:'Outfit', size:11 }, maxRotation:40 },
          border: { display:false }
        },
        y: {
          beginAtZero: true,
          grid: { color:'rgba(255,255,255,0.06)' },
          ticks: { color:'#666', font:{ family:'Outfit', size:12 }, stepSize:1 },
          border: { display:false }
        }
      }
    }
  });

  function switchPeriod(days) {
    const is7 = days === 7;
    document.getElementById('btn7').classList.toggle('active', is7);
    document.getElementById('btn30').classList.toggle('active', !is7);
    chart.data.labels = is7 ? labels7 : labels30;
    chart.data.datasets[0].data = is7 ? data7 : data30;
    chart.data.datasets[0].backgroundColor = makeGrad();
    chart.update();
  }
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
