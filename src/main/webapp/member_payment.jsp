<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (request.getAttribute("members") == null) {
        response.sendRedirect("member-payment");
        return;
    }

    List<Map<String, Object>> members = (List<Map<String, Object>>) request.getAttribute("members");
    List<Map<String, Object>> recentPayments = (List<Map<String, Object>>) request.getAttribute("recentPayments");
    Map<String, Object> selectedMember = (Map<String, Object>) request.getAttribute("selectedMember");
    int selectedMemberId = selectedMember != null && selectedMember.get("id") != null
            ? (Integer) selectedMember.get("id")
            : -1;
%>

<!DOCTYPE html>
<html>
<head>
    <title>Membership & Payment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #f4f6f9; }
        .page { padding: 24px; }
        .grid { display: grid; grid-template-columns: 1.1fr 0.9fr; gap: 20px; align-items: start; }
        .card { background: #fff; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); padding: 20px; }
        h2, h3 { margin-top: 0; }
        label { display: block; margin-top: 12px; font-weight: bold; }
        input, select { width: 100%; padding: 10px; box-sizing: border-box; margin-top: 6px; }
        button { margin-top: 18px; padding: 11px 16px; border: 0; border-radius: 8px; background: #0a7; color: #fff; cursor: pointer; font-weight: bold; }
        button:hover { background: #086; }
        .muted { color: #666; }
        .summary { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px; }
        .summary div { background: #f8f8f8; padding: 10px; border-radius: 8px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background: #f1f1f1; }
        .status-active { color: #0a7; font-weight: bold; }
        .status-expired { color: #d33; font-weight: bold; }
    </style>
</head>
<body>

<div class="page">
    <div class="card" style="margin-bottom:20px;">
        <h2>Membership & Payment</h2>
        <p class="muted">Choose a member, record the membership payment, and send the WhatsApp receipt automatically.</p>
    </div>

    <div class="grid">
        <div class="card">
            <h3>Record a Payment</h3>

            <form id="paymentForm" method="post">
                <label for="memberId">Member</label>
                <select id="memberId" name="memberId" required onchange="goToMember(this.value)">
                    <option value="">-- Select member --</option>
                    <% for (Map<String, Object> member : members) { %>
                        <option value="<%= member.get("id") %>" <%= ((Integer) member.get("id") == selectedMemberId) ? "selected" : "" %>>
                            <%= member.get("fullName") %> (<%= member.get("fingerprintId") %>)
                        </option>
                    <% } %>
                </select>

                <label for="amount">Amount (Rs.)</label>
                <input type="number" id="amount" name="amount" step="0.01" min="0" required>

                <label for="months">Months</label>
                <input type="number" id="months" name="months" min="1" max="12" required>

                <label for="startDate">Start Date</label>
                <input type="date" id="startDate" name="startDate" required>

                <label for="endDate">End Date</label>
                <input type="date" id="endDate" name="endDate" readonly>

                <button type="submit">Save Payment & Send WhatsApp Receipt</button>
            </form>
        </div>

        <div class="card">
            <h3>Selected Member Summary</h3>
            <% if (selectedMember != null) { %>
                <div class="summary">
                    <div><strong>Name</strong><br><%= selectedMember.get("fullName") %></div>
                    <div><strong>Fingerprint ID</strong><br><%= selectedMember.get("fingerprintId") %></div>
                    <div><strong>WhatsApp</strong><br><%= selectedMember.get("whatsapp") != null ? selectedMember.get("whatsapp") : "-" %></div>
                    <div><strong>Status</strong><br><span class="<%= "Expired".equalsIgnoreCase(String.valueOf(selectedMember.get("daysLeft"))) ? "status-expired" : "status-active" %>"><%= selectedMember.get("daysLeft") %></span></div>
                    <div><strong>Package</strong><br><%= selectedMember.get("months") != null ? selectedMember.get("months") + " months" : "-" %></div>
                    <div><strong>End Date</strong><br><%= selectedMember.get("endDate") != null ? selectedMember.get("endDate") : "-" %></div>
                </div>
            <% } else { %>
                <p class="muted">Select a member from the dropdown to see membership details here.</p>
            <% } %>
        </div>
    </div>

    <div class="card" style="margin-top:20px;">
        <h3>Recent Payment History</h3>
        <table>
            <tr>
                <th>#</th>
                <th>Member</th>
                <th>WhatsApp</th>
                <th>Amount</th>
                <th>Months</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
            <% if (recentPayments != null && !recentPayments.isEmpty()) {
                for (Map<String, Object> payment : recentPayments) { %>
                <tr>
                    <td><%= payment.get("id") %></td>
                    <td><%= payment.get("fullName") %></td>
                    <td><%= payment.get("whatsapp") != null ? payment.get("whatsapp") : "-" %></td>
                    <td>Rs. <%= payment.get("amount") %></td>
                    <td><%= payment.get("months") %></td>
                    <td><%= payment.get("paymentDate") %></td>
                    <td><%= payment.get("status") %></td>
                </tr>
            <%   }
               } else { %>
                <tr><td colspan="7">No payment history yet.</td></tr>
            <% } %>
        </table>
    </div>
</div>

<script>
    const memberIdSelect = document.getElementById('memberId');
    const startDateInput = document.getElementById('startDate');
    const monthsInput = document.getElementById('months');
    const endDateInput = document.getElementById('endDate');

    function goToMember(memberId) {
        if (!memberId) return;
        window.location.href = '${pageContext.request.contextPath}/member-payment?memberId=' + encodeURIComponent(memberId);
    }

    function calculateEndDate() {
        if (!startDateInput.value || !monthsInput.value) {
            return;
        }

        const startDate = new Date(startDateInput.value);
        const months = parseInt(monthsInput.value, 10);
        if (Number.isNaN(startDate.getTime()) || Number.isNaN(months)) {
            return;
        }

        const endDate = new Date(startDate);
        endDate.setMonth(endDate.getMonth() + months);
        endDateInput.value = endDate.toISOString().split('T')[0];
    }

    if (!startDateInput.value) {
        startDateInput.value = new Date().toISOString().split('T')[0];
    }

    monthsInput.addEventListener('change', calculateEndDate);
    startDateInput.addEventListener('change', calculateEndDate);

    let isSubmitting = false;
    document.getElementById('paymentForm').addEventListener('submit', async function (e) {
        e.preventDefault();

        if (isSubmitting) {
            return;
        }

        if (!memberIdSelect.value) {
            alert('Please select a member first.');
            return;
        }

        isSubmitting = true;
        const submitButton = this.querySelector('button[type="submit"]');
        submitButton.disabled = true;
        submitButton.textContent = 'Saving...';

        calculateEndDate();

        const formData = new FormData(this);
        // Send urlencoded fields so HttpServletRequest#getParameter works without multipart handling.
        const payload = new URLSearchParams(formData);
        const response = await fetch('${pageContext.request.contextPath}/record-payment', {
            method: 'POST',
            body: payload,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            }
        });

        const text = await response.text();
        if (response.ok && text.startsWith('OK')) {
            alert('Payment saved successfully. WhatsApp receipt was triggered if the member has a WhatsApp number.');
            window.location.href = '${pageContext.request.contextPath}/member-payment?memberId=' + encodeURIComponent(memberIdSelect.value);
        } else {
            alert(text || 'Failed to save payment.');
            isSubmitting = false;
            submitButton.disabled = false;
            submitButton.textContent = 'Save Payment & Send WhatsApp Receipt';
        }
    });

    calculateEndDate();
</script>

<script src="attendance-popup.js"></script>
</body>
</html>
