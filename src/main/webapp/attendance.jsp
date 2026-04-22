<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (request.getAttribute("attendanceLogs") == null) {
        response.sendRedirect("fingerprint-data?page=logs");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Logs – City Gym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

    <style>
        :root {
            --red:      #e8000d;
            --red-dim:  #9a0008;
            --red-glow: rgba(232,0,13,0.20);
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
            padding: 24px 28px;
            min-height: 100vh;
        }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            animation: fadeUp 0.4s ease both;
        }
        .page-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .page-header-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px;
            box-shadow: 0 6px 16px var(--red-glow);
        }
        .page-header h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 28px;
            letter-spacing: 2px;
        }
        .page-header h2 span { color: var(--red); }

        /* Live badge */
        .live-badge {
            display: flex;
            align-items: center;
            gap: 7px;
            background: rgba(232,0,13,0.12);
            border: 1px solid rgba(232,0,13,0.25);
            color: var(--red);
            font-size: 12px;
            font-weight: 700;
            padding: 6px 14px;
            border-radius: 20px;
            letter-spacing: 0.5px;
        }
        .live-dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: var(--red);
            animation: blink 1.2s ease-in-out infinite;
        }
        @keyframes blink {
            0%,100% { opacity: 1; }
            50%      { opacity: 0.2; }
        }

        /* ── STATUS MESSAGES ── */
        .status-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-bottom: 16px;
            animation: fadeUp 0.4s 0.05s ease both;
        }
        .status-msg {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(0,180,80,0.07);
            border: 1px solid rgba(0,180,80,0.18);
            border-left: 3px solid #00b450;
            border-radius: 10px;
            padding: 10px 16px;
            font-size: 13px;
            color: #a0d8b0;
        }
        .status-msg i { color: #00b450; }

        /* ── TABLE CARD ── */
        .table-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            animation: fadeUp 0.4s 0.08s ease both;
        }

        .table-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
        }
        .table-card-title {
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 14px;
            font-weight: 600;
            color: #aaa;
            text-transform: uppercase;
            letter-spacing: 0.7px;
        }
        .table-card-title i { color: var(--red); }

        .tbl-wrap { overflow-x: auto; }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        thead tr { background: var(--surface2); }
        thead th {
            padding: 12px 18px;
            text-align: left;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: var(--muted);
            white-space: nowrap;
        }
        thead th:first-child { padding-left: 22px; }

        tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.18s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.025); }

        tbody td {
            padding: 13px 18px;
            color: #ccc;
            vertical-align: middle;
        }
        tbody td:first-child { padding-left: 22px; color: var(--muted); font-size: 13px; }

        /* Number column */
        .row-num {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 16px;
            color: #333;
        }

        /* Admission no */
        .adm-no {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 17px;
            color: var(--red);
            letter-spacing: 1px;
        }

        /* Member name */
        .member-name { font-weight: 600; color: #e8e8e8; }

        /* Date / time chips */
        .date-chip, .time-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: #aaa;
        }
        .date-chip i, .time-chip i { color: #444; font-size: 11px; }

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.3px;
        }
        .badge-active {
            background: rgba(0,180,80,0.12);
            color: #00c860;
            border: 1px solid rgba(0,180,80,0.22);
        }
        .badge-warning {
            background: rgba(255,160,0,0.10);
            color: #ffa000;
            border: 1px solid rgba(255,160,0,0.22);
        }
        .badge-expired {
            background: rgba(232,0,13,0.10);
            color: var(--red);
            border: 1px solid rgba(232,0,13,0.22);
        }

        /* Error row */
        .error-row td {
            color: var(--red);
            font-weight: 600;
            font-size: 13px;
            padding: 10px 22px;
        }

        /* Empty state */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
            gap: 12px;
            color: var(--muted);
        }
        .empty-state i { font-size: 36px; opacity: 0.3; }
        .empty-state p { font-size: 15px; }

        /* ── ANIMATION ── */
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }
    </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-left">
        <div class="page-header-icon"><i class="fa-solid fa-chart-bar"></i></div>
        <h2>Attendance <span>Logs</span></h2>
    </div>
    <div class="live-badge">
        <span class="live-dot"></span> LIVE – Auto Refresh 5s
    </div>
</div>

<%-- STATUS MESSAGES --%>
<%
    List<String> statusLogs = (List<String>) request.getAttribute("statusLogs");
    if (statusLogs != null && !statusLogs.isEmpty()) {
%>
<div class="status-list">
    <% for (String msg : statusLogs) { %>
    <div class="status-msg">
        <i class="fa-solid fa-circle-check"></i>
        <%= msg %>
    </div>
    <% } %>
</div>
<% } %>

<%-- ATTENDANCE TABLE --%>
<%
    List<Map<String, String>> attendanceLogs =
            (List<Map<String, String>>) request.getAttribute("attendanceLogs");
    boolean hasData = (attendanceLogs != null && !attendanceLogs.isEmpty());
%>

<div class="table-card">
    <div class="table-card-header">
        <div class="table-card-title">
            <i class="fa-solid fa-fingerprint"></i>
            Fingerprint Attendance Records
        </div>
    </div>

    <div class="tbl-wrap">
        <% if (hasData) { %>
        <table>
            <thead>
            <tr>
                <th>#</th>
                <th>Admission No</th>
                <th>Name</th>
                <th>Date</th>
                <th>Time</th>
                <th>Membership Remaining</th>
            </tr>
            </thead>
            <tbody id="attendanceTable">
            <%
                int i = 1;
                for (Map<String, String> log : attendanceLogs) {

                    if (log.containsKey("error")) {
            %>
            <tr class="error-row">
                <td colspan="6">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <%= log.get("error") %>
                </td>
            </tr>
            <%
                    continue;
                }

                String logName      = log.get("name");
                String logAdmission = log.get("admission");

                if (logName == null || logName.trim().isEmpty()
                        || "Unknown".equalsIgnoreCase(logName.trim())
                        || logAdmission == null || logAdmission.trim().isEmpty()
                        || "-".equals(logAdmission.trim())) {
                    continue;
                }

                String daysLeft = log.get("daysLeft");
                String cssClass = "badge-active";
                String icon     = "fa-circle-check";

                if ("Expired".equals(daysLeft)) {
                    cssClass = "badge-expired";
                    icon     = "fa-circle-xmark";
                } else if (!"-".equals(daysLeft)) {
                    try {
                        int d = Integer.parseInt(daysLeft.replace(" days","").trim());
                        if (d <= 7) { cssClass = "badge-warning"; icon = "fa-triangle-exclamation"; }
                    } catch (Exception ignored) {}
                }
            %>
            <tr>
                <td><span class="row-num"><%= i++ %></span></td>
                <td><span class="adm-no"><%= logAdmission %></span></td>
                <td><span class="member-name"><%= logName %></span></td>
                <td>
            <span class="date-chip">
              <i class="fa-regular fa-calendar"></i>
              <%= log.get("date") %>
            </span>
                </td>
                <td>
            <span class="time-chip">
              <i class="fa-regular fa-clock"></i>
              <%= log.get("time") %>
            </span>
                </td>
                <td>
            <span class="status-badge <%= cssClass %>">
              <i class="fa-solid <%= icon %>" style="margin-right:5px; font-size:11px;"></i>
              <%= daysLeft %>
            </span>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <i class="fa-solid fa-inbox"></i>
            <p>No attendance logs found.</p>
        </div>
        <% } %>
    </div>
</div>

<script>
    function loadAttendance() {
        fetch('fingerprint-data?page=logs')
            .then(res => res.text())
            .then(html => {
                const parser = new DOMParser();
                const doc    = parser.parseFromString(html, 'text/html');
                const newTbody  = doc.querySelector("#attendanceTable");
                const currTbody = document.querySelector("#attendanceTable");
                if (newTbody && currTbody) currTbody.innerHTML = newTbody.innerHTML;
            });
    }
    setInterval(loadAttendance, 5000);
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
