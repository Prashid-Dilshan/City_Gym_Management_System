<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    if (request.getAttribute("attendanceLogs") == null) {
        response.sendRedirect("fingerprint-data?page=logs");
        return;
    }
%>

<html>
<head>
    <title>Attendance Logs</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            padding: 20px;
        }

        h2 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        th {
            background: #28a745;
            color: white;
            padding: 12px 15px;
            text-align: center;
        }

        td {
            padding: 10px 15px;
            text-align: center;
            border-bottom: 1px solid #eee;
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background: #f9fff9;
        }

        .expired { color: #dc3545; font-weight: bold; }
        .warning { color: #fd7e14; font-weight: bold; }
        .active  { color: #28a745; font-weight: bold; }

        .status-box {
            margin-bottom: 15px;
            padding: 10px 15px;
            background: #e9f7ef;
            border-left: 4px solid #28a745;
            border-radius: 4px;
            font-size: 14px;
        }

        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
            font-size: 16px;
        }
    </style>
</head>
<body>

<h2>📋 Fingerprint Attendance Logs</h2>

<%-- ✅ Connection status messages --%>
<%
    List<String> statusLogs = (List<String>) request.getAttribute("statusLogs");
    if (statusLogs != null) {
        for (String msg : statusLogs) {
%>
<div class="status-box"><%= msg %></div>
<% } } %>

<%-- ✅ Attendance table --%>
<%
    List<Map<String, String>> attendanceLogs =
            (List<Map<String, String>>) request.getAttribute("attendanceLogs");

    if (attendanceLogs != null && !attendanceLogs.isEmpty()) {
%>

<table id="attendanceTable">
    <tr>
        <th>#</th>
        <th>Admission No</th>
        <th>Name</th>
        <th>Date</th>
        <th>Time</th>
        <th>Membership Remaining</th>
    </tr>

    <%
        int i = 1;
        for (Map<String, String> log : attendanceLogs) {

            // Error row
            if (log.containsKey("error")) {
    %>
    <tr>
        <td colspan="6" style="color:#dc3545; font-weight:bold;">
            <%= log.get("error") %>
        </td>
    </tr>
    <%
            continue;
        }

        String daysLeft = log.get("daysLeft");
        String cssClass = "active";

        if ("Expired".equals(daysLeft)) {
            cssClass = "expired";
        } else if (!"-".equals(daysLeft)) {
            try {
                int d = Integer.parseInt(daysLeft.replace(" days", "").trim());
                if (d <= 7) cssClass = "warning";
            } catch (Exception ignored) {}
        }
    %>
    <tr>
        <td><%= i++ %></td>
        <td><%= log.get("admission") %></td>
        <td><%= log.get("name") %></td>
        <td><%= log.get("date") %></td>
        <td><%= log.get("time") %></td>
        <td class="<%= cssClass %>"><%= daysLeft %></td>
    </tr>

    <% } %>
</table>

<% } else { %>
<div class="no-data">📭 No attendance logs found.</div>
<% } %>


<script>
    function loadAttendance() {
        fetch('fingerprint-data?page=logs')
            .then(response => response.text())
            .then(html => {
                let parser = new DOMParser();
                let doc = parser.parseFromString(html, 'text/html');

                let newTable = doc.querySelector("#attendanceTable");
                document.querySelector("#attendanceTable").innerHTML = newTable.innerHTML;
            });
    }

    // auto refresh every 5 seconds
    setInterval(loadAttendance, 5000);
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
