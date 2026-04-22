<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login – City Gym Hambantota</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

  <style>
    :root {
      --red:        #e8000d;
      --red-dim:    #9a0008;
      --red-glow:   rgba(232, 0, 13, 0.45);
      --red-soft:   rgba(232, 0, 13, 0.12);
      --card-bg:    rgba(8, 4, 4, 0.78);
      --border:     rgba(232, 0, 13, 0.55);
      --input-bg:   rgba(255,255,255,0.04);
      --input-bdr:  rgba(255,255,255,0.10);
      --text:       #f0f0f0;
      --muted:      #888;
    }

    *, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

    body {
      min-height: 100vh;
      background: url('img/Login_image.png') no-repeat center center / cover;
      display: flex;
      align-items: center;
      justify-content: flex-end;
      padding: 24px 48px;
      font-family: 'Outfit', sans-serif;
      color: var(--text);
      overflow: hidden;
      position: relative;
    }

    /* Overlay layers */
    body::before {
      content: '';
      position: absolute; inset: 0;
      background: linear-gradient(
              115deg,
              rgba(0,0,0,0.55) 0%,
              rgba(0,0,0,0.20) 45%,
              rgba(0,0,0,0.72) 100%
      );
    }
    body::after {
      content: '';
      position: absolute; inset: 0;
      background: radial-gradient(ellipse 70% 80% at 75% 50%, rgba(180,0,0,0.08) 0%, transparent 70%);
      pointer-events: none;
    }

    /* Animated background particles */
    .particles {
      position: fixed; inset: 0;
      pointer-events: none;
      overflow: hidden;
      z-index: 0;
    }
    .particle {
      position: absolute;
      width: 2px; height: 2px;
      background: var(--red);
      border-radius: 50%;
      opacity: 0;
      animation: float linear infinite;
    }
    @keyframes float {
      0%   { transform: translateY(110vh) translateX(0);  opacity: 0; }
      10%  { opacity: 0.6; }
      90%  { opacity: 0.3; }
      100% { transform: translateY(-10vh) translateX(40px); opacity: 0; }
    }

    /* ── CARD ── */
    .card {
      max-height: 520px;   /* මෙක adjust කරන්න */
      overflow: hidden;    /* extra part hide වෙනවා */
      position: relative;
      z-index: 10;
      width: 100%;
      max-width: 380px;
      background: var(--card-bg);
      border: 1.5px solid var(--border);
      border-radius: 28px;
      padding: 44px 38px 34px;
      margin-right: 130px;
      backdrop-filter: blur(18px) saturate(140%);
      -webkit-backdrop-filter: blur(18px) saturate(140%);
      box-shadow:
              0 0 0 1px rgba(255,255,255,0.04) inset,
              0 0 60px rgba(0,0,0,0.6),
              0 0 30px var(--red-glow);
      animation: cardIn 0.7s cubic-bezier(0.22,1,0.36,1) both;
    }
    @keyframes cardIn {
      from { opacity: 0; transform: translateY(30px) scale(0.97); }
      to   { opacity: 1; transform: translateY(0)    scale(1); }
    }

    /* Top glow strip */
    .card::before {
      content: '';
      position: absolute;
      top: 0; left: 10%; right: 10%;
      height: 2px;
      background: linear-gradient(90deg, transparent, var(--red), transparent);
      border-radius: 50%;
      filter: blur(1px);
    }

    /* ── HEADER ── */
    .header { text-align: center; margin-bottom: 28px; }

    .header h1 {
      font-family: 'Bebas Neue', sans-serif;
      font-size: 42px;
      letter-spacing: 2px;
      line-height: 1;
      margin-bottom: 6px;
    }
    .header h1 span { color: var(--red); }

    .header p {
      color: var(--muted);
      font-size: 14px;
      font-weight: 400;
      letter-spacing: 0.5px;
    }

    /* ── LOCK ICON ── */
    .lock-wrap {
      width: 70px; height: 70px;
      margin: 0 auto 26px;
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      background: radial-gradient(circle, rgba(180,0,0,0.25) 0%, rgba(0,0,0,0.5) 100%);
      border: 1.5px solid var(--border);
      box-shadow: 0 0 24px var(--red-glow), 0 0 8px var(--red-glow) inset;
      position: relative;
      animation: pulse 2.8s ease-in-out infinite;
    }
    @keyframes pulse {
      0%,100% { box-shadow: 0 0 18px var(--red-glow), 0 0 8px var(--red-glow) inset; }
      50%      { box-shadow: 0 0 36px var(--red-glow), 0 0 14px var(--red-glow) inset; }
    }
    .lock-wrap i { color: var(--red); font-size: 30px; }

    /* ── SECTION TITLE ── */
    .section-title {
      text-align: center;
      font-family: 'Bebas Neue', sans-serif;
      font-size: 28px;
      letter-spacing: 4px;
      margin-bottom: 30px;
      position: relative;
    }
    .section-title::before,
    .section-title::after {
      content: '';
      position: absolute;
      top: 50%; width: 60px; height: 1.5px;
      background: linear-gradient(90deg, transparent, var(--red));
      transform: translateY(-50%);
    }
    .section-title::before { left: 0; background: linear-gradient(90deg, transparent, var(--red)); }
    .section-title::after  { right: 0; background: linear-gradient(270deg, transparent, var(--red)); }

    /* ── INPUTS ── */
    .form-group { margin-bottom: 18px; }

    .input-wrap {
      display: flex;
      align-items: center;
      height: 40px;
      background: var(--input-bg);
      border: 1.5px solid var(--input-bdr);
      border-radius: 14px;
      overflow: hidden;
      transition: border-color 0.3s, box-shadow 0.3s;

    }
    .input-wrap:focus-within {
      border-color: var(--red);
      box-shadow: 0 0 0 3px rgba(232,0,13,0.12);
    }

    .input-icon {
      width: 50px; min-width: 56px;
      display: flex; align-items: center; justify-content: center;
      color: var(--red);
      font-size: 17px;
      opacity: 0.85;
    }

    .input-wrap input {
      flex: 1;
      height: 100%;
      border: none; outline: none;
      background: transparent;
      color: var(--text);
      font-family: 'Outfit', sans-serif;
      font-size: 15px;
      font-weight: 500;
      padding-left: 15px;
    }
    .input-wrap input::placeholder { color: #555; }

    .toggle-btn {
      width: 52px;
      display: flex; align-items: center; justify-content: center;
      color: var(--muted);
      cursor: pointer;
      font-size: 16px;
      transition: color 0.25s;
    }
    .toggle-btn:hover { color: var(--red); }

    /* ── OPTIONS ROW ── */
    .options {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin: 8px 0 26px;
    }

    .remember input[type="checkbox"] {
      appearance: none;
      width: 16px; height: 16px;
      border: 1.5px solid rgba(255,255,255,0.20);
      border-radius: 5px;
      background: var(--input-bg);
      cursor: pointer;
      display: grid; place-items: center;
      transition: 0.25s;
    }
    .remember input[type="checkbox"]:checked {
      background: var(--red);
      border-color: var(--red);
    }
    .remember input[type="checkbox"]:checked::before {
      content: '';
      width: 8px; height: 5px;
      border-left: 2px solid #fff;
      border-bottom: 2px solid #fff;
      transform: rotate(-45deg) translateY(-1px);
    }



    /* ── LOGIN BUTTON ── */
    .login-btn {
      width: 100%;
      height: 35px;
      border: none;
      border-radius: 14px;
      background: linear-gradient(135deg, #ff1a1a 0%, #9a0008 100%);
      color: #fff;
      font-family: 'Bebas Neue', sans-serif;
      font-size: 19px;
      letter-spacing: 3px;
      cursor: pointer;
      position: relative;
      overflow: hidden;
      transition: transform 0.2s, box-shadow 0.3s;
      box-shadow: 0 6px 24px rgba(200,0,0,0.35);
    }
    .login-btn::before {
      content: '';
      position: absolute; inset: 0;
      background: linear-gradient(135deg, rgba(255,255,255,0.15) 0%, transparent 60%);
      opacity: 0;
      transition: opacity 0.3s;
    }
    .login-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 32px rgba(200,0,0,0.50);
    }
    .login-btn:hover::before { opacity: 1; }
    .login-btn:active { transform: translateY(0); }

    /* Shine sweep on hover */
    .login-btn::after {
      content: '';
      position: absolute;
      top: 0; left: -75%;
      width: 50%; height: 100%;
      background: linear-gradient(120deg, transparent, rgba(255,255,255,0.18), transparent);
      transform: skewX(-20deg);
      transition: left 0.5s ease;
    }
    .login-btn:hover::after { left: 150%; }

    /* ── ERROR ── */
    .error {
      text-align: center;
      color: #ff4d4d;
      font-size: 13px;
      font-weight: 500;
      margin-top: 14px;
      min-height: 18px;
    }

    /* ── FOOTER ── */
    .footer {
      text-align: center;
      margin-top: 28px;
      color: #ffffff;
      font-size: 12px;
      letter-spacing: 0.3px;
    }
    .footer span { color: var(--red); font-weight: 600; }

    /* Divider line above footer */
    .divider {
      height: 1px;
      background: linear-gradient(90deg, transparent, rgba(255,255,255,0.07), transparent);
      margin: 24px 0 20px;
    }

    /* ── RESPONSIVE ── */
    @media (max-width: 900px) {
      body { justify-content: center; padding: 20px; }
    }
    @media (max-width: 500px) {
      .card { padding: 32px 22px 24px; border-radius: 22px; }
      .header h1 { font-size: 34px; }
      .section-title { font-size: 24px; }
    }
  </style>
</head>
<body>

<!-- Floating particles -->
<div class="particles" id="particles"></div>

<div class="card">

  <div class="header">
    <h1>Welcome <span>Back!</span></h1>
    <p>Sign in to your account to continue</p>
  </div>

  <div class="lock-wrap">
    <i class="fa-solid fa-lock"></i>
  </div>

  <div class="section-title">LOGIN</div>

  <form action="login" method="post" autocomplete="off">

    <div class="form-group">
      <div class="input-wrap">
        <div class="input-icon"><i class="fa-regular fa-user"></i></div>
        <input type="text" name="username" placeholder="Username" autocomplete="off" required>
      </div>
    </div>

    <div class="form-group">
      <div class="input-wrap">
        <div class="input-icon"><i class="fa-solid fa-lock"></i></div>
        <input type="password" name="password" id="password" placeholder="Password" autocomplete="new-password" required>
        <div class="toggle-btn" onclick="togglePassword()" title="Show/Hide password">
          <i class="fa-regular fa-eye" id="eyeIcon"></i>
        </div>
      </div>
    </div>

    <button type="submit" class="login-btn">Login</button>

  </form>

  <p class="error">${error}</p>

  <div class="divider"></div>

  <div class="footer">
    &copy; 2024 <span>AGNOX</span>. All rights reserved.
  </div>

</div>

<script>
  /* Password toggle */
  function togglePassword() {
    const pw = document.getElementById('password');
    const ic = document.getElementById('eyeIcon');
    const show = pw.type === 'password';
    pw.type = show ? 'text' : 'password';
    ic.classList.toggle('fa-eye',      !show);
    ic.classList.toggle('fa-eye-slash', show);
  }

  /* Floating particles */
  (function () {
    const container = document.getElementById('particles');
    const count = 28;
    for (let i = 0; i < count; i++) {
      const p = document.createElement('div');
      p.className = 'particle';
      const size = Math.random() * 3 + 1;
      p.style.cssText = `
        width:${size}px; height:${size}px;
        left:${Math.random() * 100}%;
        animation-duration:${6 + Math.random() * 10}s;
        animation-delay:${Math.random() * 8}s;
        opacity:0;
      `;
      container.appendChild(p);
    }
  })();
</script>

</body>
</html>