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

  double revToday  = 0.0;
  double rev7Days  = 0.0;
  double rev30Days = 0.0;

  String[] days7    = new String[7];
  int[]    counts7  = new int[7];
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

    // ── REVENUE from membership_details ──
    // Today: membership fee + registration fee where start_date = today
    String qR1 = "SELECT COALESCE(SUM(amount + registration_fee), 0) " +
            "FROM membership_details WHERE DATE(start_date) = CURDATE()";
    try (PreparedStatement ps = con.prepareStatement(qR1); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) revToday = rs.getDouble(1);
    }

    // Last 7 days
    String qR2 = "SELECT COALESCE(SUM(amount + registration_fee), 0) " +
            "FROM membership_details WHERE start_date >= CURDATE() - INTERVAL 7 DAY";
    try (PreparedStatement ps = con.prepareStatement(qR2); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) rev7Days = rs.getDouble(1);
    }

    // Last 30 days
    String qR3 = "SELECT COALESCE(SUM(amount + registration_fee), 0) " +
            "FROM membership_details WHERE start_date >= CURDATE() - INTERVAL 30 DAY";
    try (PreparedStatement ps = con.prepareStatement(qR3); ResultSet rs = ps.executeQuery()) {
      if (rs.next()) rev30Days = rs.getDouble(1);
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

    /* ── SEARCH BAR ── */
    .search-wrapper {
      position: relative;
      margin-bottom: 18px;
      animation: fadeUp 0.3s ease both;
    }
    .search-box {
      width: 100%;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 14px 44px 14px 50px;
      font-family: 'Outfit', sans-serif;
      font-size: 15px;
      color: var(--text);
      outline: none;
      transition: border-color 0.22s, box-shadow 0.22s;
    }
    .search-box:focus {
      border-color: rgba(232,0,13,0.5);
      box-shadow: 0 0 0 3px rgba(232,0,13,0.08);
    }
    .search-box::placeholder { color: #3a3a3a; }
    .search-icon-left {
      position: absolute;
      left: 18px; top: 50%;
      transform: translateY(-50%);
      color: var(--red);
      font-size: 16px;
      pointer-events: none;
    }
    .search-clear-btn {
      position: absolute;
      right: 16px; top: 50%;
      transform: translateY(-50%);
      background: none; border: none;
      color: #555; font-size: 14px;
      cursor: pointer; display: none;
      line-height: 1;
    }
    .search-clear-btn:hover { color: #999; }
    .search-results-dropdown {
      display: none;
      position: fixed;
      background: #161616;
      border: 1px solid rgba(255,255,255,0.09);
      border-radius: 14px;
      overflow: hidden;
      z-index: 99999;
      box-shadow: 0 20px 50px rgba(0,0,0,0.85);
    }
    .search-result-item {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 12px 18px;
      border-bottom: 1px solid rgba(255,255,255,0.04);
      text-decoration: none;
      transition: background 0.15s;
    }
    .search-result-item:last-child { border-bottom: none; }
    .search-result-item:hover { background: rgba(232,0,13,0.06); }
    .search-avatar {
      width: 38px; height: 38px;
      border-radius: 10px;
      background: linear-gradient(135deg, #e8000d, #9a0008);
      display: flex; align-items: center; justify-content: center;
      font-size: 13px; font-weight: 700; color: #fff;
      flex-shrink: 0;
    }
    .search-result-name { font-size: 14px; font-weight: 600; color: #f0f0f0; }
    .search-result-meta { font-size: 12px; color: #555; margin-top: 2px; }
    .search-arrow { margin-left: auto; color: #333; font-size: 12px; }
    .search-msg { padding: 20px; text-align: center; color: #444; font-size: 13px; }

    /* ── ROWS ── */
    .row1 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      margin-bottom: 14px;
    }
    .row2 {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 14px;
      margin-bottom: 14px;
    }
    .row3 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      margin-bottom: 18px;
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
    }
    .stat-card-link:hover {
      border-color: rgba(232,0,13,0.45);
      box-shadow: 0 0 0 1px rgba(232,0,13,0.15);
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
    .ic-gold   { background: linear-gradient(135deg, #ffb300, #e65c00); box-shadow: 0 5px 16px rgba(255,179,0,0.28); }
    .ic-teal   { background: linear-gradient(135deg, #00bcd4, #007b8a); box-shadow: 0 5px 16px rgba(0,188,212,0.22); }
    .ic-purple { background: linear-gradient(135deg, #8b00ff, #5500aa); box-shadow: 0 5px 16px rgba(139,0,255,0.22); }

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
    /* Revenue cards — smaller font so long Rs. values fit */
    .stat-value.rev {
      font-size: 26px;
    }
    .stat-sub { font-size: 11px; color: #444; margin-top: 4px; }

    .c-red    { color: var(--red); }
    .c-green  { color: #00c860; }
    .c-white  { color: #f0f0f0; }
    .c-gold   { color: #ffb300; }
    .c-teal   { color: #00d4e8; }
    .c-purple { color: #b060ff; }

    /* ── REVENUE SECTION DIVIDER ── */
    .section-label-row {
      display: flex;
      align-items: center;
      gap: 20px;
      margin-bottom: 12px;
      margin-top: 30px;
      animation: fadeUp 0.4s 0.10s ease both;
    }
    .section-label-row span {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: #444;
      white-space: nowrap;
    }
    .section-label-row::before,
    .section-label-row::after {
      content: '';
      flex: 1;
      height: 1px;
      background: var(--border);
    }

    /* ── CHART CARD ── */
    .chart-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 20px 24px;
      position: relative;
      overflow: hidden;
      animation: fadeUp 0.4s 0.18s ease both;
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
      .row3 { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 480px) {
      body { padding: 12px; }
      .row1, .row2, .row3 { gap: 10px; }
      .stat-value     { font-size: 28px; }
      .stat-value.rev { font-size: 22px; }
    }
  </style>
</head>
<body>

<!-- ══ MEMBER SEARCH ══ -->
<div class="search-wrapper" id="searchWrapper">
  <i class="fa-solid fa-magnifying-glass search-icon-left"></i>
  <input
          type="text"
          id="memberSearchBox"
          class="search-box"
          placeholder="Search member by name or admission number..."
          autocomplete="off"
  >
  <button class="search-clear-btn" id="searchClearBtn" onclick="clearMemberSearch()">
    <i class="fa-solid fa-xmark"></i>
  </button>
</div>
<!-- Dropdown appended to body to escape all stacking contexts -->
<div class="search-results-dropdown" id="memberSearchResults"></div>

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

  <div class="stat-card stat-card-link" onclick="navigateTo('attendance.jsp')" style="cursor:pointer;">
    <div class="stat-icon ic-red"><i class="fa-solid fa-fingerprint"></i></div>
    <div>
      <div class="stat-label">Today Attendance</div>
      <div class="stat-value c-red"><%= todayCount %></div>
      <div class="stat-sub">Click to view &rarr;</div>
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

  <div class="stat-card stat-card-link" onclick="navigateTo('active_memberships.jsp')" style="cursor:pointer;">
    <div class="stat-icon ic-green"><i class="fa-solid fa-id-card"></i></div>
    <div>
      <div class="stat-label">Active Memberships</div>
      <div class="stat-value c-green"><%= activeMemberships %></div>
      <div class="stat-sub">Click to view &rarr;</div>
    </div>
  </div>

  <div class="stat-card stat-card-link" onclick="navigateTo('expired_memberships.jsp')" style="cursor:pointer;">
    <div class="stat-icon ic-gray"><i class="fa-solid fa-calendar-xmark"></i></div>
    <div>
      <div class="stat-label">Ended Memberships</div>
      <div class="stat-value c-red"><%= endedMemberships %></div>
      <div class="stat-sub">Click to view &rarr;</div>
    </div>
  </div>

</div>

<!-- ══ ROW 4: Chart ══ -->
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

<!-- ══ ROW 3: Revenue ══ -->
<div class="section-label-row">
  <span><i class="fa-solid fa-coins" style="color:#ffb300;margin-right:5px;"></i>Revenue Collected</span>
</div>
<div class="row3">

  <div class="stat-card">
    <div>
      <div class="stat-label">Today's Revenue</div>
      <div class="stat-value rev c-gold">Rs. <%= String.format("%,.0f", revToday) %></div>
      <div class="stat-sub">Membership + Reg. fee today</div>
    </div>
  </div>

  <div class="stat-card">
    <div>
      <div class="stat-label">Last 7 Days</div>
      <div class="stat-value rev c-teal">Rs. <%= String.format("%,.0f", rev7Days) %></div>
      <div class="stat-sub">Weekly collections</div>
    </div>
  </div>

  <div class="stat-card">
    <div>
      <div class="stat-label">Last 30 Days</div>
      <div class="stat-value rev c-purple">Rs. <%= String.format("%,.0f", rev30Days) %></div>
      <div class="stat-sub">Monthly collections</div>
    </div>
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

  // ══ NAVIGATION HELPER ══
  function navigateTo(url) {
    // Try parent iframe (sidebar layout)
    try {
      var frame = window.parent.document.getElementById('contentFrame');
      if (frame) { frame.src = url; return; }
    } catch(e) {}
    // Fallback: direct navigation
    window.location.href = url;
  }

  // ══ MEMBER SEARCH LOGIC ══
  (function () {
    const box      = document.getElementById('memberSearchBox');
    const dropdown = document.getElementById('memberSearchResults');
    const clearBtn = document.getElementById('searchClearBtn');
    let timer = null;

    function positionDropdown() {
      var rect = box.getBoundingClientRect();
      dropdown.style.top   = (rect.bottom + 6) + 'px';
      dropdown.style.left  = rect.left + 'px';
      dropdown.style.width = rect.width + 'px';
    }

    box.addEventListener('input', function () {
      const q = this.value.trim();
      clearBtn.style.display = q ? 'block' : 'none';

      if (!q) {
        dropdown.style.display = 'none';
        return;
      }

      positionDropdown();
      dropdown.style.display = 'block';
      dropdown.innerHTML = '<div class="search-msg"><i class="fa-solid fa-spinner fa-spin" style="color:#e8000d;margin-right:6px;"></i>Searching...</div>';

      clearTimeout(timer);
      timer = setTimeout(function () {
        fetch('member-search?q=' + encodeURIComponent(q))
                .then(function(r) { return r.json(); })
                .then(function(data) {
                  if (!data.length) {
                    dropdown.innerHTML = '<div class="search-msg"><i class="fa-solid fa-user-slash" style="display:block;font-size:22px;margin-bottom:8px;color:#2a2a2a;"></i>No members found</div>';
                    return;
                  }
                  dropdown.innerHTML = data.map(function(m) {
                    var initials = m.name.split(' ').map(function(w){ return w[0]; }).join('').slice(0,2).toUpperCase();
                    return '<a href="view-member?fid=' + encodeURIComponent(m.fid) + '" class="search-result-item">' +
                            '<div class="search-avatar">' + initials + '</div>' +
                            '<div>' +
                            '<div class="search-result-name">' + m.name + '</div>' +
                            '<div class="search-result-meta">' + m.admNo + ' &nbsp;&middot;&nbsp; ' + m.gender + '</div>' +
                            '</div>' +
                            '<i class="fa-solid fa-arrow-right search-arrow"></i>' +
                            '</a>';
                  }).join('');
                })
                .catch(function() {
                  dropdown.innerHTML = '<div class="search-msg">Search failed. Please try again.</div>';
                });
      }, 300);
    });

    window.addEventListener('scroll', function() {
      if (dropdown.style.display === 'block') positionDropdown();
    }, true);

    window.addEventListener('resize', function() {
      if (dropdown.style.display === 'block') positionDropdown();
    });

    document.addEventListener('click', function(e) {
      if (!document.getElementById('searchWrapper').contains(e.target)) {
        dropdown.style.display = 'none';
      }
    });

    window.clearMemberSearch = function () {
      box.value = '';
      clearBtn.style.display = 'none';
      dropdown.style.display = 'none';
      box.focus();
    };
  })();
</script>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
