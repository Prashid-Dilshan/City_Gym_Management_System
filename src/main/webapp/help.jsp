<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Help – City Gym</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

    <style>
        :root {
            --red:      #e8000d;
            --red-dim:  #9a0008;
            --red-glow: rgba(232,0,13,0.18);
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
            padding: 24px 28px 40px;
            min-height: 100vh;
        }

        ::-webkit-scrollbar { width:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

        /* ── PAGE HEADER ── */
        .page-header {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 28px;
            animation: fadeUp 0.4s ease both;
        }
        .page-header-icon {
            width: 48px; height: 48px;
            border-radius: 13px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 20px;
            box-shadow: 0 6px 18px var(--red-glow);
            flex-shrink: 0;
        }
        .page-header-text h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 30px;
            letter-spacing: 2px;
        }
        .page-header-text h2 span { color: var(--red); }
        .page-header-text p { font-size: 13px; color: var(--muted); margin-top: 2px; }

        /* ── SYSTEM OVERVIEW BANNER ── */
        .overview-banner {
            background: var(--surface);
            border: 1px solid var(--border);
            border-left: 3px solid var(--red);
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 22px;
            animation: fadeUp 0.4s 0.05s ease both;
        }
        .overview-banner h3 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 20px;
            letter-spacing: 1.5px;
            color: var(--red);
            margin-bottom: 10px;
        }
        .overview-banner p {
            font-size: 14px;
            color: #aaa;
            line-height: 1.7;
        }

        /* ── FLOW STEPS ── */
        .flow-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-bottom: 26px;
            animation: fadeUp 0.4s 0.08s ease both;
        }
        .flow-step {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 13px;
            padding: 16px 14px;
            text-align: center;
            position: relative;
            transition: border-color 0.2s, transform 0.2s;
        }
        .flow-step:hover {
            border-color: rgba(232,0,13,0.35);
            transform: translateY(-3px);
        }
        .flow-step:not(:last-child)::after {
            content: '\f054';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            position: absolute;
            right: -12px; top: 50%;
            transform: translateY(-50%);
            color: #333; font-size: 11px;
            z-index: 1;
        }
        .flow-num {
            width: 26px; height: 26px;
            border-radius: 50%;
            background: var(--red);
            color: #fff;
            font-size: 12px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 10px;
        }
        .flow-icon { font-size: 22px; margin-bottom: 8px; color: var(--red); }
        .flow-label { font-size: 12px; font-weight: 600; color: #ddd; line-height: 1.4; }
        .flow-sub   { font-size: 11px; color: #555; margin-top: 4px; }

        /* ── SECTION CARDS ── */
        .section-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            margin-bottom: 16px;
            overflow: hidden;
            animation: fadeUp 0.4s ease both;
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 22px;
            cursor: pointer;
            user-select: none;
            transition: background 0.2s;
        }
        .section-header:hover { background: rgba(255,255,255,0.02); }

        .section-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .section-icon {
            width: 40px; height: 40px;
            border-radius: 11px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 16px;
            box-shadow: 0 4px 12px var(--red-glow);
            flex-shrink: 0;
        }
        .section-title-text h3 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 20px;
            letter-spacing: 1.5px;
        }
        .section-title-text p { font-size: 12px; color: var(--muted); margin-top: 1px; }

        .chevron {
            color: #444; font-size: 14px;
            transition: transform 0.28s;
        }
        .section-card.open .chevron { transform: rotate(180deg); }

        .section-body {
            display: none;
            padding: 0 22px 22px;
            border-top: 1px solid var(--border);
        }
        .section-card.open .section-body { display: block; }

        /* ── STEPS LIST ── */
        .steps-list { margin-top: 18px; display: flex; flex-direction: column; gap: 12px; }

        .step-item {
            display: flex;
            gap: 14px;
            align-items: flex-start;
        }
        .step-num {
            width: 28px; height: 28px;
            border-radius: 50%;
            background: rgba(232,0,13,0.15);
            border: 1.5px solid rgba(232,0,13,0.30);
            color: var(--red);
            font-size: 12px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            margin-top: 1px;
        }
        .step-content h4 { font-size: 14px; font-weight: 600; color: #e0e0e0; margin-bottom: 4px; }
        .step-content p  { font-size: 13px; color: #888; line-height: 1.6; }

        /* ── INFO GRID ── */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 18px;
        }
        .info-box {
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
        }
        .info-box .ib-label {
            font-size: 10px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.8px;
            color: var(--muted); margin-bottom: 6px;
        }
        .info-box .ib-value { font-size: 13px; color: #ccc; line-height: 1.6; }
        .info-box .ib-value strong { color: #fff; }

        /* ── STATUS PILLS ── */
        .pill {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 11px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px;
            letter-spacing: 0.3px;
        }
        .pill-green  { background:rgba(0,200,80,0.10); color:#00c860; border:1px solid rgba(0,200,80,0.22); }
        .pill-orange { background:rgba(255,160,0,0.10); color:#ffa000; border:1px solid rgba(255,160,0,0.22); }
        .pill-red    { background:rgba(232,0,13,0.10); color:var(--red); border:1px solid rgba(232,0,13,0.22); }

        /* ── TABLE (DB tables section) ── */
        .db-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            margin-top: 14px;
        }
        .db-table thead tr { background: var(--surface2); }
        .db-table thead th {
            padding: 10px 14px;
            text-align: left;
            font-size: 10px; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.6px;
            color: var(--muted);
        }
        .db-table thead th:first-child { border-radius: 8px 0 0 8px; }
        .db-table thead th:last-child  { border-radius: 0 8px 8px 0; }
        .db-table tbody tr { border-bottom: 1px solid var(--border); }
        .db-table tbody tr:last-child { border-bottom: none; }
        .db-table tbody td { padding: 10px 14px; color: #bbb; vertical-align: top; }
        .db-table .col-name { font-weight: 600; color: var(--red); font-family: monospace; font-size: 13px; }
        .db-table .col-type { color: #5588ff; font-family: monospace; }

        /* ── TIP BOX ── */
        .tip-box {
            background: rgba(232,0,13,0.06);
            border: 1px solid rgba(232,0,13,0.18);
            border-left: 3px solid var(--red);
            border-radius: 10px;
            padding: 12px 16px;
            margin-top: 14px;
            font-size: 13px;
            color: #aaa;
            line-height: 1.6;
        }
        .tip-box strong { color: var(--red); }

        /* ── ANIMATION ── */
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        .section-card:nth-child(1) { animation-delay: 0.10s; }
        .section-card:nth-child(2) { animation-delay: 0.14s; }
        .section-card:nth-child(3) { animation-delay: 0.18s; }
        .section-card:nth-child(4) { animation-delay: 0.22s; }
        .section-card:nth-child(5) { animation-delay: 0.26s; }
        .section-card:nth-child(6) { animation-delay: 0.30s; }

        @media (max-width: 900px) {
            .flow-grid { grid-template-columns: repeat(3,1fr); }
            .info-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 560px) {
            body { padding: 14px 14px 32px; }
            .flow-grid { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-icon"><i class="fa-regular fa-circle-question"></i></div>
    <div class="page-header-text">
        <h2>Help &amp; <span>Guide</span></h2>
        <p>City Gym Hambantota – Admin System Documentation</p>
    </div>
</div>

<!-- OVERVIEW BANNER -->
<div class="overview-banner">
    <h3><i class="fa-solid fa-circle-info" style="margin-right:8px;"></i>System Overview</h3>
    <p>
        City Gym Hambantota Management System is a <strong style="color:#ddd;">fingerprint-based gym management platform</strong>.
        Members register their fingerprint on a physical device. When they scan at the gym, the system records their attendance in real-time,
        tracks membership status, and notifies the admin via a live popup. The admin can manage members, record payments, and view attendance reports — all from this dashboard.
    </p>
</div>

<!-- HOW IT WORKS – FLOW -->
<div class="flow-grid">
    <div class="flow-step">
        <div class="flow-num">1</div>
        <div class="flow-icon"><i class="fa-solid fa-fingerprint"></i></div>
        <div class="flow-label">Fingerprint Registered</div>
        <div class="flow-sub">Member scans on device</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">2</div>
        <div class="flow-icon"><i class="fa-solid fa-user-plus"></i></div>
        <div class="flow-label">Added to System</div>
        <div class="flow-sub">Admin adds member details</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">3</div>
        <div class="flow-icon"><i class="fa-solid fa-credit-card"></i></div>
        <div class="flow-label">Payment Recorded</div>
        <div class="flow-sub">Membership package set</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">4</div>
        <div class="flow-icon"><i class="fa-solid fa-hand-pointer"></i></div>
        <div class="flow-label">Daily Scan</div>
        <div class="flow-sub">Member scans at entrance</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">5</div>
        <div class="flow-icon"><i class="fa-solid fa-bell"></i></div>
        <div class="flow-label">Live Notification</div>
        <div class="flow-sub">Admin sees popup instantly</div>
    </div>
</div>

<!-- ═══════════════════ SECTIONS ═══════════════════ -->

<!-- 1. HOME DASHBOARD -->
<div class="section-card open">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-house"></i></div>
            <div class="section-title-text">
                <h3>Home Dashboard</h3>
                <p>Stats overview, attendance chart, membership status</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="info-grid">
            <div class="info-box">
                <div class="ib-label">Row 1 – 3 Stat Cards</div>
                <div class="ib-value">
                    <strong>Total Members</strong> — member_details table<br>
                    <strong>Today Attendance</strong> — distinct fingerprint scans today<br>
                    <strong>Weekly Avg Attendance</strong> — avg per day (last 7 days)
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Row 2 – 2 Stat Cards</div>
                <div class="ib-value">
                    <strong>Active Memberships</strong> — end_date &ge; today<br>
                    <strong>Ended Memberships</strong> — end_date &lt; today (expired)
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Row 3 – Attendance Chart</div>
                <div class="ib-value">
                    Bar chart showing daily attendance.<br>
                    Toggle between <strong>Last 7 Days</strong> and <strong>Last 30 Days</strong>.<br>
                    Page auto-refreshes every <strong>30 seconds</strong>.
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">DB Tables Used</div>
                <div class="ib-value">
                    <code style="color:#e8000d;">attendance_log</code> — scan records<br>
                    <code style="color:#e8000d;">member_details</code> — member info<br>
                    <code style="color:#e8000d;">membership_details</code> — package dates
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Tip:</strong> The watermark logo (img/logo.png) appears faintly on each stat card and inside the chart for branding. Make sure the logo file exists at that path.
        </div>
    </div>
</div>

<!-- 2. MEMBERS -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-users"></i></div>
            <div class="section-title-text">
                <h3>Members</h3>
                <p>Add new fingerprint users, view &amp; manage all saved members</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>New Fingerprint Users (Top Table)</h4>
                    <p>When a member scans their finger on the device for the first time, they appear here. The table auto-refreshes every <strong>3 seconds</strong> via fetch(). Click <strong>Add Member</strong> to open the registration popup.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Add Member Popup</h4>
                    <p>Fill in personal details (Name, Admission No, Phone, WhatsApp, Gender, Age, Birthday, Address, Photo) and membership package (Duration, Start Date — End Date auto-calculates, Amount, Registration Fee). Click <strong>Save Member</strong> to store in DB.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Saved Members (Bottom Table)</h4>
                    <p>All registered members shown here. Each row has a <strong>Payment</strong> button (goes to payment page) and a <strong>View</strong> button (opens full member profile).</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">4</div>
                <div class="step-content">
                    <h4>Delete from Device</h4>
                    <p>The 🗑 trash button deletes the fingerprint record from the physical device (calls <code>fingerprint-data</code> servlet with <code>action=deleteDeviceUser</code>). This does NOT delete from the member_details table.</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Note:</strong> A member who is already saved won't appear in the "New Fingerprint Users" table — the system filters them out by comparing fingerprint IDs in savedMembers set.
        </div>
    </div>
</div>

<!-- 3. VIEW MEMBER -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-user"></i></div>
            <div class="section-title-text">
                <h3>Member Profile (View Member)</h3>
                <p>Full profile, membership status, edit &amp; delete</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="info-grid">
            <div class="info-box">
                <div class="ib-label">Days Remaining Indicator</div>
                <div class="ib-value">
                    <span class="pill pill-green"><i class="fa-solid fa-circle-check"></i> Active</span> — more than 7 days left<br><br>
                    <span class="pill pill-orange"><i class="fa-solid fa-triangle-exclamation"></i> Warning</span> — 7 days or less<br><br>
                    <span class="pill pill-red"><i class="fa-solid fa-circle-xmark"></i> Expired</span> — membership ended
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Actions Available</div>
                <div class="ib-value">
                    <strong>Update Profile</strong> — Edit all fields + photo<br>
                    <strong>Record Payment</strong> — Go to payment page<br>
                    <strong>Delete Member</strong> — Permanently removes from DB
                </div>
            </div>
        </div>
        <div class="steps-list" style="margin-top:16px;">
            <div class="step-item">
                <div class="step-num">!</div>
                <div class="step-content">
                    <h4>Edit Mode</h4>
                    <p>Click <strong>Update Profile</strong> to switch to edit view. All fields become editable. End date auto-calculates when you change the month dropdown or start date. Click <strong>Save Changes</strong> to submit (<code>action=update</code> to view-member servlet).</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Photo:</strong> Member photo is served via <code>view-member?fid=XXX&type=image</code>. The servlet reads from the database BLOB and streams it as an image. If no photo, a fallback icon is shown.
        </div>
    </div>
</div>

<!-- 4. ATTENDANCE LOGS -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-chart-bar"></i></div>
            <div class="section-title-text">
                <h3>Members Attendance</h3>
                <p>Live fingerprint scan log with membership status</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>How Attendance is Recorded</h4>
                    <p>When a member scans their finger at the entrance, the fingerprint device communicates with the server. The <strong>attendance-stream</strong> servlet receives the scan and inserts a record into the <code>attendance_log</code> table with the fingerprint_id and scan_time.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Auto-Refresh</h4>
                    <p>The attendance table auto-refreshes every <strong>5 seconds</strong> via fetch() — only the table body refreshes, not the full page. The "LIVE" badge with blinking dot shows this is active.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Membership Remaining Column</h4>
                    <p>
                        <span class="pill pill-green">Active</span> — more than 7 days &nbsp;
                        <span class="pill pill-orange">Expiring Soon</span> — ≤7 days &nbsp;
                        <span class="pill pill-red">Expired</span> — past end date
                    </p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">4</div>
                <div class="step-content">
                    <h4>Unknown / Deleted Members</h4>
                    <p>If a fingerprint scan comes in but the member was deleted from the DB (or never added), the row is silently skipped. Only members with valid names and admission numbers are shown.</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Note:</strong> Attendance data comes from the <code>fingerprint-data</code> servlet with <code>page=logs</code>. The servlet joins <code>attendance_log</code> with <code>member_details</code> and <code>membership_details</code> to build each row.
        </div>
    </div>
</div>

<!-- 5. MEMBERSHIP & PAYMENT -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-credit-card"></i></div>
            <div class="section-title-text">
                <h3>Membership &amp; Payment</h3>
                <p>Record payments, renew membership, WhatsApp receipt</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>Select a Member</h4>
                    <p>Choose a member from the dropdown. The <strong>Selected Member Summary</strong> card on the right instantly shows their current membership status, package, end date, and WhatsApp number.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Fill Payment Details</h4>
                    <p>Enter Amount (Rs.), number of Months, and Start Date. The <strong>End Date auto-calculates</strong> based on start date + months. The end date field is read-only.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Save &amp; WhatsApp Receipt</h4>
                    <p>Click <strong>Save Payment &amp; Send WhatsApp Receipt</strong>. The form submits to <code>record-payment</code> servlet via fetch(). If the member has a WhatsApp number, the receipt is automatically triggered. On success, the page reloads with the member's updated info.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">4</div>
                <div class="step-content">
                    <h4>Recent Payment History</h4>
                    <p>The bottom table shows all past payment records with member name, WhatsApp, amount, package duration, payment date, and status.</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>DB:</strong> Payments are stored in a payments table linked to member_details. The WhatsApp message is sent via an external API call triggered from the <code>record-payment</code> servlet.
        </div>
    </div>
</div>

<!-- 6. LIVE ATTENDANCE POPUP -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-bell"></i></div>
            <div class="section-title-text">
                <h3>Live Attendance Popup</h3>
                <p>Real-time notification when a member scans (attendance-popup.js)</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="info-grid">
            <div class="info-box">
                <div class="ib-label">How It Works</div>
                <div class="ib-value">
                    The JS file polls <code>/attendance-stream?lastSeen=TIMESTAMP</code> every <strong>5 seconds</strong>. If a new scan is found (found: true), the popup appears bottom-right. The lastSeen timestamp is stored in <strong>sessionStorage</strong> so navigating between pages doesn't reset it.
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Popup Shows</div>
                <div class="ib-value">
                    • Member name &amp; avatar<br>
                    • Admission No<br>
                    • Scan time<br>
                    • Membership remaining<br>
                    • Status badge (ACTIVE / EXPIRING SOON / MEMBERSHIP EXPIRED)
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Color Coding</div>
                <div class="ib-value">
                    <span class="pill pill-green">ACTIVE</span> &gt; 7 days remaining<br><br>
                    <span class="pill pill-orange">EXPIRING SOON</span> ≤ 7 days<br><br>
                    <span class="pill pill-red">MEMBERSHIP EXPIRED</span>
                </div>
            </div>
            <div class="info-box">
                <div class="ib-label">Auto-Close</div>
                <div class="ib-value">
                    Popup closes automatically after <strong>2.5 minutes</strong> with a slide-out animation. The red progress bar at the bottom shrinks as the timer counts down. Users can also click ✕ to close manually.
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Important:</strong> <code>attendance-popup.js</code> is included in EVERY page via <code>&lt;script src="attendance-popup.js"&gt;</code>. This means the live popup works on ALL pages of the dashboard simultaneously — not just the attendance page.
        </div>
    </div>
</div>


<script>
    function toggle(header) {
        const card = header.closest('.section-card');
        card.classList.toggle('open');
    }
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
