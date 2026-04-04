<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.JsonObject" %>
<%
  List<JsonObject> expiringSoon = (List<JsonObject>) request.getAttribute("expiringSoon");
  if (expiringSoon == null) expiringSoon = java.util.Collections.emptyList();
  List<JsonObject> expiredMembers = (List<JsonObject>) request.getAttribute("expiredMembers");
  if (expiredMembers == null) expiredMembers = java.util.Collections.emptyList();
%>
<html>
<head>
  <title>Expiry Alerts</title>
  <style>
    body { margin: 0; background: #101010; color: #efefef; font-family: Arial, sans-serif; }
    .container { padding: 18px; }
    .panel { background: #171717; border: 1px solid #2e2e2e; border-radius: 10px; padding: 14px; margin-top: 14px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { text-align: left; padding: 9px; border-bottom: 1px solid #2a2a2a; }
    .ok { color: #7cff95; }
    .err { color: #ff7f7f; }
    .warn { color: #ffbf73; }
    button { padding: 7px 10px; border-radius: 6px; border: 1px solid #3e3e3e; background: #1f1f1f; color: #fff; }
    .footer { margin-top: 18px; color: #9b9b9b; }
  </style>
</head>
<body>
<%@ include file="nav.jsp" %>
<div class="container">
  <h2>Alerts</h2>
  <p class="ok">${successMessage}</p>
  <p class="err">${error}</p>
  <p class="warn">${whatsappError}</p>

  <div class="panel">
    <h3>Expiring Soon (within 7 days)</h3>
    <table>
      <thead>
      <tr><th>Name</th><th>WhatsApp</th><th>Expiry Date</th><th>Action</th></tr>
      </thead>
      <tbody>
      <% for (JsonObject m : expiringSoon) {
           String id = m.has("id") ? m.get("id").getAsString() : "";
           String name = m.has("name") ? m.get("name").getAsString() : "-";
           String phone = m.has("whatsappNumber") ? m.get("whatsappNumber").getAsString() : "-";
           String expiry = m.has("expiryDate") ? m.get("expiryDate").getAsString() : "-";
      %>
      <tr>
        <td><%= name %></td>
        <td><%= phone %></td>
        <td><%= expiry %></td>
        <td>
          <form action="alert/send-reminder" method="post">
            <input type="hidden" name="memberId" value="<%= id %>">
            <button type="submit">Send WhatsApp Reminder</button>
          </form>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>

  <div class="panel">
    <h3>Already Expired</h3>
    <table>
      <thead>
      <tr><th>Name</th><th>WhatsApp</th><th>Expiry Date</th><th>Action</th></tr>
      </thead>
      <tbody>
      <% for (JsonObject m : expiredMembers) {
           String id = m.has("id") ? m.get("id").getAsString() : "";
           String name = m.has("name") ? m.get("name").getAsString() : "-";
           String phone = m.has("whatsappNumber") ? m.get("whatsappNumber").getAsString() : "-";
           String expiry = m.has("expiryDate") ? m.get("expiryDate").getAsString() : "-";
      %>
      <tr>
        <td><%= name %></td>
        <td><%= phone %></td>
        <td><%= expiry %></td>
        <td>
          <form action="alert/send-reminder" method="post">
            <input type="hidden" name="memberId" value="<%= id %>">
            <button type="submit">Send WhatsApp Reminder</button>
          </form>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>

  <div class="footer">Powered by AGNOX</div>
</div>
</body>
</html>

