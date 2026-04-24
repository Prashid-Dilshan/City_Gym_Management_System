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
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Outfit', sans-serif;
            background: var(--bg);
            color: var(--text);
            padding: 24px 28px;
            min-height: 100vh;
        }

        .page-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 22px;
            animation: fadeUp 0.4s ease both;
        }
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
            font-size: 28px;
            letter-spacing: 2px;
        }
        .page-header-text h2 span { color: var(--red); }
        .page-header-text p { font-size: 13px; color: var(--muted); margin-top: 2px; }

        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--muted);
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--border);
        }
        .card-title i { color: var(--red); font-size: 14px; }

        .muted { color: var(--muted); }

        .history-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            overflow: hidden;
            animation: fadeUp 0.4s 0.12s ease both;
        }

        .history-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 22px;
            border-bottom: 1px solid var(--border);
        }
        .history-title {
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--muted);
        }
        .history-title i { color: var(--red); }

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

        .member-name-cell { font-weight: 600; color: #e8e8e8; }

        .amount-cell {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 18px;
            color: var(--red);
            letter-spacing: 0.5px;
        }

        .pkg-pill {
            display: inline-block;
            background: rgba(232,0,13,0.10);
            color: var(--red);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
            border: 1px solid rgba(232,0,13,0.20);
        }

        .date-chip {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 13px; color: #aaa;
        }
        .date-chip i { color: #444; font-size: 11px; }

        .status-completed {
            display: inline-block;
            background: rgba(0,180,80,0.12);
            color: #00c860;
            border: 1px solid rgba(0,180,80,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }
        .status-failed {
            display: inline-block;
            background: rgba(232,0,13,0.10);
            color: var(--red);
            border: 1px solid rgba(232,0,13,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }

        .empty-row td {
            text-align: center;
            padding: 40px;
            color: var(--muted);
        }
        .empty-row td i { font-size: 28px; display: block; margin-bottom: 8px; opacity: 0.25; }

        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

        @media (max-width: 820px) {
            body { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<div class="page-header">
    <div class="page-header-icon"><i class="fa-solid fa-credit-card"></i></div>
    <div class="page-header-text">
        <h2>Payment <span>History</span></h2>
        <p>View all recorded payments and the latest WhatsApp receipt activity</p>
    </div>
</div>

<div class="history-card">
    <div class="history-header">
        <div class="history-title">
            <i class="fa-solid fa-clock-rotate-left"></i>
            Recent Payment History
        </div>
    </div>

    <div class="tbl-wrap">
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
            <tbody>
                <% if (recentPayments != null && !recentPayments.isEmpty()) {
                    for (Map<String, Object> payment : recentPayments) { %>
                <tr>
                    <td><%= payment.get("id") %></td>
                    <td class="member-name-cell"><%= payment.get("fullName") %></td>
                    <td><%= payment.get("whatsapp") != null ? payment.get("whatsapp") : "-" %></td>
                    <td class="amount-cell">Rs. <%= payment.get("amount") %></td>
                    <td><span class="pkg-pill"><%= payment.get("months") %> Mo</span></td>
                    <td>
                        <span class="date-chip"><i class="fa-regular fa-calendar"></i><%= payment.get("paymentDate") %></span>
                    </td>
                    <td>
                        <span class="<%= "FAILED".equalsIgnoreCase(String.valueOf(payment.get("status"))) ? "status-failed" : "status-completed" %>">
                            <%= payment.get("status") %>
                        </span>
                    </td>
                </tr>
                <%  }
                } else { %>
                <tr class="empty-row">
                    <td colspan="7">
                        <i class="fa-solid fa-receipt"></i>
                        No payment history yet
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
