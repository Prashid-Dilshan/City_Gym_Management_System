<%--
    Payment Processing Example JSP
    This shows how to integrate WhatsApp messaging when admin marks payment
--%>

<div class="payment-form">
    <h2>Record Member Payment</h2>

    <form id="paymentForm" method="POST" action="${pageContext.request.contextPath}/record-payment">
        <!-- Member Selection -->
        <label for="memberId">Select Member:</label>
        <input type="hidden" id="memberId" name="memberId" value="">

        <!-- Payment Amount -->
        <label for="amount">Amount (Rs.):</label>
        <input type="number" id="amount" name="amount" step="0.01" required>

        <!-- Membership Duration -->
        <label for="months">Months:</label>
        <input type="number" id="months" name="months" min="1" max="12" required>

        <!-- Start Date -->
        <label for="startDate">Start Date:</label>
        <input type="date" id="startDate" name="startDate" required>

        <!-- End Date (Auto-calculated) -->
        <label for="endDate">End Date:</label>
        <input type="date" id="endDate" name="endDate" readonly>

        <!-- Submit Button -->
        <button type="submit">Mark Payment & Send Receipt</button>
    </form>
</div>

<script>
// Auto-calculate end date when months change
document.getElementById("months").addEventListener("change", function() {
    const startDate = new Date(document.getElementById("startDate").value);
    const months = parseInt(this.value);
    const endDate = new Date(startDate.getFullYear(), startDate.getMonth() + months, startDate.getDate());

    // Format as YYYY-MM-DD
    const year = endDate.getFullYear();
    const month = String(endDate.getMonth() + 1).padStart(2, '0');
    const day = String(endDate.getDate()).padStart(2, '0');

    document.getElementById("endDate").value = `${year}-${month}-${day}`;
});

// Form submission with feedback
document.getElementById("paymentForm").addEventListener("submit", async function(e) {
    e.preventDefault();

    try {
        const formData = new FormData(this);
        const response = await fetch("${pageContext.request.contextPath}/record-payment", {
            method: "POST",
            body: formData
        });

        if (response.ok) {
            const text = await response.text();
            if (text.includes("OK")) {
                alert("✅ Payment recorded! WhatsApp receipt sent to member.");
                this.reset();
            } else {
                alert("⚠️ Payment recorded but WhatsApp may not have been sent.");
            }
        } else {
            alert("❌ Error: " + (await response.text()));
        }
    } catch (error) {
        console.error("Error:", error);
        alert("❌ Error submitting payment: " + error.message);
    }
});
</script>

<style>
.payment-form {
    max-width: 500px;
    margin: 20px auto;
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background-color: #f9f9f9;
}

.payment-form h2 {
    color: #333;
    margin-bottom: 20px;
}

.payment-form label {
    display: block;
    margin-top: 10px;
    font-weight: bold;
    color: #555;
}

.payment-form input {
    width: 100%;
    padding: 10px;
    margin-top: 5px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
    box-sizing: border-box;
}

.payment-form button {
    width: 100%;
    padding: 12px;
    margin-top: 20px;
    background-color: #4CAF50;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    transition: background-color 0.3s;
}

.payment-form button:hover {
    background-color: #45a049;
}

.payment-form button:active {
    background-color: #3d8b40;
}
</style>

