<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
  if (request.getAttribute("users") == null) {
    response.sendRedirect("fingerprint-data?page=users");
    return;
  }

  List<String> users = (List<String>) request.getAttribute("users");
  Set<String> savedMembers = (Set<String>) request.getAttribute("savedMembers");
%>

<h2>🆕 New Fingerprint Users</h2>

<!-- 🔥 ONLY THIS TABLE WILL AUTO REFRESH -->
<table id="newUsersTable" border="1" cellpadding="10">
  <tr>
    <th>#</th>
    <th>User</th>
    <th>Action</th>
  </tr>

  <%
    int i=1;

    for(String user: users){

      String userId = user.split("\\|")[0]
              .replace("👤 ID:", "")
              .replaceAll("[^0-9]", "")
              .trim();

      boolean isSaved = savedMembers != null && savedMembers.contains(userId);

      if(isSaved) continue;
  %>

  <tr>
    <td><%=i++%></td>
    <td><%=user%></td>
    <td>

      <!-- ➕ ADD -->
      <button onclick="openPopup('<%=userId%>')">➕ Add</button>

      <!-- 🗑 DELETE -->
      <form action="fingerprint-data" method="post" style="display:inline;">
        <input type="hidden" name="action" value="deleteDeviceUser">
        <input type="hidden" name="fid" value="<%=userId%>">
        <button type="submit" onclick="return confirm('Delete from device?')">
          🗑
        </button>
      </form>

    </td>
  </tr>

  <% } %>
</table>

<hr>

<h2>📋 Saved Members</h2>

<table border="1" cellpadding="10">
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Phone</th>
    <th>Package</th>
    <th>Start</th>
    <th>End</th>
    <th>Action</th>
  </tr>

  <%
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");

      Connection con = DriverManager.getConnection(
              "jdbc:mysql://localhost:3306/gym_system",
              "root",
              "1234"
      );

      String sql = "SELECT md.fingerprint_id, md.full_name, md.phone, " +
              "ms.months, ms.start_date, ms.end_date " +
              "FROM member_details md " +
              "LEFT JOIN membership_details ms ON md.id = ms.member_id";

      PreparedStatement ps = con.prepareStatement(sql);
      ResultSet rs = ps.executeQuery();

      while(rs.next()){
  %>

  <tr>
    <td><%=rs.getString("fingerprint_id")%></td>
    <td><%=rs.getString("full_name")%></td>
    <td><%=rs.getString("phone")%></td>

    <td>
      <%= rs.getObject("months") != null ? rs.getInt("months") + " Months" : "N/A" %>
    </td>

    <td><%= rs.getString("start_date") != null ? rs.getString("start_date") : "-" %></td>
    <td><%= rs.getString("end_date") != null ? rs.getString("end_date") : "-" %></td>

    <td>
      <form action="view-member" method="get">
        <input type="hidden" name="fid" value="<%=rs.getString("fingerprint_id")%>">
        <button type="submit">👁 View</button>
      </form>
    </td>

  </tr>

  <%
      }

      rs.close();
      ps.close();
      con.close();

    } catch(Exception e){
      out.println("Error: " + e.getMessage());
    }
  %>

</table>

<!-- ================= POPUP ================= -->

<div id="popup" style="display:none; position:fixed; top:10%; left:30%; width:40%; background:white; padding:20px; border:2px solid black;">

  <form action="save-member" method="post" enctype="multipart/form-data">

    <input type="hidden" name="userId" id="userId">

    <h3>Member Details</h3>

    Name: <input type="text" name="name" required><br>
    Admission No: <input type="text" name="admissionNo" required><br>
    Phone: <input type="text" name="phone"><br>
    Gender: <input type="text" name="gender"><br>
    Age: <input type="number" name="age"><br>
    WhatsApp: <input type="text" name="whatsapp"><br>
    Address: <input type="text" name="address"><br>

    <!-- 🔥 PHOTO -->
    Photo: <input type="file" name="photo"><br>

    <h3>Package</h3>

    <!-- 🔥 1–12 MONTHS -->
    <select name="months" onchange="calc(this.value)">
      <% for(int m=1; m<=12; m++){ %>
      <option value="<%=m%>"><%=m%> Month</option>
      <% } %>
    </select><br>

    Start: <input type="date" id="startDate" name="startDate"><br>
    End: <input type="date" id="endDate" name="endDate"><br>

    <!-- 🔥 NEW FIELDS -->
    Membership Amount: <input type="number" name="amount" required><br>
    Registration Fee: <input type="number" name="regFee" required><br>

    <button type="submit">Save</button>
  </form>

  <button type="button" onclick="closePopup()">Close</button>
</div>

<!-- ================= JS ================= -->

<script>
  function openPopup(id){
    document.getElementById("popup").style.display="block";
    document.getElementById("userId").value=id;

    let today = new Date().toISOString().split("T")[0];
    document.getElementById("startDate").value = today;
  }

  function closePopup(){
    document.getElementById("popup").style.display="none";
  }

  function calc(months){
    let start = new Date(document.getElementById("startDate").value);
    let end = new Date(start);
    end.setMonth(end.getMonth()+parseInt(months));
    document.getElementById("endDate").value = end.toISOString().split("T")[0];
  }

  // 🔥 AUTO LIVE REFRESH ONLY NEW USERS TABLE
  setInterval(function(){
    fetch('fingerprint-data?page=users')
            .then(res => res.text())
            .then(html => {

              let parser = new DOMParser();
              let doc = parser.parseFromString(html, 'text/html');

              let newTable = doc.querySelector("#newUsersTable");
              let currentTable = document.querySelector("#newUsersTable");

              if(newTable && currentTable){
                currentTable.innerHTML = newTable.innerHTML;
              }
            });
  }, 3000);
</script>

<script src="attendance-popup.js"></script>