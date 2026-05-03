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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Active Memberships – City Gym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <style>
        :root {
            --red: #e8000d; --red-dim: #9a0008; --red-glow: rgba(232,0,13,0.20);
            --bg: #0a0a0a; --surface: #111111; --surface2: #161616;
            --border: rgba(255,255,255,0.07); --text: #f0f0f0; --muted: #555;
            --green: #00b846; --green-glow: rgba(0,184,70,0.18);
        }
        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Outfit',sans-serif; background:var(--bg); color:var(--text); padding:24px 28px; min-height:100vh; }

        .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:22px; animation:fadeUp 0.4s ease both; }
        .page-header-left { display:flex; align-items:center; gap:12px; }
        .page-header-icon { width:44px; height:44px; border-radius:12px; background:linear-gradient(135deg,var(--green),#006e2a); display:flex; align-items:center; justify-content:center; color:#fff; font-size:18px; box-shadow:0 6px 16px var(--green-glow); }
        .page-header h2 { font-family:'Bebas Neue',sans-serif; font-size:28px; letter-spacing:2px; }
        .page-header h2 span { color:var(--green); }

        .back-btn { display:inline-flex; align-items:center; gap:7px; padding:8px 16px; border-radius:10px; background:rgba(255,255,255,0.05); border:1px solid var(--border); color:#888; text-decoration:none; font-size:13px; font-weight:500; transition:0.2s; }
        .back-btn:hover { color:#fff; border-color:rgba(255,255,255,0.15); background:rgba(255,255,255,0.08); }

        /* Stats row */
        .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:14px; margin-bottom:20px; animation:fadeUp 0.4s 0.04s ease both; }
        .stat-mini { background:var(--surface); border:1px solid var(--border); border-radius:14px; padding:16px 20px; display:flex; align-items:center; gap:14px; }
        .stat-mini-icon { width:42px; height:42px; border-radius:10px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:16px; flex-shrink:0; }
        .ic-green  { background:linear-gradient(135deg,#00b846,#006e2a); box-shadow:0 4px 14px rgba(0,184,70,0.22); }
        .ic-orange { background:linear-gradient(135deg,#ff6600,#b34400); box-shadow:0 4px 14px rgba(255,102,0,0.22); }
        .ic-blue   { background:linear-gradient(135deg,#0088ff,#0050b3); box-shadow:0 4px 14px rgba(0,136,255,0.22); }
        .stat-mini-label { font-size:11px; color:#666; font-weight:600; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:3px; }
        .stat-mini-value { font-family:'Bebas Neue',sans-serif; font-size:28px; letter-spacing:1px; line-height:1; }
        .cv-green  { color:#00c860; }
        .cv-orange { color:#ffa000; }
        .cv-blue   { color:#4db8ff; }

        /* Controls */
        .controls-row { display:flex; align-items:center; gap:12px; margin-bottom:16px; flex-wrap:wrap; animation:fadeUp 0.4s 0.06s ease both; }
        .search-wrap { display:flex; align-items:center; gap:10px; background:var(--surface); border:1px solid var(--border); border-radius:12px; padding:10px 16px; flex:1; min-width:200px; max-width:360px; transition:0.2s; }
        .search-wrap:focus-within { border-color:rgba(0,184,70,0.45); box-shadow:0 0 0 3px rgba(0,184,70,0.08); }
        .search-wrap i { color:var(--green); font-size:14px; flex-shrink:0; }
        .search-wrap input { background:transparent; border:none; outline:none; color:var(--text); font-family:'Outfit',sans-serif; font-size:14px; width:100%; }
        .search-wrap input::placeholder { color:#3a3a3a; }

        .sort-select { background:var(--surface); border:1px solid var(--border); border-radius:12px; padding:10px 14px; color:#888; font-family:'Outfit',sans-serif; font-size:13px; outline:none; cursor:pointer; transition:0.2s; }
        .sort-select:focus { border-color:rgba(0,184,70,0.45); }

        .count-badge { margin-left:auto; background:rgba(0,184,70,0.08); border:1px solid rgba(0,184,70,0.18); color:#00c860; font-size:12px; font-weight:600; padding:5px 14px; border-radius:20px; white-space:nowrap; }
        .count-badge span { font-family:'Bebas Neue',sans-serif; font-size:16px; margin-left:4px; }

        /* Table card */
        .table-card { background:var(--surface); border:1px solid var(--border); border-radius:16px; overflow:hidden; animation:fadeUp 0.4s 0.08s ease both; }
        .table-card-header { display:flex; align-items:center; gap:10px; padding:18px 22px; border-bottom:1px solid var(--border); }
        .table-card-title { display:flex; align-items:center; gap:9px; font-size:14px; font-weight:600; color:#aaa; text-transform:uppercase; letter-spacing:0.7px; }
        .table-card-title i { color:var(--green); }

        .tbl-wrap { overflow-x:auto; }
        table { width:100%; border-collapse:collapse; font-size:14px; }
        thead tr { background:var(--surface2); }
        thead th { padding:12px 18px; text-align:left; font-size:11px; font-weight:600; text-transform:uppercase; letter-spacing:0.6px; color:var(--muted); white-space:nowrap; }
        thead th:first-child { padding-left:22px; border-radius:0; }
        tbody tr { border-bottom:1px solid var(--border); transition:background 0.18s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:rgba(255,255,255,0.025); }
        tbody td { padding:13px 18px; color:#ccc; vertical-align:middle; }
        tbody td:first-child { padding-left:22px; }

        .row-num { font-family:'Bebas Neue',sans-serif; font-size:15px; color:#333; }
        .adm-no  { font-family:'Bebas Neue',sans-serif; font-size:17px; color:var(--green); letter-spacing:1px; }
        .member-name { font-weight:600; color:#e8e8e8; }

        .days-chip { display:inline-flex; align-items:center; gap:6px; padding:4px 12px; border-radius:20px; font-size:12px; font-weight:700; }
        .days-safe    { background:rgba(0,184,70,0.10); color:#00c860; border:1px solid rgba(0,184,70,0.22); }
        .days-warning { background:rgba(255,160,0,0.10); color:#ffa000; border:1px solid rgba(255,160,0,0.22); }

        .pkg-chip { display:inline-block; background:rgba(0,184,70,0.10); color:#00b846; font-size:12px; font-weight:600; padding:3px 12px; border-radius:20px; border:1px solid rgba(0,184,70,0.20); white-space:nowrap; }

        .btn { display:inline-flex; align-items:center; gap:6px; padding:7px 14px; border-radius:8px; font-family:'Outfit',sans-serif; font-size:13px; font-weight:600; cursor:pointer; border:none; transition:all 0.2s; text-decoration:none; }
        .btn-ghost { background:rgba(255,255,255,0.05); color:#aaa; border:1px solid var(--border); }
        .btn-ghost:hover { background:rgba(255,255,255,0.09); color:#fff; }

        .empty-state { display:flex; flex-direction:column; align-items:center; justify-content:center; padding:60px 20px; gap:12px; color:var(--muted); }
        .empty-state i { font-size:36px; opacity:0.3; }

        tr.hidden-row { display:none !important; }

        @keyframes fadeUp { from{opacity:0;transform:translateY(14px);}to{opacity:1;transform:translateY(0);} }
        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }
    </style>
</head>
<body>

<!-- HEADER -->
<div class="page-header">
    <div class="page-header-left">
        <div class="page-header-icon"><i class="fa-solid fa-id-card"></i></div>
        <h2>Active <span>Memberships</span></h2>
    </div>
    <a href="home.jsp" class="back-btn" target="contentFrame">
        <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
    </a>
</div>

<%
    int totalActive = 0, expiringSoon = 0, expiring30 = 0;
    java.util.List<java.util.Map<String,String>> activeList = new java.util.ArrayList<>();

    try (Connection con = DatabaseUtil.getConnection()) {
        String sql =
                "SELECT md.fingerprint_id, md.admission_no, md.full_name, md.gender, md.phone, " +
                        "ms.months, ms.start_date, ms.end_date, " +
                        "DATEDIFF(ms.end_date, CURDATE()) AS days_left " +
                        "FROM member_details md " +
                        "JOIN membership_details ms ON md.id = ms.member_id " +
                        "WHERE ms.end_date >= CURDATE() " +
                        "ORDER BY ms.end_date ASC";
        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String,String> row = new java.util.LinkedHashMap<>();
                row.put("fid",       rs.getString("fingerprint_id"));
                row.put("admNo",     rs.getString("admission_no") != null ? rs.getString("admission_no") : "–");
                row.put("name",      rs.getString("full_name")    != null ? rs.getString("full_name")    : "–");
                row.put("gender",    rs.getString("gender")       != null ? rs.getString("gender")       : "–");
                row.put("phone",     rs.getString("phone")        != null ? rs.getString("phone")        : "–");
                int m = rs.getInt("months");
                row.put("package",   m == 0 ? "1 Day" : m + " Month" + (m>1?"s":""));
                row.put("startDate", rs.getString("start_date")   != null ? rs.getString("start_date")   : "–");
                row.put("endDate",   rs.getString("end_date")     != null ? rs.getString("end_date")     : "–");
                int dl = rs.getInt("days_left");
                row.put("daysLeft",  String.valueOf(dl));
                activeList.add(row);
                totalActive++;
                if (dl <= 7)  expiringSoon++;
                if (dl <= 30) expiring30++;
            }
        }
    } catch (Exception e) {
        out.println("<!-- DB Error: " + e.getMessage() + " -->");
    }
%>

<!-- STATS ROW -->
<div class="stats-row">
    <div class="stat-mini">
        <div class="stat-mini-icon ic-green"><i class="fa-solid fa-id-card"></i></div>
        <div>
            <div class="stat-mini-label">Total Active</div>
            <div class="stat-mini-value cv-green"><%= totalActive %></div>
        </div>
    </div>
    <div class="stat-mini">
        <div class="stat-mini-icon ic-orange"><i class="fa-solid fa-triangle-exclamation"></i></div>
        <div>
            <div class="stat-mini-label">Expiring This Week</div>
            <div class="stat-mini-value cv-orange"><%= expiringSoon %></div>
        </div>
    </div>
    <div class="stat-mini">
        <div class="stat-mini-icon ic-blue"><i class="fa-solid fa-calendar-days"></i></div>
        <div>
            <div class="stat-mini-label">Expiring in 30 Days</div>
            <div class="stat-mini-value cv-blue"><%= expiring30 %></div>
        </div>
    </div>
</div>

<!-- CONTROLS -->
<div class="controls-row">
    <div class="search-wrap">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" id="searchInput" placeholder="Search name or admission no..." oninput="applyFilter()">
    </div>
    <select class="sort-select" id="sortSelect" onchange="applyFilter()">
        <option value="all">All Members</option>
        <option value="7">Expiring in 7 Days</option>
        <option value="30">Expiring in 30 Days</option>
    </select>
    <div class="count-badge">Showing <span id="visibleCount"><%= totalActive %></span> members</div>
</div>

<!-- TABLE -->
<div class="table-card">
    <div class="table-card-header">
        <div class="table-card-title">
            <i class="fa-solid fa-id-card"></i> Active Members
        </div>
    </div>
    <div class="tbl-wrap">
        <% if (!activeList.isEmpty()) { %>
        <table>
            <thead>
            <tr>
                <th>#</th>
                <th>Admission No</th>
                <th>Name</th>
                <th>Gender</th>
                <th>Phone</th>
                <th>Package</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Days Left</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody id="memberTable">
            <% int idx = 1; for (java.util.Map<String,String> row : activeList) {
                int dl = Integer.parseInt(row.get("daysLeft"));
                String chipClass = dl <= 7 ? "days-chip days-warning" : "days-chip days-safe";
                String icon = dl <= 7 ? "fa-triangle-exclamation" : "fa-circle-check";
            %>
            <tr data-name="<%= row.get("name").toLowerCase() %>"
                data-adm="<%= row.get("admNo").toLowerCase() %>"
                data-days="<%= dl %>">
                <td><span class="row-num"><%= idx++ %></span></td>
                <td><span class="adm-no"><%= row.get("admNo") %></span></td>
                <td><span class="member-name"><%= row.get("name") %></span></td>
                <td><%= row.get("gender") %></td>
                <td><%= row.get("phone") %></td>
                <td><span class="pkg-chip"><%= row.get("package") %></span></td>
                <td><%= row.get("startDate") %></td>
                <td><%= row.get("endDate") %></td>
                <td>
                    <span class="<%= chipClass %>">
                        <i class="fa-solid <%= icon %>" style="font-size:10px;"></i>
                        <%= dl %> days
                    </span>
                </td>
                <td>
                    <a href="view-member?fid=<%= row.get("fid") %>" target="contentFrame" class="btn btn-ghost">
                        <i class="fa-regular fa-eye"></i> View
                    </a>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <i class="fa-solid fa-id-card"></i>
            <p>No active memberships found.</p>
        </div>
        <% } %>
    </div>
</div>

<script>
    function applyFilter() {
        const keyword = document.getElementById('searchInput').value.toLowerCase().trim();
        const sort    = document.getElementById('sortSelect').value;
        const rows    = document.querySelectorAll('#memberTable tr[data-days]');
        let visible   = 0;

        rows.forEach(function(row) {
            const name = row.getAttribute('data-name') || '';
            const adm  = row.getAttribute('data-adm')  || '';
            const days = parseInt(row.getAttribute('data-days'));

            const passSearch = !keyword || name.includes(keyword) || adm.includes(keyword);
            const passSort   = sort === 'all' || days <= parseInt(sort);

            if (passSearch && passSort) {
                row.classList.remove('hidden-row');
                visible++;
            } else {
                row.classList.add('hidden-row');
            }
        });

        document.getElementById('visibleCount').textContent = visible;

        // Renumber
        let n = 1;
        rows.forEach(function(row) {
            if (!row.classList.contains('hidden-row')) {
                const el = row.querySelector('.row-num');
                if (el) el.textContent = n++;
            }
        });
    }
</script>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
