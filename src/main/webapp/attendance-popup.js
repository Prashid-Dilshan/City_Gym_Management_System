(function () {

    var KEY = 'att_last_seen';

    // ── POPUP QUEUE (stack from bottom) ──────────────────────────────────────
    var popupQueue = []; // array of DOM elements currently visible
    var POPUP_HEIGHT = 210; // approx height + gap per popup (px)

    function getLastSeen() {
        var v = sessionStorage.getItem(KEY);
        if (!v) {
            var now = Math.floor(Date.now() / 1000);
            sessionStorage.setItem(KEY, now);
            return now;
        }
        return parseInt(v);
    }

    function setLastSeen(ts) { sessionStorage.setItem(KEY, ts); }

    function base() {
        var p = window.location.pathname.split('/');
        return p.length > 1 ? '/' + p[1] : '';
    }

    // ── PLAY NOTIFICATION SOUND ───────────────────────────────────────────────
    function playSound() {
        try {
            var audio = new Audio(base() + '/tone/notification_tone.wav');
            audio.volume = 1.0;
            audio.play().catch(function () {});
        } catch (e) {}
    }

    // ── REPOSITION ALL POPUPS (bottom → top stack) ───────────────────────────
    function repositionAll() {
        var bottomOffset = 28;
        for (var i = 0; i < popupQueue.length; i++) {
            popupQueue[i].style.bottom = bottomOffset + 'px';
            bottomOffset += popupQueue[i].offsetHeight + 10;
        }
    }

    // ── REMOVE POPUP FROM QUEUE ───────────────────────────────────────────────
    function removePopup(el) {
        el.style.transition = 'opacity .35s, transform .35s';
        el.style.opacity    = '0';
        el.style.transform  = 'translateX(120%)';

        setTimeout(function () {
            if (el.parentNode) el.parentNode.removeChild(el);
            var idx = popupQueue.indexOf(el);
            if (idx > -1) popupQueue.splice(idx, 1);
            repositionAll();
        }, 360);
    }

    // ── POLL EVERY 5s ────────────────────────────────────────────────────────
    function poll() {
        var lastSeen = getLastSeen();
        fetch(base() + '/attendance-stream?lastSeen=' + lastSeen, { cache: 'no-store' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.found) {
                    setLastSeen(data.ts);
                    playSound();
                    showPopup(data);
                }
            })
            .catch(function () {})
            .finally(function () { setTimeout(poll, 5000); });
    }

    // ── BUILD POPUP ───────────────────────────────────────────────────────────
    function showPopup(data) {

        var expired = data.daysLeft === 'Expired' || (data.daysLeft && data.daysLeft.toString().startsWith('Expired'));
        var warn    = !expired && !isNaN(parseInt(data.daysLeft)) && parseInt(data.daysLeft) <= 7;

        var accentColor = expired ? '#e8000d' : warn ? '#ff5500' : '#e8000d';
        var badgeText   = expired ? 'MEMBERSHIP EXPIRED' : warn ? 'EXPIRING SOON' : 'ACTIVE';
        var statusColor = expired ? '#e8000d' : warn ? '#ff5500' : '#00c860';

        // Format daysLeft label
        var daysLabel = data.daysLeft;
        if (expired) {
            try {
                var numPart = String(data.daysLeft).replace(/[^0-9\-]/g, '').trim();
                var expDays = Math.abs(parseInt(numPart));
                if (!isNaN(expDays) && expDays > 0) {
                    daysLabel = 'Expired ' + expDays + ' day' + (expDays === 1 ? '' : 's') + ' ago';
                } else {
                    daysLabel = 'Expired';
                }
            } catch (e) { daysLabel = data.daysLeft; }
        } else if (!isNaN(parseInt(data.daysLeft))) {
            var d = parseInt(data.daysLeft);
            daysLabel = d + ' day' + (d === 1 ? '' : 's') + ' left';
        }

        var el = document.createElement('div');
        el.setAttribute('data-fid', data.fid || '');

        el.style.cssText =
            'position:fixed;right:28px;bottom:28px;width:310px;' +
            'background:#0d0d0d;' +
            'border-radius:16px;' +
            'border:1.5px solid ' + accentColor + ';' +
            'box-shadow:0 20px 60px rgba(0,0,0,0.8),0 0 40px rgba(232,0,13,0.3);' +
            'font-family:"Outfit",Arial,sans-serif;' +
            'z-index:2147483647;overflow:hidden;' +
            'cursor:pointer;' +
            'transition:bottom .3s cubic-bezier(.22,.68,0,1.2);' +
            'animation:attIn .45s cubic-bezier(.22,.68,0,1.2);';

        el.innerHTML =

            // TOP GLOW LINE
            '<div style="height:3px;background:linear-gradient(90deg,transparent,' + accentColor + ',transparent);"></div>' +

            // HEADER
            '<div style="' +
            'background:#e8000d;' +
            'padding:13px 16px;' +
            'display:flex;justify-content:space-between;align-items:center;' +
            '">' +
            '<div style="display:flex;align-items:center;gap:8px;">' +
            '<div style="' +
            'width:28px;height:28px;border-radius:50%;' +
            'background:rgba(0,0,0,0.25);' +
            'display:flex;align-items:center;justify-content:center;' +
            'font-size:14px;' +
            '">👆</div>' +
            '<span style="color:#fff;font-weight:700;font-size:13px;letter-spacing:.5px;">NEW ATTENDANCE</span>' +
            '</div>' +
            '<div class="att-close-btn" style="' +
            'width:24px;height:24px;border-radius:6px;' +
            'background:rgba(0,0,0,0.30);' +
            'display:flex;align-items:center;justify-content:center;' +
            'color:#fff;cursor:pointer;font-size:14px;font-weight:bold;' +
            'transition:background .2s;flex-shrink:0;' +
            '" onmouseover="this.style.background=\'rgba(0,0,0,0.55)\'" ' +
            'onmouseout="this.style.background=\'rgba(0,0,0,0.30)\'">&#x2715;</div>' +
            '</div>' +

            // BODY
            '<div style="padding:16px 16px 14px;background:#111;">' +

            // Name row
            '<div style="display:flex;align-items:center;gap:11px;margin-bottom:14px;' +
            'padding-bottom:14px;border-bottom:1px solid rgba(255,255,255,0.07);">' +
            '<div style="' +
            'width:42px;height:42px;border-radius:50%;flex-shrink:0;' +
            'background:#e8000d;' +
            'display:flex;align-items:center;justify-content:center;' +
            'color:#fff;font-size:18px;' +
            'box-shadow:0 4px 14px rgba(232,0,13,0.5);' +
            '">👤</div>' +
            '<div>' +
            '<div style="font-size:15px;font-weight:700;color:#fff;letter-spacing:.3px;">' + esc(data.name) + '</div>' +
            '<div style="font-size:11px;color:#555;margin-top:2px;">City Gym Hambantota — tap to view profile</div>' +
            '</div>' +
            '</div>' +

            // Info grid
            '<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px;">' +

            '<div style="background:#1a1a1a;border:1px solid rgba(255,255,255,0.07);border-radius:10px;padding:10px 12px;">' +
            '<div style="font-size:10px;font-weight:600;color:#555;text-transform:uppercase;letter-spacing:.6px;margin-bottom:5px;">Admission No</div>' +
            '<div style="font-size:14px;font-weight:700;color:#fff;">' + esc(data.admNo) + '</div>' +
            '</div>' +

            '<div style="background:#1a1a1a;border:1px solid rgba(255,255,255,0.07);border-radius:10px;padding:10px 12px;">' +
            '<div style="font-size:10px;font-weight:600;color:#555;text-transform:uppercase;letter-spacing:.6px;margin-bottom:5px;">Scan Time</div>' +
            '<div style="font-size:14px;font-weight:700;color:#fff;">' + esc(data.time) + '</div>' +
            '</div>' +

            '</div>' +

            // Membership remaining
            '<div style="' +
            'background:#1a1a1a;border:1px solid ' + accentColor + '55;' +
            'border-radius:10px;padding:12px 14px;' +
            'display:flex;justify-content:space-between;align-items:center;' +
            '">' +
            '<span style="font-size:12px;color:#888;">Membership Remaining</span>' +
            '<span style="color:' + statusColor + ';font-weight:800;font-size:15px;' +
            'font-family:\'Bebas Neue\',sans-serif;letter-spacing:1px;">' + esc(daysLabel) + '</span>' +
            '</div>' +

            // Badge
            '<div style="margin-top:10px;display:flex;justify-content:flex-end;">' +
            '<span style="' +
            'background:' + accentColor + ';color:#fff;' +
            'font-size:10px;font-weight:800;letter-spacing:1.5px;' +
            'padding:4px 12px;border-radius:20px;' +
            '">' + badgeText + '</span>' +
            '</div>' +

            '</div>' +

            // BOTTOM GLOW LINE (no timer bar — no auto close)
            '<div style="height:3px;background:linear-gradient(90deg,transparent,' + accentColor + ',transparent);opacity:0.4;"></div>';

        document.body.appendChild(el);

        // Push to queue and reposition all
        popupQueue.push(el);
        repositionAll();

        // ── CLOSE BUTTON (stop propagation so it doesn't trigger profile open) ──
        var closeBtn = el.querySelector('.att-close-btn');
        if (closeBtn) {
            closeBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                removePopup(el);
            });
        }

        // ── CLICK POPUP BODY → GO TO MEMBER PROFILE ──
        el.addEventListener('click', function () {
            var fid = el.getAttribute('data-fid');
            if (fid) {
                window.location.href = base() + '/view-member?fid=' + encodeURIComponent(fid);
            }
        });
    }

    function esc(s) {
        return s ? String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;') : '';
    }

    // ── FONTS + KEYFRAMES ────────────────────────────────────────────────────
    var st = document.createElement('style');
    st.textContent =
        '@import url("https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@400;600;700;800&display=swap");' +
        '@keyframes attIn{from{opacity:0;transform:translateX(120%) scale(.92)}to{opacity:1;transform:translateX(0) scale(1)}}';
    document.head.appendChild(st);

    setTimeout(poll, 2000);

})();
