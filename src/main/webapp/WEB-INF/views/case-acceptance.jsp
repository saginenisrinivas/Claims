<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Case Acceptance — ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
</head>
<body>
<div class="app-layout">
  <aside class="sidebar" id="sidebar"></aside>
  <div class="main">
    <header class="top-header">
      <div class="header-left"><h2>Case Acceptance</h2><p>Review and accept or reject submitted cases</p></div>
      <div class="header-right">
        <div class="header-user">
          <svg width="15" height="15" fill="none" stroke="#6b7280" stroke-width="2" viewBox="0 0 24 24">
            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>
          </svg>
          <span id="headerUserName">—</span>
        </div>
        <div id="pendingCount" style="font-size:13px;font-weight:600;color:#0f3460;background:#eef2ff;padding:6px 14px;border-radius:8px;"></div>
      </div>
    </header>
    <main class="page-content">
      <div class="card">
        <div class="filter-bar">
          <input type="text" class="form-control search-box" id="searchInput" placeholder="Search by name, ID or typeâ€¦"/>
          <select class="form-control" id="filterStatus" style="max-width:180px;">
            <option value="">All Statuses</option>
            <option value="SUBMITTED">Submitted</option>
            <option value="ACCEPTED">Accepted</option>
            <option value="REJECTED">Rejected</option>
          </select>
          <select class="form-control" id="filterType" style="max-width:160px;">
            <option value="">All Types</option>
            <option>Medical</option><option>Auto</option><option>Property</option>
            <option>Life</option><option>Travel</option><option>Others</option>
          </select>
          <button class="btn btn-ghost btn-sm" onclick="clearFilters()">Clear</button>
        </div>
        <div class="table-wrapper">
          <table>
            <thead><tr>
              <th>Case ID</th><th>THITO Case Number</th><th>Life Assured</th><th>Type</th>
              <th>Notification Date</th><th>Submitted</th><th>Status</th>
              <th style="text-align:center;">Actions</th>
            </tr></thead>
            <tbody id="tableBody"></tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</div>

<!-- Action Modal -->
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

  (async () => {
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-acceptance');
    await UI.initPage('case-acceptance');
    await UI.loadLookups(['CLAIM_TYPE','CLAIM_NATURE','ID_TYPE','GENDER','RELATION']);
    await loadCases();
  })();

  async function loadCases() {
    allCases = await API.getClaims({ status: '' });
    const stats = await API.getStats();
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-acceptance', stats);
    document.getElementById('pendingCount').textContent = stats.submitted + ' Pending';
    render();
    const openId = new URLSearchParams(window.location.search).get('openCase');
    if (openId && allCases.find(x => x.id === openId)) {
      history.replaceState({}, '', '/case-acceptance');
      openView(openId);
    }
  }

  function render() {
    const search = document.getElementById('searchInput').value.toLowerCase();
    const st     = document.getElementById('filterStatus').value;
    const ty     = document.getElementById('filterType').value;

    let list = allCases.filter(c =>
      ['SUBMITTED','ACCEPTED','REJECTED'].includes(c.status));

    if (search) list = list.filter(c =>
      c.id.toLowerCase().includes(search) ||
      (c.lifeAssuredName||'').toLowerCase().includes(search) ||
      c.claimType.toLowerCase().includes(search));
    if (st) list = list.filter(c => c.status === st);
    if (ty) list = list.filter(c => c.claimType === ty);

    const tbody = document.getElementById('tableBody');
    if (!list.length) {
      tbody.innerHTML = UI.emptyRow(8, 'No cases found', 'No cases match the current filters.');
      return;
    }
    tbody.innerHTML = list.map(c => `
      <tr>
        <td class="td-bold">${c.id}</td>
        <td style="font-weight:600;color:#0f3460;">${c.externalCaseNo||'—'}</td>
        <td><div style="font-weight:500;">${c.lifeAssuredName}</div>
            <div class="td-muted">${c.email}</div></td>
        <td>${UI.label('CLAIM_TYPE', c.claimType)}</td>
        <td class="td-muted">${UI.fmtDate(c.notificationDate)}</td>
        <td class="td-muted">${UI.fmtDate(c.submittedAt)}</td>
        <td>${UI.statusBadge(c.status)}</td>
        <td style="text-align:center;">
          <div class="flex gap-8" style="justify-content:center;">
            <button class="btn btn-outline btn-sm" onclick="openView('${c.id}')">View</button>
            ${c.status === 'SUBMITTED' ? `
              <button class="btn btn-success btn-sm" onclick="openAction('${c.id}','accept')">Accept</button>
              <button class="btn btn-danger btn-sm"  onclick="openAction('${c.id}','reject')">Reject</button>` : ''}
          </div>
        </td>
      </tr>`).join('');
  }

  function openView(id) {
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    currentId = id;
    document.getElementById('modalTitle').textContent = 'Case Details — ' + c.id;
    document.getElementById('modalSubtitle').textContent = UI.label('CLAIM_TYPE', c.claimType) + ' · ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div class="detail-grid">
        <div class="detail-item"><div class="detail-label">Policy Number</div><div class="detail-value">${c.policyNumber||'—'}</div></div>
        <div class="detail-item"><div class="detail-label">ID No.</div><div class="detail-value">${c.idNo||'—'}</div></div>
        <div class="detail-item"><div class="detail-label">Life Assured</div><div class="detail-value">${c.lifeAssuredName}</div></div>
        <div class="detail-item"><div class="detail-label">Reporter Name</div><div class="detail-value">${c.reporterName}</div></div>
        <div class="detail-item"><div class="detail-label">Email</div><div class="detail-value">${c.email}</div></div>
        <div class="detail-item"><div class="detail-label">Phone</div><div class="detail-value">${c.phone}</div></div>
        <div class="detail-item"><div class="detail-label">Claim Type</div><div class="detail-value">${UI.label('CLAIM_TYPE', c.claimType)}</div></div>
        <div class="detail-item"><div class="detail-label">Claim Nature</div><div class="detail-value">${UI.label('CLAIM_NATURE', c.claimNature)||'—'}</div></div>
        ${c.externalCaseNo ? `<div class="detail-item"><div class="detail-label">THITO Case Number</div><div class="detail-value" style="font-weight:600;color:#0f3460;">${c.externalCaseNo}</div></div>` : ''}
        ${c.bcpCaseStatus  ? `<div class="detail-item"><div class="detail-label">THITO Case Status</div><div class="detail-value">${c.bcpCaseStatus}</div></div>` : ''}
        <div class="detail-item"><div class="detail-label">Case Classification</div><div class="detail-value">${c.caseClassification||'—'}</div></div>
        <div class="detail-item"><div class="detail-label">Notification Date</div><div class="detail-value">${UI.fmtDate(c.notificationDate)}</div></div>
        <div class="detail-item"><div class="detail-label">Event Date</div><div class="detail-value">${UI.fmtDate(c.eventDate)}</div></div>
        <div class="detail-item"><div class="detail-label">Submitted</div><div class="detail-value">${UI.fmtDateTime(c.submittedAt)}</div></div>
        <div class="detail-item" style="grid-column:1/-1;"><div class="detail-label">General Comments</div>
          <div style="background:#f9fafb;padding:10px 14px;border-radius:8px;font-size:13px;">${c.generalComments||'—'}</div></div>
      </div>
      ${c.acceptanceNotes||c.rejectionNotes ? `
        <div class="divider"></div>
        <div class="detail-label" style="margin-bottom:5px;">${c.status==='ACCEPTED'?'Acceptance':'Rejection'} Notes</div>
        <div style="background:#f9fafb;padding:10px 14px;border-radius:8px;font-size:13px;">${c.acceptanceNotes||c.rejectionNotes}</div>` : ''}`;

    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Close</button>
      ${c.status === 'SUBMITTED' ? `
        <button class="btn btn-danger"  onclick="openAction('${c.id}','reject')">Reject</button>
        <button class="btn btn-success" onclick="openAction('${c.id}','accept')">Accept</button>` : ''}`;
    UI.openModal('modalOverlay');
  }

  function openAction(id, action) {
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    currentId = id;
    const isAccept = action === 'accept';
    document.getElementById('modalTitle').textContent = isAccept ? 'Accept Case' : 'Reject Case';
    document.getElementById('modalSubtitle').textContent = c.id + ' — ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div style="background:${isAccept?'#f0fdf4':'#fff5f5'};border:1px solid ${isAccept?'#bbf7d0':'#fecaca'};
           border-radius:10px;padding:14px 16px;margin-bottom:20px;font-size:13.5px;
           color:${isAccept?'#166534':'#991b1b'};">
        You are about to <strong>${isAccept?'accept':'reject'}</strong> case <strong>${c.id}</strong>.
      </div>
      <div class="form-group">
        <label class="form-label">${isAccept?'Acceptance':'Rejection'} Notes ${isAccept?'':'<span class="required">*</span>'}</label>
        <textarea class="form-control" id="actionNotes" rows="3"
          placeholder="${isAccept?'Optional notes for the evaluatorâ€¦':'Required: reason for rejectionâ€¦'}"></textarea>
        <div class="form-error" id="notesErr">Rejection reason is required.</div>
      </div>`;
    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Cancel</button>
      <button class="btn ${isAccept?'btn-success':'btn-danger'}" onclick="submitAction('${action}')">
        ${isAccept?'Confirm Acceptance':'Confirm Rejection'}
      </button>`;
    UI.openModal('modalOverlay');
  }

  async function submitAction(action) {
    const notes = document.getElementById('actionNotes').value.trim();
    if (action === 'reject' && !notes) {
      document.getElementById('notesErr').classList.add('show');
      return;
    }
    try {
      if (action === 'accept') {
        await API.acceptClaim(currentId, notes);
        UI.toast('Case accepted successfully.', 'success');
      } else {
        await API.rejectClaim(currentId, notes);
        UI.toast('Case rejected.', 'error');
      }
      UI.closeModal('modalOverlay');
      await loadCases();
    } catch (err) {
      UI.toast(err.message, 'error');
    }
  }

  function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('filterStatus').value = '';
    document.getElementById('filterType').value = '';
    render();
  }

  document.getElementById('searchInput').addEventListener('input', render);
  document.getElementById('filterStatus').addEventListener('change', render);
  document.getElementById('filterType').addEventListener('change', render);
  document.getElementById('modalOverlay').addEventListener('click', e => {
    if (e.target.id === 'modalOverlay') UI.closeModal('modalOverlay');
  });
</script>
</body>
</html>

