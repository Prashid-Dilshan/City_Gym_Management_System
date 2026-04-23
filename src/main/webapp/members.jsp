<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.example.city_gym_management_system.DatabaseUtil" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  String role = (String) session.getAttribute("userRole");
  if (!"admin".equals(role)) {
    response.sendRedirect("login.jsp");
    return;
  }

  if (request.getAttribute("users") == null) {
    response.sendRedirect("fingerprint-data?page=users");
    return;
  }

  List<String> users = new ArrayList<>();
  Object usersAttr = request.getAttribute("users");
  if (usersAttr instanceof List<?>) {
    List<?> rawUsers = (List<?>) usersAttr;
    for (Object entry : rawUsers) {
      if (entry != null) users.add(entry.toString());
    }
  }

  Set<String> savedMembers = new HashSet<>();
  Object savedMembersAttr = request.getAttribute("savedMembers");
  if (savedMembersAttr instanceof Set<?>) {
    Set<?> rawSavedMembers = (Set<?>) savedMembersAttr;
    for (Object entry : rawSavedMembers) {
      if (entry != null) savedMembers.add(entry.toString());
    }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Members – City Gym</title>
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
      --surface3: #1c1c1c;
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
      color: #fff;
      font-size: 18px;
      box-shadow: 0 6px 16px var(--red-glow);
    }
    .page-header h2 {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 28px;
      letter-spacing: 2px;
    }
    .page-header h2 span { color: var(--red); }

    /* ── SECTION CARD ── */
    .section-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 22px 24px;
      margin-bottom: 22px;
      animation: fadeUp 0.4s ease both;
    }
    .section-card:nth-child(2) { animation-delay: 0.08s; }
    .section-card:nth-child(3) { animation-delay: 0.15s; }

    .section-title {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 16px;
      font-weight: 600;
      margin-bottom: 18px;
      padding-bottom: 14px;
      border-bottom: 1px solid var(--border);
    }
    .section-title i { color: var(--red); }
    .badge {
      background: rgba(232,0,13,0.15);
      color: var(--red);
      font-size: 11px;
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 20px;
      border: 1px solid rgba(232,0,13,0.25);
    }

    /* ── TABLES ── */
    .tbl-wrap { overflow-x: auto; }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }

    thead tr {
      background: var(--surface2);
    }
    thead th {
      padding: 12px 16px;
      text-align: left;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.6px;
      color: var(--muted);
      white-space: nowrap;
    }
    thead th:first-child { border-radius: 8px 0 0 8px; }
    thead th:last-child  { border-radius: 0 8px 8px 0; }

    tbody tr {
      border-bottom: 1px solid var(--border);
      transition: background 0.18s;
    }
    tbody tr:last-child { border-bottom: none; }
    tbody tr:hover { background: rgba(255,255,255,0.025); }

    tbody td {
      padding: 13px 16px;
      color: #ccc;
      vertical-align: middle;
    }

    .fp-id {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 18px;
      color: var(--red);
      letter-spacing: 1px;
    }

    .member-name {
      font-weight: 600;
      color: #f0f0f0;
    }

    /* ── BUTTONS ── */
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 7px 14px;
      border-radius: 8px;
      font-family: 'Outfit', sans-serif;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      border: none;
      transition: all 0.2s;
      text-decoration: none;
    }
    .btn-red {
      background: linear-gradient(135deg, var(--red), var(--red-dim));
      color: #fff;
      box-shadow: 0 4px 12px var(--red-glow);
    }
    .btn-red:hover { transform: translateY(-1px); box-shadow: 0 6px 18px var(--red-glow); }

    .btn-ghost {
      background: rgba(255,255,255,0.05);
      color: #aaa;
      border: 1px solid var(--border);
    }
    .btn-ghost:hover { background: rgba(255,255,255,0.09); color: #fff; border-color: rgba(255,255,255,0.14); }

    .btn-danger {
      background: rgba(232,0,13,0.10);
      color: var(--red);
      border: 1px solid rgba(232,0,13,0.20);
    }
    .btn-danger:hover { background: rgba(232,0,13,0.20); }

    .btn-actions { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }

    /* ── EMPTY STATE ── */
    .empty-row td {
      text-align: center;
      padding: 32px;
      color: var(--muted);
      font-size: 14px;
    }
    .empty-row td i { font-size: 28px; display: block; margin-bottom: 8px; opacity: 0.4; }

    /* ── POPUP OVERLAY ── */
    .overlay {
      display: none;
      position: fixed; inset: 0;
      background: rgba(0,0,0,0.75);
      backdrop-filter: blur(6px);
      z-index: 200;
      align-items: center;
      justify-content: center;
    }
    .overlay.open { display: flex; }

    .popup {
      background: var(--surface);
      border: 1px solid rgba(232,0,13,0.35);
      border-radius: 20px;
      padding: 32px 30px;
      width: 100%;
      max-width: 620px;
      max-height: 90vh;
      overflow-y: auto;
      position: relative;
      box-shadow: 0 0 60px rgba(0,0,0,0.7), 0 0 30px var(--red-glow);
      animation: popIn 0.28s cubic-bezier(0.22,1,0.36,1) both;
    }
    @keyframes popIn {
      from { opacity:0; transform: scale(0.94) translateY(16px); }
      to   { opacity:1; transform: scale(1)    translateY(0); }
    }

    .popup-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 24px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--border);
    }
    .popup-title {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 24px;
      letter-spacing: 2px;
    }
    .popup-title span { color: var(--red); }

    .popup-close {
      width: 34px; height: 34px;
      border-radius: 8px;
      background: rgba(255,255,255,0.06);
      border: 1px solid var(--border);
      color: #888;
      font-size: 16px;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      transition: 0.2s;
    }
    .popup-close:hover { background: rgba(232,0,13,0.15); color: var(--red); border-color: rgba(232,0,13,0.3); }

    /* ── FORM ── */
    .form-section-label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1px;
      color: var(--red);
      margin: 20px 0 12px;
    }
    .form-section-label:first-of-type { margin-top: 0; }

    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }
    .form-grid.full { grid-template-columns: 1fr; }

    .form-group { display: flex; flex-direction: column; gap: 6px; }
    .form-group label {
      font-size: 12px;
      font-weight: 500;
      color: #777;
      text-transform: uppercase;
      letter-spacing: 0.4px;
    }
    .form-group input,
    .form-group select {
      background: var(--surface2);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 10px 14px;
      color: var(--text);
      font-family: 'Outfit', sans-serif;
      font-size: 14px;
      outline: none;
      transition: 0.2s;
    }
    .form-group input:focus,
    .form-group select:focus {
      border-color: rgba(232,0,13,0.55);
      box-shadow: 0 0 0 3px rgba(232,0,13,0.10);
    }
    .form-group input::placeholder { color: #3a3a3a; }
    .form-group select option { background: #1a1a1a; }

    /* file input */
    .form-group input[type="file"] {
      padding: 8px 12px;
      color: #888;
      cursor: pointer;
    }
    .form-group input[type="file"]::-webkit-file-upload-button {
      background: rgba(232,0,13,0.15);
      border: 1px solid rgba(232,0,13,0.3);
      color: var(--red);
      border-radius: 6px;
      padding: 4px 10px;
      cursor: pointer;
      font-family: 'Outfit', sans-serif;
      font-size: 12px;
      margin-right: 8px;
    }

    .popup-actions {
      display: flex;
      gap: 10px;
      margin-top: 24px;
      padding-top: 18px;
      border-top: 1px solid var(--border);
    }
    .popup-actions .btn { flex: 1; justify-content: center; padding: 12px; font-size: 15px; letter-spacing: 0.5px; }

    /* ── ANIMATION ── */
    @keyframes fadeUp {
      from { opacity:0; transform: translateY(14px); }
      to   { opacity:1; transform: translateY(0); }
    }

    /* Scrollbar */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #2a2a2a; border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: #3a3a3a; }
  </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
  <div class="page-header-icon"><i class="fa-solid fa-fingerprint"></i></div>
  <div>
    <h2><span>Members</span> Management</h2>
  </div>
</div>

<!-- NEW FINGERPRINT USERS -->
<div class="section-card">
  <div class="section-title">
    <i class="fa-solid fa-user-plus"></i>
    New Fingerprint Users
    <span class="badge">LIVE</span>
  </div>
  <div class="tbl-wrap">
    <table>
      <thead>
      <tr>
        <th>#</th>
        <th>Fingerprint ID</th>
        <th>Actions</th>
      </tr>
      </thead>
      <tbody id="newUsersTable">
      <%
        int i = 1;
        boolean hasNew = false;
        for (String user : users) {
          String userId = user.split("\\|")[0]
                  .replace("👤 ID:", "")
                  .replaceAll("[^0-9]", "")
                  .trim();
          boolean isSaved = savedMembers.contains(userId);
          if (isSaved) continue;
          hasNew = true;
      %>
      <tr>
        <td><%= i++ %></td>
        <td><span class="fp-id"><%= user %></span></td>
        <td>
          <div class="btn-actions">
            <button class="btn btn-red" onclick="openPopup('<%= userId %>')">
              <i class="fa-solid fa-plus"></i> Add Member
            </button>
            <form action="fingerprint-data" method="post" style="display:inline;">
              <input type="hidden" name="action" value="deleteDeviceUser">
              <input type="hidden" name="fid" value="<%= userId %>">
              <button type="submit" class="btn btn-danger"
                      onclick="return confirm('Delete this fingerprint from device?')">
                <i class="fa-solid fa-trash"></i>
              </button>
            </form>
          </div>
        </td>
      </tr>
      <% } %>
      <% if (!hasNew) { %>
      <tr class="empty-row">
        <td colspan="3">
          <i class="fa-solid fa-fingerprint"></i>
          No new fingerprint users detected
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>

<!-- SAVED MEMBERS -->
<div class="section-card">
  <div class="section-title">
    <i class="fa-solid fa-users"></i>
    Saved Members
  </div>
  <div class="tbl-wrap">
    <table>
      <thead>
      <tr>
        <th>FP ID</th>
        <th>Name</th>
        <th>Gender</th>
        <th>WhatsApp</th>
        <th>Package</th>
        <th>Start</th>
        <th>End</th>
        <th>Actions</th>
      </tr>
      </thead>
      <tbody>
      <%
        boolean hasMembers = false;
        try (Connection con = DatabaseUtil.getConnection()) {
          String sql = "SELECT md.id AS member_id, md.fingerprint_id, md.full_name, md.gender, md.whatsapp, " +
                  "ms.months, ms.start_date, ms.end_date " +
                  "FROM member_details md " +
                  "LEFT JOIN membership_details ms ON md.id = ms.member_id";
          try (PreparedStatement ps = con.prepareStatement(sql);
               ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
              hasMembers = true;
      %>
      <tr>
        <td><span class="fp-id"><%= rs.getString("fingerprint_id") %></span></td>
        <td><span class="member-name"><%= rs.getString("full_name") %></span></td>
        <td><%= rs.getString("gender") != null ? rs.getString("gender") : "–" %></td>
        <td><%= rs.getString("whatsapp") != null ? rs.getString("whatsapp") : "–" %></td>
        <td>
          <% if (rs.getObject("months") != null) { %>
          <span style="background:rgba(232,0,13,0.12); color:var(--red); padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600; border:1px solid rgba(232,0,13,0.22);">
                <%= rs.getInt("months") %> Mo
              </span>
          <% } else { %>
          <span style="color:var(--muted);">N/A</span>
          <% } %>
        </td>
        <td><%= rs.getString("start_date") != null ? rs.getString("start_date") : "–" %></td>
        <td><%= rs.getString("end_date")   != null ? rs.getString("end_date")   : "–" %></td>
        <td>
          <div class="btn-actions">
            <a href="view-member?fid=<%= rs.getString("fingerprint_id") %>&mode=membership"
               target="contentFrame" class="btn btn-ghost">
              <i class="fa-solid fa-credit-card"></i> Payment
            </a>
            <form action="view-member" method="get" style="display:inline;">
              <input type="hidden" name="fid" value="<%= rs.getString("fingerprint_id") %>">
              <button type="submit" class="btn btn-ghost">
                <i class="fa-regular fa-eye"></i> View
              </button>
            </form>
          </div>
        </td>
      </tr>
      <%
          }
        }
      } catch (Exception e) {
      %>
      <tr class="empty-row">
        <td colspan="8">
          <i class="fa-solid fa-circle-exclamation"></i>
          Error loading members: <%= e.getMessage() %>
        </td>
      </tr>
      <%
        }
        if (!hasMembers) {
      %>
      <tr class="empty-row">
        <td colspan="8">
          <i class="fa-solid fa-users"></i>
          No members saved yet
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
</div>

<!-- ═══════════ ADD MEMBER POPUP ═══════════ -->
<div class="overlay" id="overlay">
  <div class="popup">
    <div class="popup-header">
      <div class="popup-title">Add <span>Member</span></div>
      <button class="popup-close" onclick="closePopup()">
        <i class="fa-solid fa-xmark"></i>
      </button>
    </div>

    <form action="save-member" method="post" enctype="multipart/form-data">
      <input type="hidden" name="userId" id="userId">

      <div class="form-section-label"><i class="fa-solid fa-user" style="margin-right:6px;"></i>Personal Details</div>
      <div class="form-grid">
        <div class="form-group">
          <label>Full Name *</label>
          <input type="text" name="name" placeholder="John Doe" required>
        </div>
        <div class="form-group">
          <label>Admission No *</label>
          <input type="text" name="admissionNo" placeholder="ADM-001" required>
        </div>
        <div class="form-group">
          <label>Phone *</label>
          <div style="display:flex; align-items:center; background: var(--surface2); border:1px solid var(--border); border-radius:10px; overflow:hidden;">
    <span style="padding:10px 14px; color:#aaa; background:#1a1a1a; border-right:1px solid var(--border); font-weight:600;">
      +94
    </span>
            <input
                    type="text"
                    name="phone"
                    id="phone"
                    placeholder="77XXXXXXX"
                    maxlength="9"
                    required
                    pattern="[0-9]{9}"
                    inputmode="numeric"
                    oninput="onlyNumbers(this)"
                    style="border:none; background:transparent; flex:1; box-shadow:none;"
                    title="Enter 9 digit mobile number"
            >
          </div>
        </div>

        <div class="form-group">
          <label>WhatsApp *</label>
          <div style="display:flex; align-items:center; background: var(--surface2); border:1px solid var(--border); border-radius:10px; overflow:hidden;">
    <span style="padding:10px 14px; color:#aaa; background:#1a1a1a; border-right:1px solid var(--border); font-weight:600;">
      +94
    </span>
            <input
                    type="text"
                    name="whatsapp"
                    id="whatsapp"
                    placeholder="77XXXXXXX"
                    maxlength="9"
                    required
                    pattern="[0-9]{9}"
                    inputmode="numeric"
                    oninput="onlyNumbers(this)"
                    style="border:none; background:transparent; flex:1; box-shadow:none;"
                    title="Enter 9 digit WhatsApp number"
            >
          </div>
        </div>
        <div class="form-group">
          <label>Gender</label>
          <select name="gender">
            <option value="">Select</option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          </select>
        </div>
        <div class="form-group">
          <label>Age</label>
          <input type="number" name="age" placeholder="25" min="1" max="120">
        </div>
        <div class="form-group">
          <label>Birthday</label>
          <input type="date" name="birthdayDate">
        </div>
        <div class="form-group">
          <label>Address</label>
          <input type="text" name="address" placeholder="No. 1, Main St">
        </div>
      </div>

      <div class="form-grid full" style="margin-top:4px;">
        <div class="form-group">
          <label>Photo</label>
          <input type="file" name="photo" accept="image/*">
        </div>
      </div>

      <div class="form-section-label" style="margin-top:20px;">
        <i class="fa-solid fa-id-card" style="margin-right:6px;"></i>Membership Package
      </div>
      <div class="form-grid">
        <div class="form-group">
          <label>Package Duration</label>
          <select name="months" onchange="calc(this.value)">
            <% for (int m = 1; m <= 12; m++) { %>
            <option value="<%= m %>"><%= m %> Month<%= m > 1 ? "s" : "" %></option>
            <% } %>
          </select>
        </div>
        <div class="form-group">
          <label>Start Date</label>
          <input type="date" id="startDate" name="startDate" oninput="calc(document.querySelector('[name=months]').value)">
        </div>
        <div class="form-group">
          <label>End Date</label>
          <input type="date" id="endDate" name="endDate" readonly
                 style="opacity:0.6; cursor:not-allowed;">
        </div>
        <div class="form-group">
          <label>Membership Amount (Rs)</label>
          <input type="number" name="amount" placeholder="0.00" required>
        </div>
        <div class="form-group">
          <label>Registration Fee (Rs)</label>
          <input type="number" name="regFee" placeholder="0.00" required>
        </div>
      </div>

      <div class="popup-actions">
        <button type="button" class="btn btn-ghost" onclick="closePopup()">
          <i class="fa-solid fa-xmark"></i> Cancel
        </button>
        <button type="submit" class="btn btn-red">
          <i class="fa-solid fa-floppy-disk"></i> Save Member
        </button>
      </div>
    </form>
  </div>
</div>

<script>
  function openPopup(id) {
    document.getElementById("overlay").classList.add("open");
    document.getElementById("userId").value = id;
    const today = new Date().toISOString().split("T")[0];
    document.getElementById("startDate").value = today;
    calc(1);
  }

  function closePopup() {
    document.getElementById("overlay").classList.remove("open");
  }

  // Close on overlay click
  document.getElementById("overlay").addEventListener("click", function(e) {
    if (e.target === this) closePopup();
  });

  function calc(months) {
    const start = new Date(document.getElementById("startDate").value);
    if (isNaN(start)) return;
    const end = new Date(start);
    end.setMonth(end.getMonth() + parseInt(months));
    document.getElementById("endDate").value = end.toISOString().split("T")[0];
  }

  // Live refresh – new users table only
  setInterval(function () {
    fetch('fingerprint-data?page=users')
            .then(res => res.text())
            .then(html => {
              const parser = new DOMParser();
              const doc = parser.parseFromString(html, 'text/html');
              const newTbody  = doc.querySelector("#newUsersTable");
              const currTbody = document.querySelector("#newUsersTable");
              if (newTbody && currTbody) currTbody.innerHTML = newTbody.innerHTML;
            });
  }, 3000);

  function onlyNumbers(input) {
    input.value = input.value.replace(/[^0-9]/g, '');
  }

</script>

<script src="attendance-popup.js"></script>
</body>
</html>
