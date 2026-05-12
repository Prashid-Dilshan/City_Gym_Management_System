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

        /* ── FILTER SECTION — two rows ── */
        .filter-section {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 16px;
            animation: fadeUp 0.4s 0.06s ease both;
        }
        .filter-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-row-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--muted);
            min-width: 52px;
        }

        .filter-tab {
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 9px 20px;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--muted);
            transition: all 0.18s ease;
            user-select: none;
            letter-spacing: 0.3px;
        }
        .filter-tab i { font-size: 12px; }
        .filter-tab:hover {
            border-color: rgba(232,0,13,0.3);
            color: #ccc;
            background: var(--surface2);
        }

        /* Date tabs active = red */
        .filter-tab.date-tab.active {
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            border-color: var(--red);
            color: #fff;
            box-shadow: 0 4px 14px var(--red-glow);
        }

        /* All types tab active = neutral white */
        .filter-tab.tab-all.active {
            background: var(--surface2);
            border-color: rgba(255,255,255,0.18);
            color: #ccc;
        }

        /* One Day tab active = blue */
        .filter-tab.tab-oneday.active {
            background: linear-gradient(135deg, #0078d4, #005a9e);
            border-color: #0078d4;
            color: #fff;
            box-shadow: 0 4px 14px rgba(0,120,212,0.28);
        }

        /* Monthly tab active = purple */
        .filter-tab.tab-monthly.active {
            background: linear-gradient(135deg, #7c3aed, #5b21b6);
            border-color: #7c3aed;
            color: #fff;
            box-shadow: 0 4px 14px rgba(124,58,237,0.28);
        }

        /* count chip inside filter tab */
        .tab-count {
            background: rgba(255,255,255,0.18);
            color: #fff;
            font-size: 11px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 20px;
            min-width: 20px;
            text-align: center;
        }
        .filter-tab:not(.active) .tab-count {
            background: rgba(255,255,255,0.06);
            color: #666;
        }

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

        /* visible row counter */
        .row-counter {
            font-size: 13px;
            color: var(--muted);
            font-weight: 500;
        }
        .row-counter span {
            color: var(--red);
            font-weight: 700;
        }

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

        /* Membership type badge */
        .type-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.4px;
            margin-right: 6px;
        }
        .type-oneday {
            background: rgba(0,120,212,0.12);
            color: #3b9eff;
            border: 1px solid rgba(0,120,212,0.25);
        }
        .type-monthly {
            background: rgba(124,58,237,0.12);
            color: #a78bfa;
            border: 1px solid rgba(124,58,237,0.25);
        }

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

        /* hidden rows when filtered */
        tr.filtered-hidden { display: none !important; }

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

<!-- ═══════════════════════════════════════
     FILTER SECTION
     Row 1 : Date   — Today / 7 Days / 30 Days
     Row 2 : Type   — All / One Day / Monthly
     ═══════════════════════════════════════ -->
<div class="filter-section">

    <!-- Row 1 : Date -->
    <div class="filter-row">
        <span class="filter-row-label">
            <i class="fa-solid fa-calendar-day" style="margin-right:4px;"></i>Date
        </span>
        <div class="filter-tab date-tab active" id="tab-today" onclick="setDateFilter('today')">
            <i class="fa-solid fa-calendar-day"></i>
            Today
            <span class="tab-count" id="count-today">0</span>
        </div>
        <div class="filter-tab date-tab" id="tab-7days" onclick="setDateFilter('7days')">
            <i class="fa-solid fa-calendar-week"></i>
            Last 7 Days
            <span class="tab-count" id="count-7days">0</span>
        </div>
        <div class="filter-tab date-tab" id="tab-30days" onclick="setDateFilter('30days')">
            <i class="fa-solid fa-calendar"></i>
            Last 30 Days
            <span class="tab-count" id="count-30days">0</span>
        </div>
    </div>

    <!-- Row 2 : Membership type -->
    <div class="filter-row">
        <span class="filter-row-label">
            <i class="fa-solid fa-id-card" style="margin-right:4px;"></i>Type
        </span>
        <div class="filter-tab tab-all active" id="tab-all" onclick="setTypeFilter('all')">
            <i class="fa-solid fa-users"></i>
            All Members
            <span class="tab-count" id="count-all">0</span>
        </div>
        <div class="filter-tab tab-oneday" id="tab-oneday" onclick="setTypeFilter('oneday')">
            <i class="fa-solid fa-bolt"></i>
            One Day
            <span class="tab-count" id="count-oneday">0</span>
        </div>
        <div class="filter-tab tab-monthly" id="tab-monthly" onclick="setTypeFilter('monthly')">
            <i class="fa-solid fa-calendar-check"></i>
            Monthly
            <span class="tab-count" id="count-monthly">0</span>
        </div>
    </div>

</div>

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
        <div class="row-counter">
            Showing <span id="visibleCount">0</span> records
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
                <th>Membership Status</th>
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

                String daysLeft   = log.get("daysLeft");
                String cssClass   = "badge-active";
                String icon       = "fa-circle-check";
                String badgeLabel = daysLeft;

                if (daysLeft != null && daysLeft.startsWith("Expired")) {
                    cssClass = "badge-expired";
                    icon     = "fa-circle-xmark";
                    try {
                        String numPart = daysLeft.replaceAll("[^0-9\\-]", "").trim();
                        int expDays = Math.abs(Integer.parseInt(numPart));
                        badgeLabel = "Expired " + expDays + " day" + (expDays == 1 ? "" : "s") + " ago";
                    } catch (Exception ex) {
                        badgeLabel = daysLeft;
                    }
                } else if (daysLeft != null && !"-".equals(daysLeft)) {
                    try {
                        int d = Integer.parseInt(daysLeft.replace(" days","").trim());
                        if (d <= 7) { cssClass = "badge-warning"; icon = "fa-triangle-exclamation"; }
                        badgeLabel = d + " day" + (d == 1 ? "" : "s") + " left";
                    } catch (Exception ignored) {}
                }

                // 🔥 membership type
                String logMonthsStr = log.get("months");
                int logMonths = 0;
                try { logMonths = Integer.parseInt(logMonthsStr); } catch (Exception ignored) {}

                String typeClass = (logMonths == 0) ? "type-oneday" : "type-monthly";

                String typeLabel = (logMonths == 0)
                        ? "One Day"
                        : logMonths + " Month" + (logMonths == 1 ? "" : "s");

                String logDate = log.get("date");
            %>
            <tr data-date="<%= logDate %>" data-months="<%= logMonths %>">
                <td><span class="row-num"><%= i++ %></span></td>
                <td><span class="adm-no"><%= logAdmission %></span></td>
                <td>
                    <% if (logMonths > 0) { %>
                    <span class="type-badge <%= typeClass %>"><%= typeLabel %></span>
                    <% } %>
                    <span class="member-name"><%= logName %></span>
                </td>
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
                        <%= badgeLabel %>
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
    // ── TWO INDEPENDENT FILTERS — combined with AND ───────────────────────────
    let currentDate = 'today';   // today | 7days | 30days
    let currentType = 'all';     // all   | oneday | monthly

    function getTodayStr() {
        const d = new Date();
        return d.getFullYear() + '-' +
            String(d.getMonth() + 1).padStart(2, '0') + '-' +
            String(d.getDate()).padStart(2, '0');
    }

    function getCutoffStr(daysBack) {
        const d = new Date();
        d.setDate(d.getDate() - daysBack);
        return d.getFullYear() + '-' +
            String(d.getMonth() + 1).padStart(2, '0') + '-' +
            String(d.getDate()).padStart(2, '0');
    }

    // ── Date row setter ───────────────────────────────────────────────────────
    function setDateFilter(filter) {
        currentDate = filter;
        document.querySelectorAll('.date-tab').forEach(t => t.classList.remove('active'));
        document.getElementById('tab-' + filter).classList.add('active');
        updateTabCounts();
        applyFilter();
    }

    // ── Type row setter ───────────────────────────────────────────────────────
    function setTypeFilter(type) {
        currentType = type;
        document.querySelectorAll('.tab-all, .tab-oneday, .tab-monthly')
            .forEach(t => t.classList.remove('active'));
        document.getElementById('tab-' + type).classList.add('active');
        applyFilter();
    }

    // ── Apply both filters (AND logic) ────────────────────────────────────────
    function applyFilter() {
        const tbody = document.getElementById('attendanceTable');
        if (!tbody) return;

        const today = getTodayStr();
        const cut7  = getCutoffStr(6);
        const cut30 = getCutoffStr(29);

        const rows = tbody.querySelectorAll('tr[data-date]');
        let visible = 0;

        rows.forEach(row => {
            const rowDate   = row.getAttribute('data-date');
            const rowMonths = parseInt(row.getAttribute('data-months') || '0', 10);

            // Date check
            let dateOk = false;
            if      (currentDate === 'today')   dateOk = (rowDate === today);
            else if (currentDate === '7days')   dateOk = (rowDate >= cut7  && rowDate <= today);
            else if (currentDate === '30days')  dateOk = (rowDate >= cut30 && rowDate <= today);

            // Type check
            let typeOk = false;
            if      (currentType === 'all')     typeOk = true;
            else if (currentType === 'oneday')  typeOk = (rowMonths === 0);
            else if (currentType === 'monthly') typeOk = (rowMonths > 0);

            const show = dateOk && typeOk;

            if (show) {
                row.classList.remove('filtered-hidden');
                visible++;
            } else {
                row.classList.add('filtered-hidden');
            }
        });

        const counter = document.getElementById('visibleCount');
        if (counter) counter.textContent = visible;

        // Renumber visible rows
        let num = 1;
        rows.forEach(row => {
            if (!row.classList.contains('filtered-hidden')) {
                const numEl = row.querySelector('.row-num');
                if (numEl) numEl.textContent = num++;
            }
        });
    }

    // ── Update tab counts ─────────────────────────────────────────────────────
    // Date row  → always shows total for that range (type-agnostic)
    // Type row  → counts within the CURRENT date window only
    function updateTabCounts() {
        const tbody = document.getElementById('attendanceTable');
        if (!tbody) return;

        const today = getTodayStr();
        const cut7  = getCutoffStr(6);
        const cut30 = getCutoffStr(29);

        let cToday = 0, c7 = 0, c30 = 0;
        let cAll = 0, cOneDay = 0, cMonthly = 0;

        tbody.querySelectorAll('tr[data-date]').forEach(row => {
            const rowDate   = row.getAttribute('data-date');
            const rowMonths = parseInt(row.getAttribute('data-months') || '0', 10);

            // Date row counts (independent of type)
            if (rowDate === today)                    cToday++;
            if (rowDate >= cut7  && rowDate <= today) c7++;
            if (rowDate >= cut30 && rowDate <= today) c30++;

            // Type row counts — scoped to current date window
            let inWindow = false;
            if      (currentDate === 'today')  inWindow = (rowDate === today);
            else if (currentDate === '7days')  inWindow = (rowDate >= cut7  && rowDate <= today);
            else if (currentDate === '30days') inWindow = (rowDate >= cut30 && rowDate <= today);

            if (inWindow) {
                cAll++;
                if (rowMonths === 0) cOneDay++;
                if (rowMonths > 0)   cMonthly++;
            }
        });

        document.getElementById('count-today').textContent   = cToday;
        document.getElementById('count-7days').textContent   = c7;
        document.getElementById('count-30days').textContent  = c30;
        document.getElementById('count-all').textContent     = cAll;
        document.getElementById('count-oneday').textContent  = cOneDay;
        document.getElementById('count-monthly').textContent = cMonthly;
    }

    // ── LIVE REFRESH every 5s ─────────────────────────────────────────────────
    function loadAttendance() {
        fetch('fingerprint-data?page=logs')
            .then(res => res.text())
            .then(html => {
                const parser    = new DOMParser();
                const doc       = parser.parseFromString(html, 'text/html');
                const newTbody  = doc.querySelector('#attendanceTable');
                const currTbody = document.querySelector('#attendanceTable');
                if (newTbody && currTbody) {
                    currTbody.innerHTML = newTbody.innerHTML;
                    updateTabCounts();
                    applyFilter();
                }
            });
    }

    // Init
    updateTabCounts();
    applyFilter();
    setInterval(loadAttendance, 5000);
</script>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
