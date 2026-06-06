<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> recentPayments = (List<Map<String, Object>>) request.getAttribute("recentPayments");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment History – City Gym</title>
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
            --green:    #00c860;
            --green-bg: rgba(0,180,80,0.10);
            --green-br: rgba(0,180,80,0.22);
            --blue:     #3b9eff;
            --blue-bg:  rgba(0,120,212,0.10);
            --blue-br:  rgba(0,120,212,0.22);
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
            margin-bottom: 22px;
            animation: fadeUp 0.4s ease both;
            flex-wrap: wrap;
            gap: 12px;
        }
        .page-header-left { display: flex; align-items: center; gap: 12px; }
        .page-header-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px;
            box-shadow: 0 6px 16px var(--red-glow);
        }
        .page-header-text h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 28px; letter-spacing: 2px;
        }
        .page-header-text h2 span { color: var(--red); }
        .page-header-text p { font-size: 13px; color: var(--muted); margin-top: 2px; }

        /* ── MONTH SELECTOR ── */
        .month-selector-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
            animation: fadeUp 0.4s 0.05s ease both;
        }
        .month-selector-label {
            font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            color: var(--muted);
        }
        .month-nav-btn {
            width: 34px; height: 34px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--muted);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px;
            transition: all 0.18s;
        }
        .month-nav-btn:hover {
            border-color: rgba(232,0,13,0.35);
            color: #ccc;
            background: var(--surface2);
        }
        .month-display {
            padding: 7px 18px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: var(--surface2);
            font-size: 14px; font-weight: 600;
            color: #ddd;
            min-width: 140px;
            text-align: center;
            letter-spacing: 0.3px;
        }
        .btn-today {
            padding: 7px 16px;
            border-radius: 10px;
            border: 1px solid rgba(232,0,13,0.3);
            background: rgba(232,0,13,0.08);
            color: var(--red);
            font-size: 12px; font-weight: 700;
            cursor: pointer;
            transition: all 0.18s;
            letter-spacing: 0.3px;
        }
        .btn-today:hover {
            background: rgba(232,0,13,0.15);
        }

        /* ── STAT CARDS ── */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 14px;
            margin-bottom: 20px;
            animation: fadeUp 0.4s 0.07s ease both;
        }
        .stat-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px 20px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            transition: border-color 0.2s;
        }
        .stat-card:hover { border-color: rgba(255,255,255,0.12); }
        .stat-label {
            font-size: 11px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.7px;
            color: var(--muted);
            display: flex; align-items: center; gap: 7px;
        }
        .stat-label i { font-size: 12px; }
        .stat-value {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 32px;
            letter-spacing: 1px;
            line-height: 1;
        }
        .stat-sub {
            font-size: 12px; color: var(--muted);
        }

        .stat-today  { border-left: 3px solid var(--green); }
        .stat-month  { border-left: 3px solid var(--blue); }
        .stat-count-today { border-left: 3px solid #f59e0b; }
        .stat-count-month { border-left: 3px solid #a78bfa; }

        .stat-today  .stat-value { color: var(--green); }
        .stat-month  .stat-value { color: var(--blue); }
        .stat-count-today .stat-value { color: #f59e0b; }
        .stat-count-month .stat-value { color: #a78bfa; }

        /* ── TABLE CARD ── */
        .history-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            animation: fadeUp 0.4s 0.1s ease both;
        }
        .history-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
            flex-wrap: wrap; gap: 10px;
        }
        .history-title {
            display: flex; align-items: center; gap: 9px;
            font-size: 13px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.8px;
            color: var(--muted);
        }
        .history-title i { color: var(--red); }
        .row-counter { font-size: 13px; color: var(--muted); font-weight: 500; }
        .row-counter span { color: var(--red); font-weight: 700; }

        .tbl-wrap { overflow-x: auto; }

        table { width: 100%; border-collapse: collapse; font-size: 14px; }
        thead tr { background: var(--surface2); }
        thead th {
            padding: 12px 18px;
            text-align: left; font-size: 11px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.6px;
            color: var(--muted); white-space: nowrap;
        }
        thead th:first-child { padding-left: 22px; }

        tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background 0.18s;
        }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: rgba(255,255,255,0.025); }
        tbody td { padding: 13px 18px; color: #ccc; vertical-align: middle; }
        tbody td:first-child { padding-left: 22px; color: var(--muted); font-size: 13px; }

        .row-num {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 16px; color: #333;
        }
        .member-name-cell { font-weight: 600; color: #e8e8e8; }
        .amount-cell {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 18px; color: var(--red); letter-spacing: 0.5px;
        }
        .pkg-pill {
            display: inline-block;
            background: rgba(232,0,13,0.10); color: var(--red);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
            border: 1px solid rgba(232,0,13,0.20);
        }
        .pkg-pill.oneday {
            background: rgba(0,120,212,0.10); color: var(--blue);
            border-color: rgba(0,120,212,0.22);
        }
        .date-chip {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 13px; color: #aaa;
        }
        .date-chip i { color: #444; font-size: 11px; }
        .status-completed {
            display: inline-block;
            background: var(--green-bg); color: var(--green);
            border: 1px solid var(--green-br);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }
        .status-failed {
            display: inline-block;
            background: rgba(232,0,13,0.10); color: var(--red);
            border: 1px solid rgba(232,0,13,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }

        /* hidden rows */
        tr.ph-hidden { display: none !important; }

        .empty-state {
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            padding: 60px 20px; gap: 12px; color: var(--muted);
        }
        .empty-state i { font-size: 36px; opacity: 0.3; }
        .empty-state p { font-size: 15px; }

        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

        @media (max-width: 820px) { body { padding: 20px 16px; } }
    </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-left">
        <div class="page-header-icon"><i class="fa-solid fa-credit-card"></i></div>
        <div class="page-header-text">
            <h2>Payment <span>History</span></h2>
            <p>Monthly income overview and payment records</p>
        </div>
    </div>

    <!-- MONTH NAVIGATOR -->
    <div class="month-selector-wrap">
        <span class="month-selector-label"><i class="fa-solid fa-calendar-days" style="margin-right:4px;"></i>Month</span>
        <button class="month-nav-btn" onclick="changeMonth(-1)" title="Previous month">
            <i class="fa-solid fa-chevron-left"></i>
        </button>
        <div class="month-display" id="monthDisplay">—</div>
        <button class="month-nav-btn" onclick="changeMonth(1)" title="Next month">
            <i class="fa-solid fa-chevron-right"></i>
        </button>
        <button class="btn-today" onclick="goToCurrentMonth()">
            <i class="fa-solid fa-rotate-left" style="margin-right:5px;"></i>Current
        </button>
    </div>
</div>

<!-- STAT CARDS -->
<div class="stat-grid">
    <div class="stat-card stat-today">
        <div class="stat-label"><i class="fa-solid fa-sun" style="color:#00c860;"></i> Today's Income</div>
        <div class="stat-value" id="statTodayIncome">Rs. 0</div>
        <div class="stat-sub" id="statTodaySub">0 payments today</div>
    </div>
    <div class="stat-card stat-month">
        <div class="stat-label"><i class="fa-solid fa-calendar" style="color:#3b9eff;"></i> <span id="statMonthLabel">Month</span> Income</div>
        <div class="stat-value" id="statMonthIncome">Rs. 0</div>
        <div class="stat-sub" id="statMonthSub">0 payments this month</div>
    </div>
    <div class="stat-card stat-count-today">
        <div class="stat-label"><i class="fa-solid fa-users" style="color:#f59e0b;"></i> Today's Members</div>
        <div class="stat-value" id="statTodayCount">0</div>
        <div class="stat-sub">New / renewed today</div>
    </div>
    <div class="stat-card stat-count-month">
        <div class="stat-label"><i class="fa-solid fa-chart-bar" style="color:#a78bfa;"></i> <span id="statMonthCountLabel">Month</span> Members</div>
        <div class="stat-value" id="statMonthCount">0</div>
        <div class="stat-sub" id="statMonthCountSub">Total for the month</div>
    </div>
</div>

<!-- PAYMENT TABLE -->
<div class="history-card">
    <div class="history-header">
        <div class="history-title">
            <i class="fa-solid fa-clock-rotate-left"></i>
            Payment Records
        </div>
        <div class="row-counter">
            Showing <span id="visibleCount">0</span> records
        </div>
    </div>

    <div class="tbl-wrap">
        <%
            boolean hasData = (recentPayments != null && !recentPayments.isEmpty());
        %>
        <% if (hasData) { %>
        <table>
            <thead>
            <tr>
                <th>#</th>
                <th>Member</th>
                <th>WhatsApp</th>
                <th>Amount</th>
                <th>Months</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody id="paymentTableBody">
            <%
                int idx = 1;
                for (Map<String, Object> payment : recentPayments) {
                    String payDateStr = String.valueOf(payment.get("paymentDate"));
                    // paymentDate format expected: yyyy-MM-dd
                    String payYearMonth = (payDateStr != null && payDateStr.length() >= 7)
                            ? payDateStr.substring(0, 7)   // "yyyy-MM"
                            : "";
                    String payDateFull = (payDateStr != null && payDateStr.length() >= 10)
                            ? payDateStr.substring(0, 10)  // "yyyy-MM-dd"
                            : payDateStr;
                    String monthsVal = String.valueOf(payment.get("months"));
                    int monthsInt = 0;
                    try { monthsInt = Integer.parseInt(monthsVal); } catch (Exception ignored) {}
                    String amountVal = String.valueOf(payment.get("amount"));
            %>
            <tr data-ym="<%= payYearMonth %>"
                data-date="<%= payDateFull %>"
                data-amount="<%= amountVal %>"
                data-status="<%= String.valueOf(payment.get("status")).toLowerCase() %>">
                <td><span class="row-num"><%= idx++ %></span></td>
                <td class="member-name-cell"><%= payment.get("fullName") %></td>
                <td><%= payment.get("whatsapp") != null ? payment.get("whatsapp") : "-" %></td>
                <td class="amount-cell">Rs. <%= amountVal %></td>
                <td>
                    <span class="pkg-pill <%= monthsInt == 0 ? "oneday" : "" %>">
                        <%= monthsInt == 0 ? "1 Day" : monthsVal + " Mo" %>
                    </span>
                </td>
                <td>
                    <span class="date-chip">
                        <i class="fa-regular fa-calendar"></i>
                        <%= payDateFull %>
                    </span>
                </td>
                <td>
                    <span class="<%= "FAILED".equalsIgnoreCase(String.valueOf(payment.get("status"))) ? "status-failed" : "status-completed" %>">
                        <%= payment.get("status") %>
                    </span>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } else { %>
        <div class="empty-state">
            <i class="fa-solid fa-receipt"></i>
            <p>No payment history yet.</p>
        </div>
        <% } %>
    </div>
</div>

<script>
    // ── State ────────────────────────────────────────────────────────────────
    const now   = new Date();
    let selYear  = now.getFullYear();
    let selMonth = now.getMonth() + 1; // 1-based

    const MONTH_NAMES = [
        '', 'January','February','March','April','May','June',
        'July','August','September','October','November','December'
    ];

    function pad(n) { return String(n).padStart(2, '0'); }

    function getTodayStr() {
        return now.getFullYear() + '-' + pad(now.getMonth()+1) + '-' + pad(now.getDate());
    }

    function getSelectedYM() {
        return selYear + '-' + pad(selMonth);
    }

    // ── Navigation ───────────────────────────────────────────────────────────
    function changeMonth(delta) {
        selMonth += delta;
        if (selMonth > 12) { selMonth = 1; selYear++; }
        if (selMonth < 1)  { selMonth = 12; selYear--; }
        render();
    }

    function goToCurrentMonth() {
        selYear  = now.getFullYear();
        selMonth = now.getMonth() + 1;
        render();
    }

    // ── Main render ──────────────────────────────────────────────────────────
    function render() {
        const ym      = getSelectedYM();           // "yyyy-MM"
        const today   = getTodayStr();             // "yyyy-MM-dd"
        const label   = MONTH_NAMES[selMonth] + ' ' + selYear;
        const isCurrentMonth = (ym === (now.getFullYear() + '-' + pad(now.getMonth()+1)));

        // Update month display
        document.getElementById('monthDisplay').textContent = label;
        document.getElementById('statMonthLabel').textContent       = isCurrentMonth ? 'This Month' : label;
        document.getElementById('statMonthCountLabel').textContent  = isCurrentMonth ? 'This Month' : label;

        const tbody = document.getElementById('paymentTableBody');

        let todayIncome = 0, todayCount = 0;
        let monthIncome = 0, monthCount = 0;
        let visible = 0;

        if (tbody) {
            const rows = tbody.querySelectorAll('tr[data-ym]');

            rows.forEach(row => {
                const rowYM     = row.getAttribute('data-ym');
                const rowDate   = row.getAttribute('data-date');
                const rowAmount = parseFloat(row.getAttribute('data-amount')) || 0;
                const rowStatus = row.getAttribute('data-status');

                const inMonth = (rowYM === ym);
                const isToday = (rowDate === today);
                const completed = (rowStatus !== 'failed');

                // Stats — count only completed payments
                if (isToday && completed)  { todayIncome += rowAmount; todayCount++; }
                if (inMonth && completed)  { monthIncome += rowAmount; monthCount++; }

                // Filter table rows by selected month
                if (inMonth) {
                    row.classList.remove('ph-hidden');
                    visible++;
                } else {
                    row.classList.add('ph-hidden');
                }
            });

            // Renumber visible rows
            let num = 1;
            rows.forEach(row => {
                if (!row.classList.contains('ph-hidden')) {
                    const el = row.querySelector('.row-num');
                    if (el) el.textContent = num++;
                }
            });
        }

        // Update stat cards
        document.getElementById('statTodayIncome').textContent = 'Rs. ' + todayIncome.toLocaleString();
        document.getElementById('statMonthIncome').textContent = 'Rs. ' + monthIncome.toLocaleString();
        document.getElementById('statTodayCount').textContent  = todayCount;
        document.getElementById('statMonthCount').textContent  = monthCount;
        document.getElementById('statTodaySub').textContent    = todayCount + ' payment' + (todayCount === 1 ? '' : 's') + ' today';
        document.getElementById('statMonthSub').textContent    = monthCount + ' payment' + (monthCount === 1 ? '' : 's') + ' in ' + label;
        document.getElementById('statMonthCountSub').textContent = 'Total for ' + label;

        const counter = document.getElementById('visibleCount');
        if (counter) counter.textContent = visible;
    }

    // Init
    render();
</script>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
