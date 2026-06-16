<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Dashboard — ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
</head>
<body>
<div class="app-layout">
  <aside class="sidebar" id="sidebar"></aside>
  <div class="main">
    <header class="top-header">
      <div class="header-left"><h2>Dashboard</h2><p>Overview of all claims activity</p></div>
      <div class="header-right">
        <div class="header-user">
          <svg width="15" height="15" fill="none" stroke="#6b7280" stroke-width="2" viewBox="0 0 24 24">
            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>
          </svg>
          <span id="headerUserName">—</span>
        </div>
        <a href="/case-registration" id="btnNewCase" class="btn btn-primary btn-sm" style="display:none;">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
          New Case
        </a>
      </div>
    </header>
    <main class="page-content">
      <div class="stats-grid" id="statsGrid"></div>
      <div style="display:grid;grid-template-columns:1fr 360px;gap:20px;">
        <div class="card">
          <div class="card-header">
            <div><div class="card-title">Recent Cases</div><div class="card-subtitle">Latest 10 submissions</div></div>
            <a href="/case-acceptance" class="btn btn-outline btn-sm">View All</a>
          </div>
          <div class="card-body-flush table-wrapper">
            <table>
              <thead><tr><th>Case ID</th><th>Life Assured</th><th>Type</th><th>Notification Date</th><th>Status</th></tr></thead>
              <tbody id="recentBody"></tbody>
            </table>
          </div>
        </div>
        <div style="display:flex;flex-direction:column;gap:20px;">
          <div class="card">
            <div class="card-header"><div class="card-title">Pipeline</div></div>
            <div class="card-body" id="pipelineBody"></div>
          </div>
          <div class="card">
            <div class="card-header"><div class="card-title">Quick Actions</div></div>
            <div class="card-body" id="quickActions" style="display:flex;flex-direction:column;gap:10px;"></div>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="/static/js/api.js"></script>
<script src="/static/js/ui.js"></script>
<script>
  (async () => {
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('dashboard');
    const user = await UI.initPage('dashboard');
    const role = user ? user.role : '';

    /* Show New Case button only for Claims Officer */
    if (role === 'Claims Officer') {
      document.getElementById('btnNewCase').style.display = '';
    }

    /* Quick Actions filtered by role */
    const allActions = [
      { href: '/case-registration', label: 'Register New Case',    cls: 'btn-primary',  roles: ['Claims Officer'] },
      { href: '/case-acceptance',   label: 'Review Pending Cases', cls: 'btn-outline',  roles: ['Claims Officer'] },
      { href: '/case-evaluation',   label: 'Cases for Evaluation', cls: 'btn-ghost',    roles: ['Claims Officer'] },
      { href: '/case-approval',     label: 'Cases for Approval',   cls: 'btn-ghost',    roles: ['Case Manager'] }
    ];
    const visibleActions = allActions.filter(a => a.roles.includes(role));
    document.getElementById('quickActions').innerHTML = visibleActions.length
      ? visibleActions.map(a => `<a href="${a.href}" class="btn ${a.cls} w-full">${a.label}</a>`).join('')
      : `<p style="font-size:13px;color:#6b7280;text-align:center;">Dashboard view only</p>`;

    /* Load stats and recent cases from Java API */
    const [stats, claims] = await Promise.all([
        API.getStats(), API.getClaims(), UI.loadLookups(['CLAIM_TYPE'])]);

    /* Sidebar badges */
    document.getElementById('sidebar').innerHTML =
        UI.sidebarHTML('dashboard', stats);

    /* Stats grid */
    const STAT_DEFS = [
      { label:'Total Cases',       val: stats.total,      cls:'primary', icon:`<path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>` },
      { label:'Pending Acceptance',val: stats.submitted,  cls:'yellow',  icon:`<polyline points="22 12 16 12 14 15 10 15 8 12 2 12"/><path d="M5.45 5.11L2 12v6a2 2 0 002 2h16a2 2 0 002-2v-6l-3.45-6.89A2 2 0 0016.76 4H7.24a2 2 0 00-1.79 1.11z"/>` },
      { label:'Under Evaluation',  val: stats.underEval,  cls:'blue',    icon:`<path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/>` },
      { label:'Awaiting Approval', val: stats.evaluated,  cls:'purple',  icon:`<circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/>` },
      { label:'Approved',          val: stats.approved,   cls:'green',   icon:`<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>` },
      { label:'Rejected / Denied', val: stats.rejected,   cls:'red',     icon:`<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>` }
    ];
    document.getElementById('statsGrid').innerHTML = STAT_DEFS.map(s => `
      <div class="stat-card ${s.cls}">
        <div class="stat-icon ${s.cls}">
          <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">${s.icon}</svg>
        </div>
        <div><div class="stat-value">${s.val}</div><div class="stat-label">${s.label}</div></div>
      </div>`).join('');

    /* Recent cases */
    document.getElementById('recentBody').innerHTML = claims.slice(0,10).map(c => `
      <tr>
        <td class="td-bold">${c.id}</td>
        <td>${c.lifeAssuredName}</td>
        <td>${UI.label('CLAIM_TYPE', c.claimType)}</td>
        <td class="td-muted">${UI.fmtDate(c.notificationDate)}</td>
        <td>${UI.statusBadge(c.status)}</td>
      </tr>`).join('') || UI.emptyRow(5, 'No cases yet', 'Register a new case to get started.');

    /* Pipeline bar chart */
    const pipeline = [
      { label:'Submitted',       count: stats.submitted, color:'#6b7280' },
      { label:'Accepted',        count: stats.accepted,  color:'#3b82f6' },
      { label:'Under Evaluation',count: stats.underEval, color:'#f59e0b' },
      { label:'Evaluated',       count: stats.evaluated, color:'#8b5cf6' },
      { label:'Approved',        count: stats.approved,  color:'#10b981' }
    ];
    const pMax = Math.max(...pipeline.map(p => p.count), 1);
    document.getElementById('pipelineBody').innerHTML = pipeline.map(p => `
      <div style="margin-bottom:12px;">
        <div class="flex justify-between" style="margin-bottom:4px;">
          <span style="font-size:12.5px;color:#374151;font-weight:500;">${p.label}</span>
          <span style="font-size:13px;font-weight:700;">${p.count}</span>
        </div>
        <div style="height:6px;background:#f3f4f6;border-radius:4px;">
          <div style="height:100%;width:${(p.count/pMax)*100}%;background:${p.color};border-radius:4px;"></div>
        </div>
      </div>`).join('');
  })();
</script>
</body>
</html>
