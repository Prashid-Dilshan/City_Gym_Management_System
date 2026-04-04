<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonElement" %>
<%
  JsonArray members = (JsonArray) request.getAttribute("members");
  if (members == null) {
    members = new JsonArray();
  }
%>
<html>
<head>
  <title>Member Management</title>
  <style>
    body { margin: 0; background: #0f0f0f; color: #efefef; font-family: Arial, sans-serif; }
    .container { padding: 18px; }
    input, select, button { padding: 8px; border-radius: 6px; border: 1px solid #3a3a3a; background: #1b1b1b; color: #f2f2f2; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; }
    th, td { border-bottom: 1px solid #2f2f2f; padding: 10px; text-align: left; }
    .status-ACTIVE { color: #34d058; font-weight: 700; }
    .status-EXPIRED { color: #ff5a5a; font-weight: 700; }
    .status-EXPIRING_SOON { color: #ff9d2e; font-weight: 700; }
    .toolbar { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
    .panel { background: #171717; border: 1px solid #2a2a2a; border-radius: 10px; padding: 14px; margin-top: 16px; }
    .msg-ok { color: #69f388; }
    .msg-err { color: #ff7777; }
    .footer { margin-top: 18px; color: #9b9b9b; }
  </style>
</head>
<body>
<%@ include file="nav.jsp" %>
<div class="container">
  <h2>Member Management</h2>
  <p class="msg-ok">${successMessage}</p>
  <p class="msg-err">${error}</p>

  <div class="toolbar">
    <input type="text" id="memberSearch" placeholder="Search by name or number" onkeyup="filterRows()" />
    <button type="button" onclick="toggleAddForm()">Add New Member</button>
  </div>

  <div id="addForm" class="panel" style="display:none;">
    <h3>Add New Member</h3>
    <form action="members" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="add" />
      <label>Full Name</label><br>
      <input type="text" name="fullName" required /><br><br>

      <label>WhatsApp Number</label><br>
      <span>+94</span>
      <input type="text" name="whatsappNumber" placeholder="771234567" required /><br><br>

      <label>Membership Start Date</label><br>
      <input type="date" name="startDate" required /><br><br>

      <label>Duration</label><br>
      <select name="duration" required>
        <option value="1_MONTH">1 Month</option>
        <option value="3_MONTHS">3 Months</option>
        <option value="6_MONTHS">6 Months</option>
        <option value="1_YEAR">1 Year</option>
      </select><br><br>

      <label>Photo (optional)</label><br>
      <input type="file" name="photo" accept="image/*" /><br><br>

      <button type="submit">Save Member</button>
    </form>
  </div>

  <table id="memberTable">
    <thead>
    <tr>
      <th>Name</th>
      <th>WhatsApp Number</th>
      <th>Expiry Date</th>
      <th>Status</th>
      <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <% for (JsonElement element : members) {
         JsonObject m = element.getAsJsonObject();
         String id = m.has("id") ? m.get("id").getAsString() : "";
         String name = m.has("name") ? m.get("name").getAsString() : "-";
         String phone = m.has("whatsappNumber") ? m.get("whatsappNumber").getAsString() : "-";
         String expiry = m.has("expiryDate") ? m.get("expiryDate").getAsString() : "-";
         String status = m.has("status") ? m.get("status").getAsString() : "EXPIRED";
    %>
    <tr>
      <td><%= name %></td>
      <td><%= phone %></td>
      <td><%= expiry %></td>
      <td class="status-<%= status %>"><%= status %></td>
      <td>
        <button type="button" onclick="openEdit('<%= id %>', '<%= name %>', '<%= phone %>', '<%= expiry %>')">Edit</button>

        <form action="members" method="post" style="display:inline;" onsubmit="return confirm('Delete this member?');">
          <input type="hidden" name="action" value="delete" />
          <input type="hidden" name="memberId" value="<%= id %>" />
          <button type="submit">Delete</button>
        </form>

        <form action="members" method="post" style="display:inline;">
          <input type="hidden" name="action" value="enroll" />
          <input type="hidden" name="memberId" value="<%= id %>" />
          <button type="submit">Enroll Fingerprint</button>
        </form>
      </td>
    </tr>
    <% } %>
    </tbody>
  </table>

  <div id="editForm" class="panel" style="display:none;">
    <h3>Edit Member</h3>
    <form action="members" method="post" enctype="multipart/form-data">
      <input type="hidden" name="action" value="update" />
      <input type="hidden" name="memberId" id="editMemberId" />

      <label>Full Name</label><br>
      <input type="text" name="fullName" id="editName" required /><br><br>

      <label>WhatsApp Number</label><br>
      <input type="text" name="whatsappNumber" id="editWhatsapp" required /><br><br>

      <label>Expiry Date</label><br>
      <input type="date" name="expiryDate" id="editExpiry" required /><br><br>

      <label>Replace Photo (optional)</label><br>
      <input type="file" name="photo" accept="image/*" /><br><br>

      <button type="submit">Update Member</button>
    </form>
  </div>

  <div class="footer">Powered by AGNOX</div>
</div>

<script>
  function filterRows() {
    const q = document.getElementById("memberSearch").value.toLowerCase();
    const rows = document.querySelectorAll("#memberTable tbody tr");
    rows.forEach(row => {
      const text = row.innerText.toLowerCase();
      row.style.display = text.indexOf(q) !== -1 ? "" : "none";
    });
  }

  function toggleAddForm() {
    const el = document.getElementById("addForm");
    el.style.display = el.style.display === "none" ? "block" : "none";
  }

  function openEdit(id, name, whatsapp, expiry) {
    document.getElementById("editMemberId").value = id;
    document.getElementById("editName").value = name;
    document.getElementById("editWhatsapp").value = whatsapp;
    document.getElementById("editExpiry").value = expiry;
    document.getElementById("editForm").style.display = "block";
    window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" });
  }
</script>
</body>
</html>

