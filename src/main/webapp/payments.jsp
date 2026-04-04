<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.gson.JsonArray" %>
<%@ page import="com.google.gson.JsonObject" %>
<%@ page import="com.google.gson.JsonElement" %>
<%
  JsonArray searchResults = (JsonArray) request.getAttribute("searchResults");
  if (searchResults == null) searchResults = new JsonArray();
  JsonArray paymentHistory = (JsonArray) request.getAttribute("paymentHistory");
  if (paymentHistory == null) paymentHistory = new JsonArray();
  JsonObject selectedMember = (JsonObject) request.getAttribute("selectedMember");
%>
<html>
<head>
  <title>Payments & Renewals</title>
  <style>
    body { margin: 0; background: #111; color: #ececec; font-family: Arial, sans-serif; }
    .container { padding: 18px; }
    .panel { background: #1a1a1a; border: 1px solid #313131; border-radius: 10px; padding: 14px; margin-top: 14px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { text-align: left; padding: 9px; border-bottom: 1px solid #2d2d2d; }
    input, select, button { padding: 8px; border-radius: 6px; border: 1px solid #3e3e3e; background: #202020; color: #f4f4f4; }
    .ok { color: #76ff8f; }
    .err { color: #ff7979; }
    .warn { color: #ffc06b; }
    .footer { margin-top: 18px; color: #9d9d9d; }
  </style>
</head>
<body>
<%@ include file="nav.jsp" %>
<div class="container">
  <h2>Payment & Renewal</h2>
  <p class="ok">${successMessage}</p>
  <p class="err">${error}</p>
  <p class="warn">${whatsappError}</p>

  <div class="panel">
    <h3>Search Member</h3>
    <form action="payments" method="get">
      <input type="text" name="memberName" placeholder="Enter member name" required />
      <button type="submit">Search</button>
    </form>

    <% if (!searchResults.isEmpty()) { %>
    <table>
      <thead><tr><th>Name</th><th>Expiry Date</th><th>Select</th></tr></thead>
      <tbody>
      <% for (JsonElement element : searchResults) {
           JsonObject m = element.getAsJsonObject();
           String name = m.has("name") ? m.get("name").getAsString() : "-";
           String expiry = m.has("expiryDate") ? m.get("expiryDate").getAsString() : "-";
           String id = m.has("id") ? m.get("id").getAsString() : "";
      %>
      <tr>
        <td><%= name %></td>
        <td><%= expiry %></td>
        <td><a href="payments?memberId=<%= id %>">Open</a></td>
      </tr>
      <% } %>
      </tbody>
    </table>
    <% } %>
  </div>

  <% if (selectedMember != null) {
       String memberName = selectedMember.has("name") ? selectedMember.get("name").getAsString() : "-";
       String duration = selectedMember.has("duration") ? selectedMember.get("duration").getAsString() : "-";
       String expiry = selectedMember.has("expiryDate") ? selectedMember.get("expiryDate").getAsString() : "-";
       String id = selectedMember.has("id") ? selectedMember.get("id").getAsString() : "";
  %>
  <div class="panel">
    <h3>Member Details</h3>
    <p><strong>Name:</strong> <%= memberName %></p>
    <p><strong>Current Plan:</strong> <%= duration %></p>
    <p><strong>Expiry Date:</strong> <%= expiry %></p>
    <p><strong>Status:</strong> <%= request.getAttribute("memberStatus") %></p>

    <h3>Record Payment</h3>
    <form action="payments" method="post">
      <input type="hidden" name="memberId" value="<%= id %>" />

      <label>Payment Amount</label><br>
      <input type="number" step="0.01" min="0" name="paymentAmount" required /><br><br>

      <label>Payment Method</label><br>
      <select name="paymentMethod" required>
        <option value="CASH">Cash</option>
        <option value="CARD">Card</option>
      </select><br><br>

      <label>New Plan Duration</label><br>
      <select name="newPlanDuration" required>
        <option value="1_MONTH">1 Month</option>
        <option value="3_MONTHS">3 Months</option>
        <option value="6_MONTHS">6 Months</option>
        <option value="1_YEAR">1 Year</option>
      </select><br><br>

      <button type="submit">Record Payment</button>
    </form>
  </div>

  <div class="panel">
    <h3>Payment History</h3>
    <table>
      <thead><tr><th>Date</th><th>Amount</th><th>Method</th></tr></thead>
      <tbody>
      <% for (JsonElement element : paymentHistory) {
           JsonObject p = element.getAsJsonObject();
           String date = p.has("date") ? p.get("date").getAsString() : "-";
           String amount = p.has("amount") ? p.get("amount").getAsString() : "-";
           String method = p.has("method") ? p.get("method").getAsString() : "-";
      %>
      <tr>
        <td><%= date %></td>
        <td><%= amount %></td>
        <td><%= method %></td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
  <% } %>

  <div class="footer">Powered by AGNOX</div>
</div>
</body>
</html>

