<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonElement" %>
<%
  JsonArray recentActivity = (JsonArray) request.getAttribute("recentActivity");
  if (recentActivity == null) {
    recentActivity = new JsonArray();
  }
  Object checkinCount = request.getAttribute("checkinCount");
%>
<html>
<head>
  <title>Live Scan Dashboard</title>
  <style>
    body { margin: 0; font-family: Arial, sans-serif; background: #0e0e0e; color: #f3f3f3; }
    .container { padding: 18px; }
    .cards { display: flex; gap: 16px; flex-wrap: wrap; margin-top: 14px; }
    .card { background: #1b1b1b; border: 1px solid #2a2a2a; border-radius: 10px; padding: 16px; min-width: 220px; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; }
    th, td { padding: 10px; border-bottom: 1px solid #2a2a2a; text-align: left; }
    .status-active { color: #35d14f; font-weight: 700; }
    .status-expired { color: #ff4a4a; font-weight: 700; }
    .status-soon { color: #ff9a1f; font-weight: 700; }
    .overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, 0.88); display: none; align-items: center; justify-content: center; z-index: 999; }
    .overlay-content { background: #171717; border: 1px solid #333; border-radius: 14px; width: min(840px, 92vw); text-align: center; padding: 30px; }
    .overlay h1 { font-size: 48px; margin-bottom: 12px; }
    .overlay img { width: 180px; height: 180px; border-radius: 50%; object-fit: cover; border: 3px solid #303030; }
    .badge { display: inline-block; margin-top: 18px; padding: 10px 20px; font-size: 20px; font-weight: 700; border-radius: 10px; }
    .badge-active { background: #35d14f; color: #071007; }
    .badge-expired { background: #ff4a4a; color: #200202; }
    .badge-soon { background: #ff9a1f; color: #271400; }
    .footer { margin-top: 22px; color: #9a9a9a; }
  </style>
</head>
<body>
<%@ include file="nav.jsp" %>

<div class="container">
  <h2>Live Scan Monitor</h2>
  <p style="color:#b0b0b0;">${error}</p>

  <div class="cards">
    <div class="card">
      <div>Today</div>
      <h3 style="margin:6px 0 0 0;"><%= request.getAttribute("todayDate") %></h3>
    </div>
    <div class="card">
      <div>Total Check-ins</div>
      <h3 style="margin:6px 0 0 0;"><%= checkinCount == null ? 0 : checkinCount %></h3>
    </div>
  </div>

  <h3 style="margin-top:20px;">Recent Activity</h3>
  <table>
    <thead>
    <tr>
      <th>Name</th>
      <th>Time</th>
      <th>Status</th>
    </tr>
    </thead>
    <tbody>
    <% for (JsonElement element : recentActivity) {
         JsonObject item = element.getAsJsonObject();
         String status = item.has("membershipStatus") ? item.get("membershipStatus").getAsString() : "ACTIVE";
         String name = item.has("memberName") ? item.get("memberName").getAsString() : "Unknown";
         String time = item.has("scanTime") ? item.get("scanTime").getAsString() : "-";
    %>
      <tr>
        <td><%= name %></td>
        <td><%= time %></td>
        <td class="<%= "EXPIRED".equals(status) ? "status-expired" : ("EXPIRING_SOON".equals(status) ? "status-soon" : "status-active") %>">
          <%= status %>
        </td>
      </tr>
    <% } %>
    </tbody>
  </table>

  <div class="footer">Powered by AGNOX</div>
</div>

<div id="scanOverlay" class="overlay">
  <div class="overlay-content">
    <h1 id="memberName">Member Name</h1>
    <img id="memberPhoto" src="https://via.placeholder.com/180" alt="Member Photo">
    <div id="statusBadge" class="badge">Access Granted</div>
  </div>
</div>

<script>
  let lastEventId = "";
  const overlay = document.getElementById("scanOverlay");
  const memberName = document.getElementById("memberName");
  const memberPhoto = document.getElementById("memberPhoto");
  const statusBadge = document.getElementById("statusBadge");

  function showOverlay(event) {
    memberName.textContent = event.memberName || "Unknown Member";
    memberPhoto.src = event.photoUrl || "https://via.placeholder.com/180";

    const status = event.membershipStatus || "ACTIVE";
    if (status === "EXPIRED") {
      statusBadge.className = "badge badge-expired";
      statusBadge.textContent = "Membership Expired";
    } else if (status === "EXPIRING_SOON") {
      statusBadge.className = "badge badge-soon";
      statusBadge.textContent = "Expiring Soon";
    } else {
      statusBadge.className = "badge badge-active";
      statusBadge.textContent = "Access Granted";
    }

    overlay.style.display = "flex";
    setTimeout(() => {
      overlay.style.display = "none";
    }, 5000);
  }

  async function pollLatestScan() {
    try {
      const response = await fetch("api/scan/latest", { cache: "no-store" });
      if (!response.ok) {
        return;
      }
      const data = await response.json();
      const eventId = data.eventId || data.scanId || data.scanTime || "";
      if (eventId && eventId !== lastEventId) {
        lastEventId = eventId;
        showOverlay(data);
      }
    } catch (e) {
      console.error("Scan polling failed", e);
    }
  }

  setInterval(pollLatestScan, 2000);
</script>

</body>
</html>

