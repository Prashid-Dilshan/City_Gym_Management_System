<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
  String role = (String) session.getAttribute("userRole");
  if (!"admin".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Birthday Members – City Gym</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <style>
    :root {
      --red: #e8000d; --red-dim: #9a0008;
      --red-glow: rgba(232,0,13,0.20);
      --bg: #0a0a0a; --surface: #111111; --surface2: #161616;
      --border: rgba(255,255,255,0.07); --text: #f0f0f0; --muted: #555;
    }
    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
    body { font-family:'Outfit',sans-serif; background:var(--bg); color:var(--text); padding:24px 28px; min-height:100vh; }

    .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; animation:fadeUp 0.4s ease both; }
    .page-header-left { display:flex; align-items:center; gap:12px; }
    .page-header-icon { width:44px; height:44px; border-radius:12px; background:linear-gradient(135deg,var(--red),var(--red-dim)); display:flex; align-items:center; justify-content:center; color:#fff; font-size:18px; box-shadow:0 6px 16px var(--red-glow); }
    .page-header h2 { font-family:'Bebas Neue',sans-serif; font-size:28px; letter-spacing:2px; }
    .page-header h2 span { color:var(--red); }

    .stat-row { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:14px; margin-bottom:24px; animation:fadeUp 0.4s 0.05s ease both; }
    .stat-card { background:var(--surface); border:1px solid var(--border); border-radius:14px; padding:18px 20px; display:flex; flex-direction:column; gap:6px; }
    .stat-label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:0.6px; color:var(--muted); }
    .stat-value { font-family:'Bebas Neue',sans-serif; font-size:32px; letter-spacing:1px; color:var(--text); }
    .stat-value.red { color:var(--red); }
    .stat-sub { font-size:12px; color:#444; }

    .month-filter { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:20px; animation:fadeUp 0.4s 0.08s ease both; }
    .month-btn { padding:7px 16px; border-radius:20px; border:1px solid var(--border); background:var(--surface); color:#666; font-size:13px; font-weight:600; cursor:pointer; transition:0.2s; font-family:'Outfit',sans-serif; }
    .month-btn:hover { color:#fff; border-color:rgba(255,255,255,0.15); }
    .month-btn.active { background:rgba(232,0,13,0.12); border-color:rgba(232,0,13,0.35); color:var(--red); }

    .members-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:14px; animation:fadeUp 0.4s 0.1s ease both; }

    .member-card { background:var(--surface); border:1px solid var(--border); border-radius:16px; padding:18px; cursor:pointer; transition:all 0.2s; text-decoration:none; display:block; }
    .member-card:hover { border-color:rgba(232,0,13,0.35); background:rgba(232,0,13,0.03); transform:translateY(-2px); }
    .member-card-top { display:flex; align-items:center; gap:12px; margin-bottom:14px; }
    .member-avatar { width:46px; height:46px; border-radius:50%; background:rgba(232,0,13,0.12); border:2px solid rgba(232,0,13,0.25); display:flex; align-items:center; justify-content:center; font-size:18px; font-weight:700; color:var(--red); flex-shrink:0; }
    .member-avatar img { width:100%; height:100%; object-fit:cover; border-radius:50%; }
    .member-name { font-size:15px; font-weight:600; color:var(--text); margin-bottom:2px; }
    .member-id { font-size:11px; color:#444; }
    .member-divider { border:none; border-top:1px solid var(--border); margin-bottom:12px; }
    .member-info-row { display:flex; justify-content:space-between; font-size:12px; color:#555; margin-bottom:6px; }
    .member-info-row span:last-child { color:#888; font-weight:500; }
    .today-badge { display:inline-flex; align-items:center; gap:5px; background:rgba(232,0,13,0.12); border:1px solid rgba(232,0,13,0.25); color:var(--red); font-size:11px; font-weight:700; padding:4px 10px; border-radius:20px; margin-top:4px; }

    .empty-state { grid-column:1/-1; padding:48px; text-align:center; border-radius:16px; background:rgba(255,255,255,0.02); border:1px dashed var(--border); }
    .empty-state i { font-size:36px; color:#2a2a2a; display:block; margin-bottom:12px; }
    .empty-state p { color:#444; font-size:15px; }

    @keyframes fadeUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:translateY(0)} }
    ::-webkit-scrollbar { width:6px; } ::-webkit-scrollbar-track { background:transparent; } ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }
  </style>
</head>
<body>

<%
  List<Map<String, Object>> todayBirthdays   = (List<Map<String, Object>>) request.getAttribute("todayBirthdays");
  List<Map<String, Object>> monthBirthdays   = (List<Map<String, Object>>) request.getAttribute("monthBirthdays");
  List<Map<String, Object>> displayMembers   = (List<Map<String, Object>>) request.getAttribute("displayMembers");
  Integer todayCount  = (Integer) request.getAttribute("todayCount");
  Integer monthCount  = (Integer) request.getAttribute("monthCount");
  String  todayDate   = (String)  request.getAttribute("todayDate");
  String  selectedMonth = request.getParameter("month");
  if (selectedMonth == null) selectedMonth = "today";

  if (todayCount  == null) todayCount  = 0;
  if (monthCount  == null) monthCount  = 0;
  if (displayMembers == null) displayMembers = new ArrayList<>();

  String[] months = {"January","February","March","April","May","June",
          "July","August","September","October","November","December"};
%>

<div class="page-header">
  <div class="page-header-left">
    <div class="page-header-icon"><i class="fa-solid fa-cake-candles"></i></div>
    <h2>Birthday <span>Members</span></h2>
  </div>
  <div style="font-size:13px;color:#444;">
    <i class="fa-regular fa-calendar" style="margin-right:5px;"></i><%= todayDate %>
  </div>
</div>

<!-- Stats -->
<div class="stat-row">
  <div class="stat-card">
    <span class="stat-label">Today's Birthdays</span>
    <span class="stat-value red"><%= todayCount %></span>
    <span class="stat-sub">members celebrating today</span>
  </div>
  <div class="stat-card">
    <span class="stat-label">This Month</span>
    <span class="stat-value"><%= monthCount %></span>
    <span class="stat-sub">birthdays this month</span>
  </div>
</div>

<!-- Month Filter -->
<div class="month-filter">
  <button class="month-btn <%= "today".equals(selectedMonth) ? "active" : "" %>"
          onclick="location.href='birthday-members'">
    <i class="fa-solid fa-star" style="font-size:10px;"></i> Today
  </button>
  <% for (int i = 0; i < months.length; i++) { %>
  <button class="month-btn <%= String.valueOf(i+1).equals(selectedMonth) ? "active" : "" %>"
          onclick="location.href='birthday-members?month=<%= (i+1) %>'">
    <%= months[i] %>
  </button>
  <% } %>
</div>

<!-- Members Grid -->
<div class="members-grid">
  <% if (displayMembers.isEmpty()) { %>
  <div class="empty-state">
    <i class="fa-solid fa-cake-candles"></i>
    <p>No birthday members found for this period.</p>
  </div>
  <% } else {
    for (Map<String, Object> m : displayMembers) {
      boolean isToday = Boolean.TRUE.equals(m.get("isToday"));
  %>
  <a class="member-card" href="view-member?fid=<%= m.get("fid") %>" target="contentFrame">
    <div class="member-card-top">
      <div class="member-avatar">
        <img src="view-member?fid=<%= m.get("fid") %>&type=image" alt=""
             onerror="this.style.display='none';this.parentElement.textContent='<%= String.valueOf(m.get("name")).charAt(0) %>'">
      </div>
      <div>
        <div class="member-name"><%= m.get("name") %></div>
        <div class="member-id">ID: <%= m.get("admissionNo") %></div>
      </div>
    </div>
    <hr class="member-divider">
    <div class="member-info-row">
      <span><i class="fa-regular fa-calendar-days" style="margin-right:4px;"></i>Birthday</span>
      <span><%= m.get("birthdayDate") %></span>
    </div>
    <div class="member-info-row">
      <span><i class="fa-solid fa-phone" style="margin-right:4px;"></i>Phone</span>
      <span><%= m.get("phone") != null ? m.get("phone") : "–" %></span>
    </div>
    <% if (isToday) { %>
    <div class="today-badge">
      <i class="fa-solid fa-cake-candles" style="font-size:10px;"></i> Birthday Today!
    </div>
    <% } %>
  </a>
  <% } } %>
</div>

<%@ include file="footer.jsp" %>
</body>
</html>