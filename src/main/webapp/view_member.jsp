<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Member Profile – City Gym</title>
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
            justify-content: space-between;
            margin-bottom: 24px;
            animation: fadeUp 0.4s ease both;
        }
        .page-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .page-header-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--red), var(--red-dim));
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px;
            box-shadow: 0 6px 16px var(--red-glow);
        }
        .page-header h2 {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 28px;
            letter-spacing: 2px;
        }
        .page-header h2 span { color: var(--red); }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 16px;
            border-radius: 10px;
            background: rgba(255,255,255,0.05);
            border: 1px solid var(--border);
            color: #888;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: 0.2s;
        }
        .back-btn:hover { color: #fff; border-color: rgba(255,255,255,0.15); background: rgba(255,255,255,0.08); }

        /* ── LAYOUT ── */
        .profile-grid {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 20px;
            animation: fadeUp 0.4s 0.05s ease both;
        }

        /* ── LEFT COLUMN – PHOTO + QUICK STATS ── */
        .profile-left { display: flex; flex-direction: column; gap: 16px; }

        .photo-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 14px;
        }

        .photo-wrap {
            width: 120px; height: 120px;
            border-radius: 50%;
            border: 3px solid rgba(232,0,13,0.45);
            box-shadow: 0 0 24px var(--red-glow);
            overflow: hidden;
            background: var(--surface2);
            display: flex; align-items: center; justify-content: center;
        }
        .photo-wrap img {
            width: 100%; height: 100%;
            object-fit: cover;
        }
        .photo-wrap .photo-fallback {
            font-size: 42px;
            color: #333;
        }

        .member-name-big {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 22px;
            letter-spacing: 1.5px;
            text-align: center;
        }
        .member-id-badge {
            background: rgba(232,0,13,0.12);
            color: var(--red);
            font-size: 12px;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 20px;
            border: 1px solid rgba(232,0,13,0.25);
            letter-spacing: 0.5px;
        }

        /* Days remaining pill */
        .days-pill {
            width: 100%;
            border-radius: 12px;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 600;
        }
        .days-pill.green {
            background: rgba(0,200,80,0.08);
            border: 1px solid rgba(0,200,80,0.20);
            color: #00c850;
        }
        .days-pill.orange {
            background: rgba(255,160,0,0.08);
            border: 1px solid rgba(255,160,0,0.22);
            color: #ffa000;
        }
        .days-pill.red {
            background: rgba(232,0,13,0.10);
            border: 1px solid rgba(232,0,13,0.25);
            color: var(--red);
        }
        .days-pill .pill-label { color: #666; font-weight: 500; }
        .days-pill .pill-value {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 22px;
            letter-spacing: 1px;
        }

        /* Action buttons card */
        .action-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .action-card .section-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--muted);
            margin-bottom: 4px;
        }

        /* ── RIGHT COLUMN ── */
        .profile-right { display: flex; flex-direction: column; gap: 16px; }

        .info-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 22px 24px;
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--muted);
            margin-bottom: 18px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
        }
        .card-title i { color: var(--red); font-size: 14px; }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .info-item { display: flex; flex-direction: column; gap: 4px; }
        .info-label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted);
        }
        .info-value {
            font-size: 15px;
            font-weight: 500;
            color: #e0e0e0;
        }
        .info-value.highlight {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 20px;
            color: var(--red);
            letter-spacing: 1px;
        }

        /* Package badge */
        .pkg-badge {
            display: inline-block;
            background: rgba(232,0,13,0.12);
            color: var(--red);
            font-size: 13px;
            font-weight: 600;
            padding: 4px 14px;
            border-radius: 20px;
            border: 1px solid rgba(232,0,13,0.22);
        }

        /* ── BUTTONS ── */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            padding: 10px 18px;
            border-radius: 10px;
            font-family: 'Outfit', sans-serif;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
            text-decoration: none;
            width: 100%;
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
        .btn-ghost:hover { background: rgba(255,255,255,0.09); color: #fff; }
        .btn-danger {
            background: rgba(232,0,13,0.10);
            color: var(--red);
            border: 1px solid rgba(232,0,13,0.22);
        }
        .btn-danger:hover { background: rgba(232,0,13,0.20); }
        .btn-success {
            background: rgba(0,180,70,0.12);
            color: #00b846;
            border: 1px solid rgba(0,180,70,0.22);
        }
        .btn-success:hover { background: rgba(0,180,70,0.22); }

        /* ── EDIT SECTION ── */
        #editSection { display: none; }
        #personalEditCard,
        #membershipEditCard { display: none; }

        .edit-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted);
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
        .form-group input[type="file"] {
            padding: 8px 12px; color: #888; cursor: pointer;
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
        .form-group input[readonly] { opacity: 0.5; cursor: not-allowed; }

        .edit-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid var(--border);
        }
        .edit-actions .btn { flex: 1; padding: 12px; }

        /* ── ANIMATION ── */
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(14px); }
            to   { opacity:1; transform:translateY(0); }
        }

        ::-webkit-scrollbar { width:6px; height:6px; }
        ::-webkit-scrollbar-track { background:transparent; }
        ::-webkit-scrollbar-thumb { background:#2a2a2a; border-radius:4px; }

        @media (max-width: 860px) {
            .profile-grid { grid-template-columns: 1fr; }
            .info-grid { grid-template-columns: 1fr 1fr; }
            .edit-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-left">
        <div class="page-header-icon"><i class="fa-solid fa-user"></i></div>
        <h2>Member <span>Profile</span></h2>
    </div>
    <a href="fingerprint-data?page=users" class="back-btn" target="contentFrame">
        <i class="fa-solid fa-arrow-left"></i> Back to Members
    </a>
</div>

<!-- ═══════════════════ VIEW SECTION ═══════════════════ -->
<div id="viewSection">
    <div class="profile-grid">

        <!-- LEFT -->
        <div class="profile-left">

            <!-- Photo + Name -->
            <div class="photo-card">
                <div class="photo-wrap">
                    <img src="view-member?fid=${fid}&type=image" alt="Member photo"
                         onerror="this.style.display='none'; document.getElementById('photoFallback').style.display='flex'">
                    <div id="photoFallback" class="photo-fallback" style="display:none;">
                        <i class="fa-solid fa-user"></i>
                    </div>
                </div>
                <div class="member-name-big">${name}</div>
                <div class="member-id-badge">ID: ${admissionNo}</div>
            </div>

            <!-- Days remaining -->
            <div id="daysPill" class="days-pill green">
                <span class="pill-label">Days Remaining</span>
                <span class="pill-value" id="daysLeft">–</span>
            </div>

            <!-- Action buttons -->
            <div class="action-card">
                <div class="section-label">Actions</div>
                <button type="button" class="btn btn-red" onclick="showEdit('personal')">
                    <i class="fa-solid fa-pen"></i> Edit Member Details
                </button>
                <button type="button" class="btn btn-success" onclick="showEdit('membership')">
                    <i class="fa-solid fa-credit-card"></i> Update Membership
                </button>
                <form action="view-member" method="post" style="width:100%;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="fid" value="${fid}">
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('Are you sure you want to delete this member?')">
                        <i class="fa-solid fa-trash"></i> Delete Member
                    </button>
                </form>
            </div>

        </div>

        <!-- RIGHT -->
        <div class="profile-right">

            <!-- Personal Info -->
            <div class="info-card">
                <div class="card-title">
                    <i class="fa-solid fa-circle-info"></i> Personal Information
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Full Name</span>
                        <span class="info-value">${name}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Admission No</span>
                        <span class="info-value">${admissionNo}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Phone</span>
                        <span class="info-value">${phone}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">WhatsApp</span>
                        <span class="info-value">${whatsapp}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Gender</span>
                        <span class="info-value">${gender}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Age</span>
                        <span class="info-value">${age}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Birthday</span>
                        <span class="info-value">${birthdayDate}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Address</span>
                        <span class="info-value">${address}</span>
                    </div>
                </div>
            </div>

            <!-- Membership Info -->
            <div class="info-card">
                <div class="card-title">
                    <i class="fa-solid fa-id-card"></i> Membership Details
                </div>
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Package</span>
                        <span class="info-value">
              <span class="pkg-badge">${months} Months</span>
            </span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Start Date</span>
                        <span class="info-value">${startDate}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">End Date</span>
                        <span class="info-value">${endDate}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Membership Amount</span>
                        <span class="info-value highlight">Rs. ${amount}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Registration Fee</span>
                        <span class="info-value">Rs. ${regFee}</span>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ═══════════════════ EDIT SECTION ═══════════════════ -->
<div id="editSection">

    <div class="profile-grid">
        <div class="profile-left">
            <!-- Photo preview stays -->
            <div class="photo-card">
                <div class="photo-wrap">
                    <img src="view-member?fid=${fid}&type=image" alt="Member photo"
                         onerror="this.style.display='none'">
                </div>
                <div class="member-name-big">${name}</div>
                <div class="member-id-badge">Editing Profile</div>
            </div>
        </div>

        <div class="profile-right">
            <div id="personalEditCard" class="info-card" style="margin-bottom:16px;">
                <form action="view-member" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="updatePersonal">
                    <input type="hidden" name="fid" value="${fid}">

                    <!-- Personal -->
                    <div class="card-title">
                        <i class="fa-solid fa-circle-info"></i> Personal Information
                    </div>
                    <div class="edit-grid">
                        <div class="form-group" style="grid-column:1/-1;">
                            <label>Change Photo</label>
                            <input type="file" name="photo" accept="image/*">
                        </div>
                        <div class="form-group">
                            <label>Full Name *</label>
                            <input type="text" name="name" value="${name}" required>
                        </div>
                        <div class="form-group">
                            <label>Admission No *</label>
                            <input type="text" name="admissionNo" value="${admissionNo}" required>
                        </div>
                        <div class="form-group">
                            <label>Phone</label>
                            <input type="text" name="phone" value="${phone}">
                        </div>
                        <div class="form-group">
                            <label>WhatsApp</label>
                            <input type="text" name="whatsapp" value="${whatsapp}">
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="gender">
                                <option value="Male"   ${'Male'.equals(gender)   ? 'selected' : ''}>Male</option>
                                <option value="Female" ${'Female'.equals(gender) ? 'selected' : ''}>Female</option>
                                <option value="Other"  ${'Other'.equals(gender)  ? 'selected' : ''}>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Age</label>
                            <input type="number" name="age" value="${age}" min="1" max="120">
                        </div>
                        <div class="form-group">
                            <label>Birthday</label>
                            <input type="date" name="birthdayDate" value="${birthdayDate}">
                        </div>
                        <div class="form-group" style="grid-column:1/-1;">
                            <label>Address</label>
                            <input type="text" name="address" value="${address}">
                        </div>
                    </div>
                    <div class="edit-actions">
                        <button type="button" class="btn btn-ghost" onclick="cancelEdit()">
                            <i class="fa-solid fa-xmark"></i> Cancel
                        </button>
                        <button type="submit" class="btn btn-red">
                            <i class="fa-solid fa-floppy-disk"></i> Save Personal Info
                        </button>
                    </div>
                </form>
            </div>

            <div id="membershipEditCard" class="info-card">
                <form id="paymentForm" method="post">
                    <input type="hidden" name="memberId" value="${memberId}">

                    <div class="card-title">
                        <i class="fa-solid fa-id-card"></i> Membership Details & Payment
                    </div>
                    <div class="edit-grid">
                        <div class="form-group">
                            <label>Package Duration</label>
                            <select name="months" id="editMonths" onchange="calcEdit(this.value)">
                                <% for(int m = 1; m <= 12; m++){ %>
                                <option value="<%= m %>"
                                        <%= (request.getAttribute("months") != null && ((Integer)request.getAttribute("months") == m)) ? "selected" : "" %>>
                                    <%= m %> Month<%= m > 1 ? "s" : "" %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Start Date</label>
                            <input type="date" name="startDate" id="editStartDate" value="${startDate}" required
                                   oninput="calcEdit(document.querySelector('[name=months]').value)">
                        </div>
                        <div class="form-group">
                            <label>End Date</label>
                            <input type="date" name="endDate" id="editEndDate" value="${endDate}" required readonly>
                        </div>
                        <div class="form-group">
                            <label>Membership Amount (Rs)</label>
                            <input type="number" name="amount" value="${amount}" required>
                        </div>
                        <div class="form-group">
                            <label>Registration Fee (Rs)</label>
                            <input type="number" name="regFee" value="${regFee}" required>
                        </div>
                    </div>

                    <div class="edit-actions">
                        <button type="button" class="btn btn-ghost" onclick="cancelEdit()">
                            <i class="fa-solid fa-xmark"></i> Cancel
                        </button>
                        <button type="submit" class="btn btn-red">
                            <i class="fa-solid fa-credit-card"></i> Save Payment & Send Receipt
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // Section toggle
    function showEdit(mode) {
        document.getElementById("viewSection").style.display = "none";
        document.getElementById("editSection").style.display = "block";
        document.getElementById("personalEditCard").style.display = mode === "membership" ? "none" : "block";
        document.getElementById("membershipEditCard").style.display = mode === "personal" ? "none" : "block";

        if (mode === "membership" && !document.getElementById("editStartDate").value) {
            document.getElementById("editStartDate").value = new Date().toISOString().split("T")[0];
        }
        if (mode === "membership") {
            calcEdit(document.getElementById("editMonths").value);
        }
    }
    function cancelEdit() {
        document.getElementById("viewSection").style.display = "block";
        document.getElementById("editSection").style.display = "none";
    }

    // End date auto-calc (edit form)
    function calcEdit(months) {
        const start = new Date(document.getElementById("editStartDate").value);
        if (isNaN(start)) return;
        const end = new Date(start);
        end.setMonth(end.getMonth() + parseInt(months));
        document.getElementById("editEndDate").value = end.toISOString().split("T")[0];
    }

    // Payment save for membership section
    let paymentSubmitting = false;
    document.getElementById("paymentForm").addEventListener("submit", async function (e) {
        e.preventDefault();

        if (paymentSubmitting) {
            return;
        }

        paymentSubmitting = true;
        const submitButton = this.querySelector('button[type="submit"]');
        submitButton.disabled = true;
        submitButton.textContent = 'Saving...';

        calcEdit(document.getElementById("editMonths").value);

        const formData = new FormData(this);
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
            window.location.href = '${pageContext.request.contextPath}/view-member?fid=${fid}';
        } else {
            alert(text || 'Failed to save payment.');
            paymentSubmitting = false;
            submitButton.disabled = false;
            submitButton.textContent = 'Save Payment & Send Receipt';
        }
    });

    // Days remaining pill
    window.addEventListener('load', function () {
        const endDateStr = "${endDate}";
        const mode = new URLSearchParams(window.location.search).get("mode");

        if (mode === "personal" || mode === "membership") {
            showEdit(mode);
        }

        if (!endDateStr) return;

        const today   = new Date();
        const endDate = new Date(endDateStr);
        const days    = Math.ceil((endDate - today) / (1000 * 60 * 60 * 24));
        const pill    = document.getElementById("daysPill");
        const el      = document.getElementById("daysLeft");

        if (days < 0) {
            el.textContent = "Expired";
            pill.className = "days-pill red";
        } else if (days <= 7) {
            el.textContent = days + " days";
            pill.className = "days-pill orange";
        } else {
            el.textContent = days + " days";
            pill.className = "days-pill green";
        }
    });
</script>

<script src="attendance-popup.js"></script>
<%@ include file="footer.jsp" %>
</body>
</html>
