<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #121212;
            color: #fff;
            overflow: hidden; /* 🔥 fix scroll issue */
        }

        /* 🔥 Sidebar */
        .sidebar {
            width: 220px;
            height: 100vh;
            background: #1e1e1e;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 20px;
            border-right: 1px solid #333;
        }

        .sidebar h2 {
            text-align: center;
            color: #00ffcc;
            margin-bottom: 20px;
        }

        .sidebar a {
            display: block;
            padding: 15px;
            text-decoration: none;
            color: #ccc;
            font-weight: bold;
            transition: 0.3s;
        }

        .sidebar a:hover {
            background: #333;
            color: #00ffcc;
            padding-left: 20px;
        }

        .sidebar a.active {
            background: #00ffcc;
            color: #000;
        }

        .logout {
            position: absolute;
            bottom: 20px;
            width: 100%;
        }

        /* 🔥 Content */
        .content {
            margin-left: 220px;
            height: 100vh;
        }

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            background: #ffffff;
        }
    </style>

    <script>
        function setActive(link) {
            let links = document.querySelectorAll(".sidebar a");
            links.forEach(l => l.classList.remove("active"));
            link.classList.add("active");
        }
    </script>

</head>

<body>

<!-- 🔥 Sidebar -->
<div class="sidebar">
    <h2>⚡ Admin</h2>

    <!-- 🔥 IMPORTANT: Members → servlet call -->
    <a href="home.jsp" target="contentFrame" onclick="setActive(this)" class="active">Home</a>
    <a href="fingerprint-data" target="contentFrame" onclick="setActive(this)">Members</a>
    <a href="attendance.jsp" target="contentFrame" onclick="setActive(this)">Members Attendance</a>
    <a href="page1.jsp" target="contentFrame" onclick="setActive(this)">Page 1</a>
    <a href="page2.jsp" target="contentFrame" onclick="setActive(this)">Page 2</a>

    <div class="logout">
        <a href="login.jsp">🚪 Logout</a>
    </div>
</div>

<!-- 🔥 Content Area -->
<div class="content">
    <!-- ✅ Default load -->
    <iframe name="contentFrame" src="home.jsp"></iframe>
</div>
<script src="attendance-popup.js"></script>
</body>
</html>