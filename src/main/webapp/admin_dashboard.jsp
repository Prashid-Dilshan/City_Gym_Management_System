<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
    String adminName = (String) session.getAttribute("username");
    if (adminName == null) adminName = "Admin";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard – City Gym</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

    <style>
        :root {
            --red:        #e8000d;
            --red-dim:    #9a0008;
            --red-glow:   rgba(232,0,13,0.30);
            --sidebar-w:  240px;
            --topbar-h:   66px;
            --bg:         #0a0a0a;
            --surface:    #111111;
            --surface2:   #181818;
            --border:     rgba(255,255,255,0.07);
            --text:       #f0f0f0;
            --muted:      #666;
        }

        *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

        body {
            font-family: 'Outfit', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            overflow: hidden;
        }

        /* ══════════════════════════════
           SIDEBAR
        ══════════════════════════════ */
        .sidebar {
            position: fixed;
            top: 0; left: 0;
            width: var(--sidebar-w);
            height: 100vh;
            background: var(--surface);
            border-right: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            z-index: 100;
        }

        .sidebar-logo {
            padding: 6px 0;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 0;
        }

        .logo-img {
            width: 120px;
            height: auto;
            object-fit: contain;
        }

        /* If no logo image, show text fallback */
        .logo-text {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 22px;
            letter-spacing: 2px;
            color: #fff;
            text-align: center;
            line-height: 1.2;
        }
        .logo-text span { color: var(--red); }

        .sidebar-nav {
            flex: 1;
            padding: 18px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 13px 22px;
            text-decoration: none;
            color: #888;
            font-size: 15px;
            font-weight: 500;
            border-left: 3px solid transparent;
            transition: all 0.22s ease;
            cursor: pointer;
        }
        .nav-item i {
            width: 20px;
            text-align: center;
            font-size: 16px;
        }
        .nav-item:hover {
            color: #fff;
            background: rgba(255,255,255,0.04);
            border-left-color: rgba(232,0,13,0.4);
        }
        .nav-item.active {
            color: #fff;
            background: linear-gradient(90deg, rgba(232,0,13,0.18) 0%, transparent 100%);
            border-left-color: var(--red);
        }
        .nav-item.active i { color: var(--red); }

        .sidebar-logout {
            border-top: 1px solid var(--border);
            padding: 14px 0;
        }
        .sidebar-logout .nav-item {
            color: #666;
        }
        .sidebar-logout .nav-item:hover {
            color: var(--red);
        }

        /* ══════════════════════════════
           TOP BAR
        ══════════════════════════════ */
        .topbar {
            position: fixed;
            top: 0;
            left: var(--sidebar-w);
            right: 0;
            height: var(--topbar-h);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            padding: 0 28px;
            gap: 16px;
            z-index: 99;
        }

        .topbar-hamburger {
            color: #888;
            font-size: 20px;
            cursor: pointer;
            padding: 6px;
            border-radius: 8px;
            transition: 0.2s;
        }
        .topbar-hamburger:hover { color: #fff; background: rgba(255,255,255,0.06); }

        .topbar-title {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 30px;
            letter-spacing: 1.5px;
            flex: 1;
            margin-left: 440px;
        }
        .topbar-title span { color: var(--red); }

        .topbar-search {
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--surface2);
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 8px 16px;
            width: 220px;
            transition: 0.25s;
        }
        .topbar-search:focus-within {
            border-color: rgba(232,0,13,0.5);
            box-shadow: 0 0 0 3px rgba(232,0,13,0.08);
        }
        .topbar-search i { color: #555; font-size: 14px; }
        .topbar-search input {
            background: transparent;
            border: none; outline: none;
            color: #fff;
            font-family: 'Outfit', sans-serif;
            font-size: 14px;
            flex: 1;
        }
        .topbar-search input::placeholder { color: #555; }

        .topbar-admin {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            cursor: pointer;
            transition: 0.2s;
            background: var(--surface2);
        }
        .topbar-admin:hover { border-color: rgba(232,0,13,0.4); }
        .topbar-admin .avatar {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: var(--red);
            display: flex; align-items: center; justify-content: center;
            font-size: 16px;
            color: #fff;
            border: 2px solid rgba(255,255,255,0.12);
        }
        .admin-info .name { font-size: 14px; font-weight: 600; }
        .admin-info .role { font-size: 11px; color: var(--red); font-weight: 500; }
        .topbar-admin .chevron { color: #555; font-size: 12px; margin-left: 4px; }

        /* ══════════════════════════════
           MAIN CONTENT AREA
        ══════════════════════════════ */
        .main {
            margin-left: var(--sidebar-w);
            padding-top: var(--topbar-h);
            height: 100vh;
            overflow: hidden;
        }

        iframe#contentFrame {
            width: 100%;
            height: calc(100vh - var(--topbar-h));
            border: none;
            display: block;
        }

        /* ══════════════════════════════
           ACTIVE STATE SCRIPT HELPER
        ══════════════════════════════ */
    </style>
</head>
<body>

<!-- ── SIDEBAR ── -->
<div class="sidebar">

    <div class="sidebar-logo">
        <!-- Replace src with your actual logo path -->
        <img src="img/Gym_logo.png" alt="City Gym" class="logo-img"
             onerror="this.style.display='none'; document.getElementById('logoFallback').style.display='block'">
        <div id="logoFallback" class="logo-text" style="display:none;">
            <span>CG</span> FITNESS<br>
            <small style="font-size:11px; color:#555; font-family:'Outfit',sans-serif; font-weight:400; letter-spacing:1px;">CITY GYM HAMBANTOTA</small>
        </div>
    </div>

    <nav class="sidebar-nav">
        <a class="nav-item active" href="home.jsp" target="contentFrame" onclick="setActive(this)">
            <i class="fa-solid fa-house"></i> Home
        </a>
        <a class="nav-item" href="fingerprint-data" target="contentFrame" onclick="setActive(this)">
            <i class="fa-solid fa-users"></i> Members
        </a>
        <a class="nav-item" href="attendance.jsp" target="contentFrame" onclick="setActive(this)">
            <i class="fa-solid fa-chart-bar"></i> Members Attendance
        </a>
        <a class="nav-item" href="member-payment" target="contentFrame" onclick="setActive(this)">
            <i class="fa-solid fa-credit-card"></i> Membership &amp; Payment
        </a>
        <a class="nav-item" href="help.jsp" target="contentFrame" onclick="setActive(this)">
            <i class="fa-regular fa-circle-question"></i> Help
        </a>
    </nav>

    <div class="sidebar-logout">
        <a class="nav-item" href="login.jsp">
            <i class="fa-solid fa-right-from-bracket"></i> Logout
        </a>
    </div>
</div>

<!-- ── TOP BAR ── -->
<div class="topbar">
    <div class="topbar-hamburger"><i class=""></i></div>

    <div class="topbar-title">
        <span>Admin</span> Dashboard
    </div>
</div>

<!-- ── CONTENT ── -->
<div class="main">
    <iframe name="contentFrame" id="contentFrame" src="home.jsp"></iframe>
</div>

<script src="attendance-popup.js"></script>
<script>
    function setActive(el) {
        document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
        el.classList.add('active');
    }
</script>
</body>
</html>
