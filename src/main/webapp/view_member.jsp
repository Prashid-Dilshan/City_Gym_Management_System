<%@ page contentType="text/html;charset=UTF-8" %>

<h2>👤 Member Profile</h2>

<!-- ================= VIEW SECTION ================= -->
<div id="viewSection">

    <!-- 🔥 PROFILE PHOTO -->
    <div style="margin-bottom:15px;">
        <img src="view-member?fid=${fid}&type=image" width="120" style="border-radius:10px;">
    </div>

    <table border="1" cellpadding="10">

        <tr><td>Name</td><td>${name}</td></tr>
        <tr><td>Phone</td><td>${phone}</td></tr>
        <tr><td>Gender</td><td>${gender}</td></tr>
        <tr><td>Age</td><td>${age}</td></tr>
        <tr><td>WhatsApp</td><td>${whatsapp}</td></tr>
        <tr><td>Address</td><td>${address}</td></tr>

        <tr><td>Package</td><td>${months} Months</td></tr>
        <tr><td>Start Date</td><td>${startDate}</td></tr>
        <tr><td>End Date</td><td>${endDate}</td></tr>

        <!-- 🔥 NEW -->
        <tr><td>Amount</td><td>${amount}</td></tr>
        <tr><td>Registration Fee</td><td>${regFee}</td></tr>

    </table>

    <br>

    <!-- 🔥 ACTION BUTTONS -->
    <button onclick="showEdit()">✏️ Update</button>

    <form action="view-member" method="post" style="display:inline;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="fid" value="${fid}">
        <button type="submit" onclick="return confirm('Are you sure to delete?')">❌ Delete</button>
    </form>

</div>

<!-- ================= EDIT SECTION ================= -->
<div id="editSection" style="display:none;">

    <form action="view-member" method="post" enctype="multipart/form-data">

        <input type="hidden" name="action" value="update">
        <input type="hidden" name="fid" value="${fid}">

        <table border="1" cellpadding="10">

            <tr>
                <td>Change Photo</td>
                <td><input type="file" name="photo" accept="image/*"></td>
            </tr>

            <tr><td>Name</td><td><input type="text" name="name" value="${name}" required></td></tr>
            <tr><td>Phone</td><td><input type="text" name="phone" value="${phone}"></td></tr>
            <tr><td>Gender</td><td><input type="text" name="gender" value="${gender}"></td></tr>
            <tr><td>Age</td><td><input type="number" name="age" value="${age}" required></td></tr>
            <tr><td>WhatsApp</td><td><input type="text" name="whatsapp" value="${whatsapp}"></td></tr>
            <tr><td>Address</td><td><input type="text" name="address" value="${address}"></td></tr>

            <!-- 🔥 PACKAGE -->
            <tr>
                <td>Months</td>
                <td>
                    <select name="months" onchange="calcEdit(this.value)">
                        <% for(int m=1; m<=12; m++){ %>
                        <option value="<%=m%>" <%= (request.getAttribute("months")!=null && ((Integer)request.getAttribute("months")==m))?"selected":"" %>>
                            <%=m%> Month
                        </option>
                        <% } %>
                    </select>
                </td>
            </tr>
            <tr><td>Start Date</td><td><input type="date" name="startDate" value="${startDate}" required></td></tr>
            <tr><td>End Date</td><td><input type="date" name="endDate" value="${endDate}" required></td></tr>

            <!-- 🔥 NEW -->
            <tr><td>Amount</td><td><input type="number" name="amount" value="${amount}" required></td></tr>
            <tr><td>Registration Fee</td><td><input type="number" name="regFee" value="${regFee}" required></td></tr>

        </table>

        <br>

        <button type="submit">💾 Save Changes</button>
        <button type="button" onclick="cancelEdit()">Cancel</button>

    </form>

</div>

<br><br>

<a href="fingerprint-data?page=users">⬅ Back to Members</a>

<!-- ================= JS ================= -->
<script>
    function showEdit(){
        document.getElementById("viewSection").style.display="none";
        document.getElementById("editSection").style.display="block";
    }

    function cancelEdit(){
        document.getElementById("viewSection").style.display="block";
        document.getElementById("editSection").style.display="none";
    }
</script>

<script>
    function calcEdit(months){
        let start = new Date(document.querySelector('[name="startDate"]').value);
        if(!start) return;

        let end = new Date(start);
        end.setMonth(end.getMonth()+parseInt(months));

        document.querySelector('[name="endDate"]').value =
            end.toISOString().split("T")[0];
    }
</script>