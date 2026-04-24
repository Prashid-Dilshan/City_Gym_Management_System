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

        /* ── OVERVIEW BANNER ── */
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
            line-height: 1.8;
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
        .section-header-left { display: flex; align-items: center; gap: 12px; }
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
        .chevron { color: #444; font-size: 14px; transition: transform 0.28s; }
        .section-card.open .chevron { transform: rotate(180deg); }

        .section-body {
            display: none;
            padding: 0 22px 22px;
            border-top: 1px solid var(--border);
        }
        .section-card.open .section-body { display: block; }

        /* ── STEPS LIST ── */
        .steps-list { margin-top: 18px; display: flex; flex-direction: column; gap: 14px; }
        .step-item { display: flex; gap: 14px; align-items: flex-start; }
        .step-num {
            width: 28px; height: 28px;
            border-radius: 50%;
            background: rgba(232,0,13,0.15);
            border: 1.5px solid rgba(232,0,13,0.30);
            color: var(--red);
            font-size: 12px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            margin-top: 2px;
        }
        .step-content h4 { font-size: 14px; font-weight: 600; color: #e0e0e0; margin-bottom: 5px; }
        .step-content p  { font-size: 13px; color: #999; line-height: 1.7; }

        /* ── STATUS PILLS ── */
        .pill {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 11px; font-weight: 700;
            padding: 3px 10px; border-radius: 20px; letter-spacing: 0.3px;
        }
        .pill-green  { background:rgba(0,200,80,0.10);  color:#00c860; border:1px solid rgba(0,200,80,0.22); }
        .pill-orange { background:rgba(255,160,0,0.10); color:#ffa000; border:1px solid rgba(255,160,0,0.22); }
        .pill-red    { background:rgba(232,0,13,0.10);  color:var(--red); border:1px solid rgba(232,0,13,0.22); }

        /* ── TIP BOX ── */
        .tip-box {
            background: rgba(232,0,13,0.06);
            border: 1px solid rgba(232,0,13,0.18);
            border-left: 3px solid var(--red);
            border-radius: 10px;
            padding: 12px 16px;
            margin-top: 16px;
            font-size: 13px;
            color: #aaa;
            line-height: 1.7;
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
        <p>City Gym Hambantota – How to use the Admin Dashboard</p>
    </div>
</div>

<!-- OVERVIEW BANNER -->
<div class="overview-banner">
    <h3><i class="fa-solid fa-circle-info" style="margin-right:8px;"></i>System Overview</h3>
    <p>
        This dashboard lets you manage everything at <strong style="color:#ddd;">City Gym Hambantota</strong> from one place.
        Members scan their fingerprint at the entrance — the system automatically records their attendance and shows you a live popup.
        From here you can <strong style="color:#ddd;">add members, record payments, check attendance,</strong> and <strong style="color:#ddd;">view membership status</strong> at any time.
    </p>
</div>

<!-- HOW IT WORKS FLOW -->
<div class="flow-grid">
    <div class="flow-step">
        <div class="flow-num">1</div>
        <div class="flow-icon"><i class="fa-solid fa-fingerprint"></i></div>
        <div class="flow-label">Member Scans Finger</div>
        <div class="flow-sub">At the entrance device</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">2</div>
        <div class="flow-icon"><i class="fa-solid fa-user-plus"></i></div>
        <div class="flow-label">You Add the Member</div>
        <div class="flow-sub">Fill in their details</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">3</div>
        <div class="flow-icon"><i class="fa-solid fa-credit-card"></i></div>
        <div class="flow-label">Record Payment</div>
        <div class="flow-sub">Set membership package</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">4</div>
        <div class="flow-icon"><i class="fa-solid fa-hand-pointer"></i></div>
        <div class="flow-label">Daily Attendance</div>
        <div class="flow-sub">Auto-logged on each scan</div>
    </div>
    <div class="flow-step">
        <div class="flow-num">5</div>
        <div class="flow-icon"><i class="fa-solid fa-bell"></i></div>
        <div class="flow-label">Live Popup</div>
        <div class="flow-sub">You're notified instantly</div>
    </div>
</div>

<!-- ═══ 1. HOME ═══ -->
<div class="section-card open">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-house"></i></div>
            <div class="section-title-text">
                <h3>Home</h3>
                <p>Quick overview of the gym — attendance, members, memberships</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num"><i class="fa-solid fa-users" style="font-size:10px;"></i></div>
                <div class="step-content">
                    <h4>Total Members</h4>
                    <p>Shows the total number of members currently registered in the system.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num"><i class="fa-solid fa-fingerprint" style="font-size:10px;"></i></div>
                <div class="step-content">
                    <h4>Today's Attendance</h4>
                    <p>How many members have scanned their fingerprint today. This updates automatically — no need to refresh the page.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num"><i class="fa-solid fa-chart-bar" style="font-size:10px;"></i></div>
                <div class="step-content">
                    <h4>Weekly Average</h4>
                    <p>The average number of members attending per day over the past 7 days.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num"><i class="fa-solid fa-id-card" style="font-size:10px;"></i></div>
                <div class="step-content">
                    <h4>Active &amp; Ended Memberships</h4>
                    <p><strong style="color:#00c860;">Active</strong> — members whose membership is still valid today.<br>
                        <strong style="color:var(--red);">Ended</strong> — members whose membership has expired and needs renewal.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num"><i class="fa-solid fa-calendar" style="font-size:10px;"></i></div>
                <div class="step-content">
                    <h4>Attendance Chart</h4>
                    <p>A bar chart showing how many members attended each day. Use the buttons above the chart to switch between <strong>Last 7 Days</strong> and <strong>Last 30 Days</strong>. The page refreshes itself automatically every 30 seconds.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ 2. MEMBERS ═══ -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-users"></i></div>
            <div class="section-title-text">
                <h3>Members</h3>
                <p>Register new members and manage existing ones</p>
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
                    <p>When someone scans their finger at the entrance for the first time, they appear here automatically. This table updates every few seconds — you don't need to refresh the page.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Adding a New Member</h4>
                    <p>Click <strong>Add Member</strong> next to a new fingerprint user. A form will open — fill in:</p>
                    <p style="margin-top:8px;">
                        • <strong>Personal details:</strong> Name, Admission No, Phone, WhatsApp, Gender, Age, Birthday, Address, Photo<br>
                        • <strong>Membership:</strong> Duration (Date and months) and Start Date — the End Date fills in automatically<br>
                        • <strong>Fees:</strong> Monthly amount and Registration Fee
                    </p>
                    <p style="margin-top:8px;">Click <strong>Save Member</strong> when done.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Saved Members (Bottom Table)</h4>
                    <p>All registered members are listed here. Each row has two buttons:<br>
                        • <strong>Payment</strong> — Go to the payment page for that member<br>
                        • <strong>View</strong> — Open the full member profile</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">4</div>
                <div class="step-content">
                    <h4>Removing from Device</h4>
                    <p>The 🗑 trash icon in the top table removes that fingerprint from the entrance device only. It does not delete a saved member from the system.</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Note:</strong> Members who are already saved won't show up in the New Fingerprint Users table. Only unsaved fingerprints appear there.
        </div>
    </div>
</div>

<!-- ═══ 3. MEMBER PROFILE ═══ -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-user"></i></div>
            <div class="section-title-text">
                <h3>Member Profile</h3>
                <p>View full details, edit info, record payment or delete a member</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>Membership Status</h4>
                    <p>The member's current status is shown at the top of the profile:</p>
                    <p style="margin-top:8px;">
                        <span class="pill pill-green"><i class="fa-solid fa-circle-check"></i> Active</span> — Valid membership, more than 7 days left<br><br>
                        <span class="pill pill-orange"><i class="fa-solid fa-triangle-exclamation"></i> Expiring Soon</span> — 7 days or fewer remaining<br><br>
                        <span class="pill pill-red"><i class="fa-solid fa-circle-xmark"></i> Expired</span> — Membership has ended, renewal needed
                    </p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Editing a Member</h4>
                    <p>Click <strong>Update Profile</strong> to switch to edit mode. All fields become editable — you can change name, contact details, photo, and membership dates. The end date recalculates automatically when you change the duration or start date. Click <strong>Save Changes</strong> when done.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Record Payment</h4>
                    <p>Click <strong>Record Payment</strong> to go directly to the payment page for this member.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">4</div>
                <div class="step-content">
                    <h4>Deleting a Member</h4>
                    <p>Click <strong>Delete Member</strong> to permanently remove this member from the system. This cannot be undone — double-check before confirming.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ 4. ATTENDANCE ═══ -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-chart-bar"></i></div>
            <div class="section-title-text">
                <h3>Attendance</h3>
                <p>Live log of every member scan at the entrance</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>What This Page Shows</h4>
                    <p>Every time a member scans their finger at the entrance, a new row is added here automatically. The table updates on its own every few seconds — you'll see a <strong>LIVE</strong> badge at the top confirming this is active.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>What Each Row Shows</h4>
                    <p>Each row shows the member's <strong>name</strong>, <strong>admission number</strong>, the <strong>exact scan time</strong>, and their membership status:</p>
                    <p style="margin-top:8px;">
                        <span class="pill pill-green">Active</span> — Membership valid &nbsp;
                        <span class="pill pill-orange">Expiring Soon</span> — 7 days or fewer &nbsp;
                        <span class="pill pill-red">Expired</span> — Membership ended
                    </p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Unregistered Fingerprints</h4>
                    <p>If someone scans at the entrance but hasn't been added to the system yet, they won't appear here. Go to the <strong>Members</strong> page to register them first.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ 5. PAYMENT ═══ -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-credit-card"></i></div>
            <div class="section-title-text">
                <h3>Payment History</h3>
                <p>Record payments and view all past payment records</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>Viewing Payment History</h4>
                    <p>This page shows all past payments across all members — including the member's name, WhatsApp number, amount paid, package duration, and payment date.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>Recording a New Payment</h4>
                    <p>Go to the <strong>Members</strong> page and click the <strong>Payment</strong> button next to a member — or click <strong>Record Payment</strong> inside their profile. Then fill in:</p>
                    <p style="margin-top:8px;">
                        • <strong>Amount</strong> (Rs.)<br>
                        • <strong>Number of Months</strong><br>
                        • <strong>Start Date</strong> — the End Date fills in automatically
                    </p>
                    <p style="margin-top:8px;">Click <strong>Save Payment</strong> to confirm. The member's membership dates will update immediately.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>WhatsApp Receipt</h4>
                    <p>If the member has a WhatsApp number saved, a payment receipt is automatically sent to them the moment you save the payment. No extra steps needed.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ═══ 6. LIVE POPUP ═══ -->
<div class="section-card">
    <div class="section-header" onclick="toggle(this)">
        <div class="section-header-left">
            <div class="section-icon"><i class="fa-solid fa-bell"></i></div>
            <div class="section-title-text">
                <h3>Live Attendance Popup</h3>
                <p>Instant notification whenever a member scans at the entrance</p>
            </div>
        </div>
        <i class="fa-solid fa-chevron-down chevron"></i>
    </div>
    <div class="section-body">
        <div class="steps-list">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-content">
                    <h4>What It Does</h4>
                    <p>Whenever a member scans their finger at the entrance, a popup appears automatically at the <strong>bottom-right corner</strong> of your screen — on any page you're on. You don't need to be on the Attendance page to see it.</p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-content">
                    <h4>What the Popup Shows</h4>
                    <p>
                        • Member's <strong>name</strong><br>
                        • <strong>Admission number</strong><br>
                        • Exact <strong>scan time</strong><br>
                        • <strong>Days remaining</strong> on their membership<br>
                        • A colour-coded status badge:
                    </p>
                    <p style="margin-top:8px;">
                        <span class="pill pill-green">ACTIVE</span> — More than 7 days left &nbsp;
                        <span class="pill pill-orange">EXPIRING SOON</span> — 7 days or fewer &nbsp;
                        <span class="pill pill-red">MEMBERSHIP EXPIRED</span>
                    </p>
                </div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-content">
                    <h4>Closing the Popup</h4>
                    <p>The popup closes on its own after <strong>2.5 minutes</strong>. The red bar at the bottom shrinks as the timer counts down. You can also close it immediately by clicking the <strong>✕</strong> button in the top-right corner of the popup.</p>
                </div>
            </div>
        </div>
        <div class="tip-box">
            <strong>Tip:</strong> The popup works on every page — Home, Members, Attendance, Payments, and even this Help page. You'll never miss a scan.
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
<%@ include file="footer.jsp" %>
</body>
</html>
