<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login — ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg,#1a1a2e,#16213e,#0f3460); min-height:100vh; display:flex; align-items:center; justify-content:center; }
    .page { display:flex; width:100%; max-width:960px; min-height:520px; border-radius:20px; overflow:hidden; box-shadow:0 32px 80px rgba(0,0,0,.5); margin:16px; }
    .left-panel { flex:1; background:linear-gradient(145deg,#0f3460,#16213e); padding:48px 40px; display:flex; flex-direction:column; justify-content:space-between; color:#fff; }
    .brand { display:flex; align-items:center; gap:12px; }
    .brand-icon { width:44px; height:44px; background:rgba(255,255,255,.12); border-radius:12px; display:flex; align-items:center; justify-content:center; }
    .brand-name { font-size:20px; font-weight:700; }
    .hero-title { font-size:30px; font-weight:700; line-height:1.25; margin:48px 0 16px; }
    .hero-title span { color:#e94560; }
    .hero-sub { font-size:14px; color:rgba(255,255,255,.55); line-height:1.7; }
    .features { margin-top:32px; display:flex; flex-direction:column; gap:14px; }
    .feat { display:flex; align-items:center; gap:10px; font-size:13.5px; color:rgba(255,255,255,.7); }
    .feat-dot { width:8px; height:8px; border-radius:50%; background:#e94560; flex-shrink:0; }
    .left-footer { font-size:11.5px; color:rgba(255,255,255,.3); }
    .right-panel { width:440px; background:#fff; padding:48px 44px; display:flex; flex-direction:column; justify-content:center; }
    .form-title { font-size:24px; font-weight:700; color:#111827; margin-bottom:6px; }
    .form-sub   { font-size:13px; color:#6b7280; margin-bottom:32px; }
    .form-group { margin-bottom:18px; }
    label { display:block; font-size:12.5px; font-weight:600; color:#374151; margin-bottom:6px; }
    .input-wrap { position:relative; }
    .input-icon { position:absolute; left:13px; top:50%; transform:translateY(-50%); color:#9ca3af; pointer-events:none; }
    input[type=email], input[type=password] { width:100%; padding:11px 14px 11px 42px; border:1.5px solid #e5e7eb; border-radius:9px; font-size:14px; color:#111; background:#f9fafb; outline:none; transition:all .2s; font-family:inherit; }
    input:focus { border-color:#0f3460; background:#fff; box-shadow:0 0 0 3px rgba(15,52,96,.1); }
    input.error { border-color:#ef4444; }
    .toggle-btn { position:absolute; right:13px; top:50%; transform:translateY(-50%); background:none; border:none; cursor:pointer; color:#9ca3af; padding:2px; }
    .field-error { font-size:11.5px; color:#ef4444; margin-top:4px; display:none; }
    .field-error.show { display:block; }
    .options { display:flex; align-items:center; justify-content:space-between; margin-bottom:22px; }
    .remember { display:flex; align-items:center; gap:7px; font-size:13px; color:#374151; cursor:pointer; }
    .remember input { width:auto; padding:0; accent-color:#0f3460; }
    .forgot { font-size:13px; color:#0f3460; text-decoration:none; font-weight:500; }
    .btn-submit { width:100%; padding:12px; background:linear-gradient(135deg,#0f3460,#16213e); color:#fff; border:none; border-radius:9px; font-size:15px; font-weight:600; cursor:pointer; font-family:inherit; transition:all .2s; }
    .btn-submit:hover { opacity:.9; }
    .btn-submit:disabled { opacity:.6; cursor:not-allowed; }
    .alert { padding:11px 14px; border-radius:8px; font-size:13px; margin-bottom:18px; display:none; }
    .alert-error   { background:#fff5f5; color:#991b1b; border:1px solid #fecaca; }
    .alert-success { background:#f0fdf4; color:#166534; border:1px solid #bbf7d0; }
    .demo-hint { margin-top:16px; padding:10px 14px; background:#f8fafc; border-radius:8px; font-size:12px; color:#6b7280; text-align:center; border:1px dashed #e5e7eb; }
    @media(max-width:700px){ .left-panel{display:none;} .right-panel{width:100%;} }
  </style>
</head>
<body>
<div class="page">
  <div class="left-panel">
    <div>
      <div class="brand">
        <div class="brand-icon">
          <svg width="22" height="22" fill="none" stroke="#fff" stroke-width="2" viewBox="0 0 24 24">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        <div class="brand-name">ClaimsPro</div>
      </div>
      <div class="hero-title">Streamline your<br><span>claims process</span><br>effortlessly.</div>
      <div class="hero-sub">End-to-end platform for managing insurance claims from submission to final approval.</div>
      <div class="features">
        <div class="feat"><div class="feat-dot"></div>Case registration &amp; tracking</div>
        <div class="feat"><div class="feat-dot"></div>Multi-stage acceptance &amp; evaluation</div>
        <div class="feat"><div class="feat-dot"></div>Approval workflow with audit trail</div>
        <div class="feat"><div class="feat-dot"></div>Real-time status dashboards</div>
      </div>
    </div>
    <div class="left-footer">© 2026 ClaimsPro. All rights reserved.</div>
  </div>

  <div class="right-panel">
    <div class="form-title">Welcome back</div>
    <div class="form-sub">Sign in to your ClaimsPro account</div>

    <div id="alert" class="alert"></div>

    <form id="loginForm" novalidate>
      <div class="form-group">
        <label for="email">Email address</label>
        <div class="input-wrap">
          <span class="input-icon">
            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
              <polyline points="22,6 12,13 2,6"/>
            </svg>
          </span>
          <input type="email" id="email" placeholder="you@example.com" autocomplete="email"/>
        </div>
        <div class="field-error" id="emailErr">Enter a valid email address.</div>
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <div class="input-wrap">
          <span class="input-icon">
            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <rect x="3" y="11" width="18" height="11" rx="2"/>
              <path d="M7 11V7a5 5 0 0110 0v4"/>
            </svg>
          </span>
          <input type="password" id="password" placeholder="Enter your password" autocomplete="current-password"/>
          <button type="button" class="toggle-btn" id="togglePwd">
            <svg id="eyeIcon" width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
        <div class="field-error" id="pwdErr">Password must be at least 6 characters.</div>
      </div>

      <div class="options">
        <label class="remember"><input type="checkbox" id="remember"/> Remember me</label>
        <a href="#" class="forgot">Forgot password?</a>
      </div>

      <button type="submit" class="btn-submit" id="submitBtn">Sign In</button>
    </form>
    <div class="demo-hint">Demo: <b>admin@claims.com</b> / <b>admin123</b></div>
  </div>
</div>

<script src="/static/js/api.js"></script>
<script>
  const EYE_OPEN   = `<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>`;
  const EYE_CLOSED = `<path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/>`;

  document.getElementById('togglePwd').addEventListener('click', () => {
    const pw = document.getElementById('password');
    const show = pw.type === 'password';
    pw.type = show ? 'text' : 'password';
    document.getElementById('eyeIcon').innerHTML = show ? EYE_CLOSED : EYE_OPEN;
  });

  function showAlert(type, msg) {
    const el = document.getElementById('alert');
    el.className = 'alert alert-' + type;
    el.style.display = 'block';
    el.textContent = msg;
  }

  document.getElementById('loginForm').addEventListener('submit', async e => {
    e.preventDefault();
    const email = document.getElementById('email').value.trim();
    const pwd   = document.getElementById('password').value;
    let ok = true;

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      document.getElementById('email').classList.add('error');
      document.getElementById('emailErr').classList.add('show');
      ok = false;
    }
    if (pwd.length < 6) {
      document.getElementById('password').classList.add('error');
      document.getElementById('pwdErr').classList.add('show');
      ok = false;
    }
    if (!ok) return;

    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.textContent = 'Signing in…';

    try {
      await API.login(email, pwd);
      showAlert('success', 'Login successful! Redirecting…');
      setTimeout(() => { window.location.href = '/dashboard'; }, 800);
    } catch (err) {
      showAlert('error', err.message || 'Invalid email or password.');
      btn.disabled = false;
      btn.textContent = 'Sign In';
    }
  });
</script>
</body>
</html>
