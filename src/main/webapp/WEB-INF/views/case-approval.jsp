<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Case Approval â€” ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
</head>
<body>
<div class="app-layout">
  <aside class="sidebar" id="sidebar"></aside>
  <div class="main">
    <header class="top-header">
      <div class="header-left"><h2>Case Approval</h2><p>Final approval or denial of evaluated cases</p></div>
      <div class="header-right">
        <div class="header-user">
          <svg width="15" height="15" fill="none" stroke="#6b7280" stroke-width="2" viewBox="0 0 24 24">
            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>
          </svg>
          <span id="headerUserName">â€”</span>
        </div>
        <div id="pendingCount" style="font-size:13px;font-weight:600;color:#0f3460;background:#eef2ff;padding:6px 14px;border-radius:8px;"></div>
      </div>
    </header>
    <main class="page-content">
      <div class="stats-grid" id="summaryCards" style="grid-template-columns:repeat(4,1fr);margin-bottom:20px;"></div>
      <div class="card">
        <div class="filter-bar">
          <input type="text" class="form-control search-box" id="searchInput" placeholder="Search by name, ID or typeâ€¦"/>
          <select class="form-control" id="filterStatus" style="max-width:180px;">
            <option value="">All Statuses</option>
            <option value="EVALUATED">Evaluated</option>
            <option value="APPROVED">Approved</option>
            <option value="DENIED">Denied</option>
          </select>
          <select class="form-control" id="filterRisk" style="max-width:160px;">
            <option value="">All Risk Levels</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </select>
          <button class="btn btn-ghost btn-sm" onclick="clearFilters()">Clear</button>
        </div>
        <div class="table-wrapper">
          <table>
            <thead><tr>
              <th>Case ID</th><th>Life Assured</th><th>Type</th>
              <th>Evaluated Amt</th><th>Approved Amt</th>
              <th>Risk</th><th>Recommendation</th><th>Status</th>
              <th style="text-align:center;">Actions</th>
            </tr></thead>
            <tbody id="tableBody"></tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<div class="modal-overlay" id="modalOverlay">
  <div class="modal modal-lg">
    <div class="modal-header">
      <div>
        <div class="modal-title" id="modalTitle"></div>
        <div style="font-size:12px;color:#6b7280;margin-top:2px;" id="modalSubtitle"></div>
      </div>
      <button class="modal-close" onclick="UI.closeModal('modalOverlay')">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    </div>
    <div class="modal-body" id="modalBody"></div>
    <div class="modal-footer" id="modalFooter"></div>
  </div>
</div>

<script src="/static/js/api.js"></script>
<script src="/static/js/ui.js"></script>
<script>
  let allCases = [];
  let currentId = null;

  const REC_LABEL = { approve:'Recommend Approval', review:'Additional Review', deny:'Recommend Denial' };
  const REC_COLOR = { approve:'#10b981', review:'#f59e0b', deny:'#ef4444' };

  (async () => {
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-approval');
    await UI.initPage('case-approval');
    await UI.loadLookups(['CLAIM_TYPE']);
    await loadCases();
  })();

  async function loadCases() {
    allCases = await API.getClaims();
    const stats = await API.getStats();
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-approval', stats);
    document.getElementById('pendingCount').textContent = stats.evaluated + ' Awaiting Approval';
    renderSummary(stats);
    render();
  }

  function renderSummary(stats) {
    const cards = [
      { label:'Awaiting Approval', val: stats.evaluated,  cls:'purple',
        icon:`<circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/>` },
      { label:'Approved Cases',    val: stats.approved,   cls:'green',
        icon:`<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>` },
      { label:'Denied Cases',      val: stats.rejected,   cls:'red',
        icon:`<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>` },
      { label:'Total Approved Amt',val: UI.fmtCurrency(stats.totalApproved), cls:'blue',
        icon:`<line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/>` }
    ];
    document.getElementById('summaryCards').innerHTML = cards.map(s => `
      <div class="stat-card ${s.cls}">
        <div class="stat-icon ${s.cls}">
          <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">${s.icon}</svg>
        </div>
        <div><div class="stat-value">${s.val}</div><div class="stat-label">${s.label}</div></div>
      </div>`).join('');
  }

  function render() {
    const search = document.getElementById('searchInput').value.toLowerCase();
    const st     = document.getElementById('filterStatus').value;
    const rk     = document.getElementById('filterRisk').value;

    let list = allCases.filter(c =>
      ['EVALUATED','APPROVED','DENIED'].includes(c.status));

    if (search) list = list.filter(c =>
      c.id.toLowerCase().includes(search) ||
      (c.lifeAssuredName||'').toLowerCase().includes(search) ||
      c.claimType.toLowerCase().includes(search));
    if (st) list = list.filter(c => c.status === st);
    if (rk) list = list.filter(c => c.riskLevel === rk);

    const tbody = document.getElementById('tableBody');
    if (!list.length) {
      tbody.innerHTML = UI.emptyRow(9, 'No cases ready for approval',
          'Cases appear here after evaluation is completed.');
      return;
    }
    tbody.innerHTML = list.map(c => `
      <tr>
        <td class="td-bold">${c.id}</td>
        <td><div style="font-weight:500;">${c.lifeAssuredName}</div>
            <div class="td-muted">${UI.label('CLAIM_TYPE', c.claimType)}</div></td>
        <td>${UI.label('CLAIM_TYPE', c.claimType)}</td>
        <td class="td-bold">${UI.fmtCurrency(c.evaluatedAmount)}</td>
        <td>${c.approvedAmount != null
              ? `<span style="font-weight:700;color:#10b981;">${UI.fmtCurrency(c.approvedAmount)}</span>`
              : '<span class="td-muted">â€”</span>'}</td>
        <td>${UI.riskBadge(c.riskLevel)}</td>
        <td>${c.recommendation
              ? `<span style="font-size:12px;font-weight:600;color:${REC_COLOR[c.recommendation]||'#6b7280'};">
                   ${REC_LABEL[c.recommendation]||c.recommendation}</span>`
              : '<span class="td-muted">â€”</span>'}</td>
        <td>${UI.statusBadge(c.status)}</td>
        <td style="text-align:center;">
          <div class="flex gap-8" style="justify-content:center;">
            <button class="btn btn-outline btn-sm" onclick="openView('${c.id}')">View</button>
            ${c.status === 'EVALUATED' ? `
              <button class="btn btn-success btn-sm" onclick="openDecision('${c.id}','approve')">Approve</button>
              <button class="btn btn-danger  btn-sm" onclick="openDecision('${c.id}','deny')">Deny</button>` : ''}
          </div>
        </td>
      </tr>`).join('');
  }

  function openView(id) {
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    document.getElementById('modalTitle').textContent = 'Full Case Summary â€” ' + c.id;
    document.getElementById('modalSubtitle').textContent = c.claimType + ' Â· ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div class="form-section-title" style="margin-bottom:10px;">Financial Summary</div>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:16px;">
        <div style="background:#f9fafb;border-radius:8px;padding:12px;text-align:center;">
          <div style="font-size:11px;color:#6b7280;font-weight:600;text-transform:uppercase;margin-bottom:4px;">Evaluated</div>
          <div style="font-size:18px;font-weight:700;color:#0f3460;">${UI.fmtCurrency(c.evaluatedAmount)}</div>
        </div>
        <div style="background:#f0fdf4;border-radius:8px;padding:12px;text-align:center;">
          <div style="font-size:11px;color:#6b7280;font-weight:600;text-transform:uppercase;margin-bottom:4px;">Approved</div>
          <div style="font-size:18px;font-weight:700;color:${c.approvedAmount!=null?'#10b981':'#9ca3af'};">
            ${c.approvedAmount!=null?UI.fmtCurrency(c.approvedAmount):'Pending'}</div>
        </div>
        <div style="background:#faf5ff;border-radius:8px;padding:12px;text-align:center;">
          <div style="font-size:11px;color:#6b7280;font-weight:600;text-transform:uppercase;margin-bottom:4px;">Risk</div>
          <div style="font-size:16px;font-weight:700;">${UI.riskBadge(c.riskLevel)}</div>
        </div>
      </div>
      <div class="form-section-title" style="margin-bottom:10px;">Evaluation Notes</div>
      <div style="background:#faf5ff;border-radius:8px;padding:12px 14px;font-size:13px;color:#374151;
           line-height:1.65;margin-bottom:14px;">${c.evaluationNotes||'â€”'}</div>
      ${c.approvalNotes ? `
        <div class="form-section-title" style="margin-bottom:10px;">${c.status==='APPROVED'?'Approval':'Denial'} Decision</div>
        <div style="background:${c.status==='APPROVED'?'#f0fdf4':'#fff5f5'};border-radius:8px;padding:12px 14px;
             font-size:13px;color:${c.status==='APPROVED'?'#166534':'#991b1b'};line-height:1.65;">
          ${c.approvalNotes}</div>` : ''}`;
    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Close</button>
      ${c.status === 'EVALUATED' ? `
        <button class="btn btn-danger"  onclick="openDecision('${c.id}','deny')">Deny Case</button>
        <button class="btn btn-success" onclick="openDecision('${c.id}','approve')">Approve Case</button>` : ''}`;
    UI.openModal('modalOverlay');
  }

  function openDecision(id, decision) {
    currentId = id;
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    const isApprove = decision === 'approve';
    document.getElementById('modalTitle').textContent = isApprove ? 'Approve Case' : 'Deny Case';
    document.getElementById('modalSubtitle').textContent = c.id + ' â€” ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div style="background:${isApprove?'#f0fdf4':'#fff5f5'};border:1px solid ${isApprove?'#bbf7d0':'#fecaca'};
           border-radius:10px;padding:14px;margin-bottom:20px;font-size:13.5px;color:${isApprove?'#166534':'#991b1b'};">
        You are about to <strong>${isApprove?'approve':'deny'}</strong> case <strong>${c.id}</strong>.
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:12px;background:#f9fafb;
           border-radius:8px;margin-bottom:20px;">
        <div><div class="detail-label">Evaluated Amount</div>
             <div class="detail-value" style="font-weight:700;color:#0f3460;font-size:15px;">${UI.fmtCurrency(c.evaluatedAmount)}</div></div>
        <div><div class="detail-label">Risk Level</div><div class="detail-value">${UI.riskBadge(c.riskLevel)}</div></div>
        <div><div class="detail-label">Recommendation</div>
             <div class="detail-value" style="font-weight:600;color:${REC_COLOR[c.recommendation]||'#6b7280'};">
               ${REC_LABEL[c.recommendation]||'â€”'}</div></div>
      </div>
      ${isApprove ? `
        <div class="form-group" style="margin-bottom:14px;">
          <label class="form-label">Approved Amount (BWP) <span class="required">*</span></label>
          <input type="number" class="form-control" id="approvedAmt" value="${c.evaluatedAmount||0}" min="0" step="0.01"/>
          <div class="form-error" id="errAmt">Required.</div>
        </div>` : ''}
      <div class="form-group">
        <label class="form-label">${isApprove?'Approval':'Denial'} Notes <span class="required">*</span></label>
        <textarea class="form-control" id="decisionNotes" rows="3"
          placeholder="${isApprove?'Authorization notesâ€¦':'Reason for denialâ€¦'}"></textarea>
        <div class="form-error" id="errNotes">Required.</div>
      </div>`;
    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Cancel</button>
      <button class="btn ${isApprove?'btn-success':'btn-danger'}" onclick="submitDecision('${decision}')">
        ${isApprove?'Confirm Approval':'Confirm Denial'}
      </button>`;
    UI.openModal('modalOverlay');
  }

  async function submitDecision(decision) {
    const isApprove = decision === 'approve';
    const notes = document.getElementById('decisionNotes').value.trim();
    let ok = true;
    if (!notes) { document.getElementById('errNotes').classList.add('show'); ok = false; }
    let amt = null;
    if (isApprove) {
      amt = parseFloat(document.getElementById('approvedAmt').value);
      if (!amt || amt <= 0) { document.getElementById('errAmt').classList.add('show'); ok = false; }
    }
    if (!ok) return;

    try {
      if (isApprove) {
        await API.approveClaim(currentId, amt, notes);
        UI.toast('Case approved. Payment authorised.', 'success');
      } else {
        await API.denyClaim(currentId, notes);
        UI.toast('Case denied.', 'error');
      }
      UI.closeModal('modalOverlay');
      await loadCases();
    } catch (err) { UI.toast(err.message, 'error'); }
  }

  function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('filterStatus').value = '';
    document.getElementById('filterRisk').value = '';
    render();
  }

  document.getElementById('searchInput').addEventListener('input', render);
  document.getElementById('filterStatus').addEventListener('change', render);
  document.getElementById('filterRisk').addEventListener('change', render);
  document.getElementById('modalOverlay').addEventListener('click', e => {
    if (e.target.id === 'modalOverlay') UI.closeModal('modalOverlay');
  });
</script>
</body>
</html>

