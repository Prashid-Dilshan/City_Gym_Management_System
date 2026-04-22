<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (request.getAttribute("members") == null) {
        response.sendRedirect("member-payment");
        return;
    }

    List<Map<String, Object>> members = (List<Map<String, Object>>) request.getAttribute("members");
    List<Map<String, Object>> recentPayments = (List<Map<String, Object>>) request.getAttribute("recentPayments");
    Map<String, Object> selectedMember = (Map<String, Object>) request.getAttribute("selectedMember");
    int selectedMemberId = selectedMember != null && selectedMember.get("id") != null
            ? (Integer) selectedMember.get("id")
            : -1;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Membership & Payment – City Gym</title>
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

        /* ── TOP GRID ── */
        .top-grid {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 18px;
            margin-bottom: 18px;
            animation: fadeUp 0.4s 0.06s ease both;
        }

        /* ── CARDS ── */
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

        /* ── FORM ── */
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
            margin-bottom: 14px;
        }
        .form-group label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted);
        }
        .form-group input,
        .form-group select {
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 11px 14px;
            color: var(--text);
            font-family: 'Outfit', sans-serif;
            font-size: 14px;
            outline: none;
            transition: 0.2s;
            width: 100%;
        }
        .form-group input:focus,
        .form-group select:focus {
            border-color: rgba(232,0,13,0.55);
            box-shadow: 0 0 0 3px rgba(232,0,13,0.10);
        }
        .form-group input::placeholder { color: #333; }
        .form-group select option { background: #1a1a1a; }
        .form-group input[readonly] { opacity: 0.5; cursor: not-allowed; }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        /* ── SUBMIT BUTTON ── */
        .submit-btn {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            color: #fff;
            font-family: 'Outfit', sans-serif;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            margin-top: 6px;
            transition: all 0.2s;
            box-shadow: 0 6px 18px var(--red-glow);
            position: relative;
            overflow: hidden;
        }
        .submit-btn:hover { transform: translateY(-2px); box-shadow: 0 10px 24px var(--red-glow); }
        .submit-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

        /* Shine sweep */
        .submit-btn::after {
            content: '';
            position: absolute;
            top: 0; left: -75%; width: 50%; height: 100%;
            background: linear-gradient(120deg, transparent, rgba(255,255,255,0.15), transparent);
            transform: skewX(-20deg);
            transition: left 0.5s;
        }
        .submit-btn:hover::after { left: 150%; }

        /* ── MEMBER SUMMARY ── */
        .summary-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .summary-item {
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 12px 14px;
        }
        .summary-item .s-label {
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted);
            margin-bottom: 5px;
        }
        .summary-item .s-value {
            font-size: 15px;
            font-weight: 600;
            color: #ddd;
        }

        .status-active {
            display: inline-block;
            background: rgba(0,180,80,0.12);
            color: #00c860;
            border: 1px solid rgba(0,180,80,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }
        .status-expired {
            display: inline-block;
            background: rgba(232,0,13,0.10);
            color: var(--red);
            border: 1px solid rgba(232,0,13,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }
        .status-warning {
            display: inline-block;
            background: rgba(255,160,0,0.10);
            color: #ffa000;
            border: 1px solid rgba(255,160,0,0.22);
            font-size: 12px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
        }

        .empty-summary {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
            padding: 30px 0;
            color: var(--muted);
            font-size: 14px;
            text-align: center;
        }
        .empty-summary i { font-size: 32px; opacity: 0.25; }

        /* ── PAYMENT HISTORY TABLE ── */
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

        .empty-row td {
            text-align: center;
            padding: 40px;
            color: var(--muted);
        }
        .empty-row td i { font-size: 28px; display: block; margin-bottom: 8px; opacity: 0.25; }

        /* ── ANIMATION ── */
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

        @media (max-width: 820px) {
            .top-grid { grid-template-columns: 1fr; }
            .form-row { grid-template-columns: 1fr; }
            .summary-grid { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-icon"><i class="fa-solid fa-credit-card"></i></div>
    <div class="page-header-text">
        <h2>Membership &amp; <span>Payment</span></h2>
        <p>Record payments and send WhatsApp receipts automatically</p>
    </div>
</div>

<!-- TOP GRID -->
<div class="top-grid">

    <!-- RECORD PAYMENT -->
    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-plus-circle"></i> Record a Payment
        </div>

        <form id="paymentForm" method="post">

            <div class="form-group">
                <label>Member</label>
                <select id="memberId" name="memberId" required onchange="goToMember(this.value)">
                    <option value="">— Select a member —</option>
                    <% for (Map<String, Object> member : members) { %>
                    <option value="<%= member.get("id") %>"
                            <%= ((Integer) member.get("id") == selectedMemberId) ? "selected" : "" %>>
                        <%= member.get("fullName") %> (<%= member.get("fingerprintId") %>)
                    </option>
                    <% } %>
                </select>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Amount (Rs.)</label>
                    <input type="number" id="amount" name="amount" step="0.01" min="0" placeholder="0.00" required>
                </div>
                <div class="form-group">
                    <label>Months</label>
                    <input type="number" id="months" name="months" min="1" max="12" placeholder="1" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Start Date</label>
                    <input type="date" id="startDate" name="startDate" required>
                </div>
                <div class="form-group">
                    <label>End Date</label>
                    <input type="date" id="endDate" name="endDate" readonly>
                </div>
            </div>

            <button type="submit" class="submit-btn" id="submitBtn">
                <i class="fa-brands fa-whatsapp"></i>
                Save Payment &amp; Send WhatsApp Receipt
            </button>

        </form>
    </div>

    <!-- MEMBER SUMMARY -->
    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-user"></i> Selected Member Summary
        </div>

        <% if (selectedMember != null) {
            String daysLeftVal = String.valueOf(selectedMember.get("daysLeft"));
            String statusClass;
            if ("Expired".equalsIgnoreCase(daysLeftVal)) {
                statusClass = "status-expired";
            } else {
                try {
                    int d = Integer.parseInt(daysLeftVal.replace(" days","").trim());
                    statusClass = (d <= 7) ? "status-warning" : "status-active";
                } catch (Exception e2) { statusClass = "status-active"; }
            }
        %>
        <div class="summary-grid">
            <div class="summary-item">
                <div class="s-label">Full Name</div>
                <div class="s-value"><%= selectedMember.get("fullName") %></div>
            </div>
            <div class="summary-item">
                <div class="s-label">Fingerprint ID</div>
                <div class="s-value" style="color:var(--red); font-family:'Bebas Neue',sans-serif; font-size:20px; letter-spacing:1px;">
                    <%= selectedMember.get("fingerprintId") %>
                </div>
            </div>
            <div class="summary-item">
                <div class="s-label">WhatsApp</div>
                <div class="s-value"><%= selectedMember.get("whatsapp") != null ? selectedMember.get("whatsapp") : "–" %></div>
            </div>
            <div class="summary-item">
                <div class="s-label">Status</div>
                <div class="s-value">
                    <span class="<%= statusClass %>"><%= daysLeftVal %></span>
                </div>
            </div>
            <div class="summary-item">
                <div class="s-label">Package</div>
                <div class="s-value"><%= selectedMember.get("months") != null ? selectedMember.get("months") + " Months" : "–" %></div>
            </div>
            <div class="summary-item">
                <div class="s-label">End Date</div>
                <div class="s-value"><%= selectedMember.get("endDate") != null ? selectedMember.get("endDate") : "–" %></div>
            </div>
        </div>
        <% } else { %>
        <div class="empty-summary">
            <i class="fa-solid fa-user-slash"></i>
            <p>Select a member from the dropdown<br>to see their membership details.</p>
        </div>
        <% } %>
    </div>

</div>

<!-- PAYMENT HISTORY -->
<div class="history-card">
    <div class="history-header">
        <div class="history-title">
            <i class="fa-solid fa-clock-rotate-left"></i> Recent Payment History
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
                <th>Package</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            <% if (recentPayments != null && !recentPayments.isEmpty()) {
                for (Map<String, Object> payment : recentPayments) {
                    String pStatus = String.valueOf(payment.get("status"));
                    String pClass  = "status-active";
                    if ("Expired".equalsIgnoreCase(pStatus))  pClass = "status-expired";
                    else if ("Warning".equalsIgnoreCase(pStatus)) pClass = "status-warning";
            %>
            <tr>
                <td><%= payment.get("id") %></td>
                <td><span class="member-name-cell"><%= payment.get("fullName") %></span></td>
                <td><%= payment.get("whatsapp") != null ? payment.get("whatsapp") : "–" %></td>
                <td><span class="amount-cell">Rs. <%= payment.get("amount") %></span></td>
                <td><span class="pkg-pill"><%= payment.get("months") %> Mo</span></td>
                <td>
            <span class="date-chip">
              <i class="fa-regular fa-calendar"></i>
              <%= payment.get("paymentDate") %>
            </span>
                </td>
                <td><span class="<%= pClass %>"><%= pStatus %></span></td>
            </tr>
            <% } } else { %>
            <tr class="empty-row">
                <td colspan="7">
                    <i class="fa-solid fa-receipt"></i>
                    No payment history yet.
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    const memberIdSelect = document.getElementById('memberId');
    const startDateInput = document.getElementById('startDate');
    const monthsInput    = document.getElementById('months');
    const endDateInput   = document.getElementById('endDate');
    const submitBtn      = document.getElementById('submitBtn');

    function goToMember(id) {
        if (!id) return;
        window.location.href = '${pageContext.request.contextPath}/member-payment?memberId=' + encodeURIComponent(id);
    }

    function calculateEndDate() {
        if (!startDateInput.value || !monthsInput.value) return;
        const start = new Date(startDateInput.value);
        const m     = parseInt(monthsInput.value, 10);
        if (isNaN(start.getTime()) || isNaN(m)) return;
        const end = new Date(start);
        end.setMonth(end.getMonth() + m);
        endDateInput.value = end.toISOString().split('T')[0];
    }

    if (!startDateInput.value) {
        startDateInput.value = new Date().toISOString().split('T')[0];
    }

    monthsInput.addEventListener('change', calculateEndDate);
    startDateInput.addEventListener('change', calculateEndDate);
    calculateEndDate();

    let isSubmitting = false;
    document.getElementById('paymentForm').addEventListener('submit', async function (e) {
        e.preventDefault();
        if (isSubmitting) return;
        if (!memberIdSelect.value) { alert('Please select a member first.'); return; }

        isSubmitting = true;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

        calculateEndDate();

        const payload = new URLSearchParams(new FormData(this));
        const response = await fetch('${pageContext.request.contextPath}/record-payment', {
            method: 'POST',
            body: payload,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' }
        });

        const text = await response.text();
        if (response.ok && text.startsWith('OK')) {
            alert('Payment saved! WhatsApp receipt was triggered.');
            window.location.href = '${pageContext.request.contextPath}/member-payment?memberId='
                + encodeURIComponent(memberIdSelect.value);
        } else {
            alert(text || 'Failed to save payment.');
            isSubmitting = false;
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fa-brands fa-whatsapp"></i> Save Payment & Send WhatsApp Receipt';
        }
    });
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
