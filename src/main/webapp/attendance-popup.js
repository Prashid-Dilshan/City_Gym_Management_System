(function () {

    // ==============================================
    // 🔥 FIX 1: lastSeen sessionStorage එකේ save කරනවා
    // ඒ නිසා page navigate කළාත් time reset නොවෙනේ
    // ==============================================
    var KEY = 'att_last_seen';

    function getLastSeen() {
        var v = sessionStorage.getItem(KEY);
        // sessionStorage නැත්නම් — current server time ගන්නවා
        if (!v) {
            var now = Math.floor(Date.now() / 1000);
            sessionStorage.setItem(KEY, now);
            return now;
        }
        return parseInt(v);
    }

    function setLastSeen(ts) {
        sessionStorage.setItem(KEY, ts);
    }

    // Context path (e.g. /city_gym)
    function base() {
        var p = window.location.pathname.split('/');
        return p.length > 1 ? '/' + p[1] : '';
    }

    // ========================
    // 🔥 POLL EVERY 5 SECONDS
    // ========================
    function poll() {
        var lastSeen = getLastSeen();

        fetch(base() + '/attendance-stream?lastSeen=' + lastSeen, { cache: 'no-store' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.found) {
                    setLastSeen(data.ts); // 🔥 update sessionStorage
                    showPopup(data);
                }
            })
            .catch(function () {})
            .finally(function () {
                setTimeout(poll, 5000);
            });
    }

    // ========================
    // 🔥 POPUP UI
    // ========================
    function showPopup(data) {
        var old = document.getElementById('att-popup');
        if (old) old.remove();

        var expired = data.daysLeft === 'Expired';
        var warn    = !expired && !isNaN(parseInt(data.daysLeft)) && parseInt(data.daysLeft) <= 7;

        var color = expired ? '#dc3545' : warn ? '#fd7e14' : '#28a745';
        var icon  = expired ? '&#9888;&#65039;' : '&#9989;';
        var badge = expired ? 'MEMBERSHIP EXPIRED' : warn ? 'EXPIRING SOON' : 'ACTIVE';
        var soft  = expired ? '#fff5f5' : warn ? '#fff8f0' : '#f0fff4';

        var el = document.createElement('div');
        el.id = 'att-popup';
        el.style.cssText =
            'position:fixed;bottom:28px;right:28px;width:320px;' +
            'background:#fff;border-radius:14px;' +
            'box-shadow:0 12px 40px rgba(0,0,0,0.2);' +
            'font-family:Arial,sans-serif;z-index:2147483647;' +
            'overflow:hidden;border:1px solid ' + color + '33;' +
            'animation:attIn .45s cubic-bezier(.22,.68,0,1.2);';

        el.innerHTML =
            // Header
            '<div style="background:' + color + ';padding:12px 16px;' +
            'display:flex;justify-content:space-between;align-items:center;">' +
            '<span style="color:#fff;font-weight:bold;font-size:13px;">' +
            icon + '&nbsp; New Attendance' +
            '</span>' +
            '<span id="att-x" style="color:#fff;cursor:pointer;font-size:20px;line-height:1;">&#x2715;</span>' +
            '</div>' +

            // Body
            '<div style="padding:15px 17px;background:' + soft + ';">' +
            '<div style="font-size:17px;font-weight:bold;color:#1a1a1a;margin-bottom:11px;">' +
            '&#128100; ' + esc(data.name) +
            '</div>' +
            '<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:11px;">' +
            '<div style="background:#fff;border-radius:8px;padding:9px 11px;border:1px solid #eee;">' +
            '<div style="font-size:10px;color:#aaa;text-transform:uppercase;letter-spacing:.5px;margin-bottom:2px;">Admission No</div>' +
            '<div style="font-size:13px;font-weight:bold;color:#333;">&#128203; ' + esc(data.admNo) + '</div>' +
            '</div>' +
            '<div style="background:#fff;border-radius:8px;padding:9px 11px;border:1px solid #eee;">' +
            '<div style="font-size:10px;color:#aaa;text-transform:uppercase;letter-spacing:.5px;margin-bottom:2px;">Scan Time</div>' +
            '<div style="font-size:13px;font-weight:bold;color:#333;">&#128336; ' + esc(data.time) + '</div>' +
            '</div>' +
            '</div>' +
            '<div style="background:' + color + '18;border:1px solid ' + color + '44;' +
            'border-radius:8px;padding:10px 13px;' +
            'display:flex;justify-content:space-between;align-items:center;">' +
            '<span style="color:#555;font-size:13px;">Membership Remaining</span>' +
            '<span style="color:' + color + ';font-weight:bold;font-size:15px;">' + esc(data.daysLeft) + '</span>' +
            '</div>' +
            '<div style="margin-top:7px;text-align:right;font-size:10px;font-weight:bold;color:' + color + ';letter-spacing:1px;">' + badge + '</div>' +
            '</div>' +

            // Timer bar
            '<div style="height:3px;background:#e9ecef;">' +
            '<div id="att-bar" style="height:100%;width:100%;background:' + color + ';transition:width 8s linear;"></div>' +
            '</div>';

        document.body.appendChild(el);

        document.getElementById('att-x').onclick = function () { el.remove(); };

        // Animate bar
        requestAnimationFrame(function () {
            requestAnimationFrame(function () {
                var b = document.getElementById('att-bar');
                if (b) b.style.width = '0%';
            });
        });

        // Auto close 8s
        setTimeout(function () {
            var p = document.getElementById('att-popup');
            if (p) {
                p.style.transition = 'opacity .4s,transform .4s';
                p.style.opacity = '0';
                p.style.transform = 'translateX(110%)';
                setTimeout(function () {
                    var p2 = document.getElementById('att-popup');
                    if (p2) p2.remove();
                }, 420);
            }
        }, 8000);
    }

    function esc(s) {
        return s ? String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') : '';
    }

    // Keyframe CSS
    var st = document.createElement('style');
    st.textContent =
        '@keyframes attIn{' +
        'from{opacity:0;transform:translateX(110%) scale(.9)}' +
        'to{opacity:1;transform:translateX(0) scale(1)}}';
    document.head.appendChild(st);

    // Start
    setTimeout(poll, 2000);

})();