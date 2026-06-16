<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Case Evaluation â€” ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
</head>
<body>
<div class="app-layout">
  <aside class="sidebar" id="sidebar"></aside>
  <div class="main">
    <header class="top-header">
      <div class="header-left"><h2>Case Evaluation</h2><p>Evaluate accepted cases and assess claim amounts</p></div>
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
      <div class="card">
        <div class="filter-bar">
          <input type="text" class="form-control search-box" id="searchInput" placeholder="Search by name, ID or typeâ€¦"/>
          <select class="form-control" id="filterStatus" style="max-width:210px;">
            <option value="">All Statuses</option>
            <option value="ACCEPTED">Accepted</option>
            <option value="UNDER_EVALUATION">Under Evaluation</option>
            <option value="EVALUATED">Evaluated</option>
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
              <th>Evaluated Amount</th><th>Risk</th><th>Accepted On</th>
              <th>Status</th><th style="text-align:center;">Actions</th>
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

  (async () => {
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-evaluation');
    await UI.initPage('case-evaluation');
    await UI.loadLookups(['CLAIM_TYPE']);
    await loadCases();
  })();

  async function loadCases() {
    allCases = await API.getClaims();
    const stats = await API.getStats();
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-evaluation', stats);
    document.getElementById('pendingCount').textContent =
        (stats.accepted + stats.underEval) + ' In Progress';
    render();
  }

  function render() {
    const search = document.getElementById('searchInput').value.toLowerCase();
    const st     = document.getElementById('filterStatus').value;
    const rk     = document.getElementById('filterRisk').value;

    let list = allCases.filter(c =>
      ['ACCEPTED','UNDER_EVALUATION','EVALUATED'].includes(c.status));

    if (search) list = list.filter(c =>
      c.id.toLowerCase().includes(search) ||
      (c.lifeAssuredName||'').toLowerCase().includes(search) ||
      c.claimType.toLowerCase().includes(search));
    if (st) list = list.filter(c => c.status === st);
    if (rk) list = list.filter(c => c.riskLevel === rk);

    const tbody = document.getElementById('tableBody');
    if (!list.length) {
      tbody.innerHTML = UI.emptyRow(8, 'No cases to evaluate', 'Cases appear here after acceptance.');
      return;
    }
    tbody.innerHTML = list.map(c => `
      <tr>
        <td class="td-bold">${c.id}</td>
        <td><div style="font-weight:500;">${c.lifeAssuredName}</div>
            <div class="td-muted">${c.email}</div></td>
        <td>${UI.label('CLAIM_TYPE', c.claimType)}</td>
        <td>${c.evaluatedAmount != null
              ? `<span style="font-weight:600;color:#0f3460;">${UI.fmtCurrency(c.evaluatedAmount)}</span>`
              : '<span class="td-muted">â€”</span>'}</td>
        <td>${UI.riskBadge(c.riskLevel)}</td>
        <td class="td-muted">${UI.fmtDate(c.acceptedAt)}</td>
        <td>${UI.statusBadge(c.status)}</td>
        <td style="text-align:center;">
          <div class="flex gap-8" style="justify-content:center;">
            <button class="btn btn-outline btn-sm" onclick="openView('${c.id}')">View</button>
            ${c.status === 'ACCEPTED'         ? `<button class="btn btn-warning btn-sm" onclick="doStartEval('${c.id}')">Start Eval</button>` : ''}
            ${c.status === 'UNDER_EVALUATION' ? `<button class="btn btn-purple  btn-sm" onclick="openEvaluate('${c.id}')">Evaluate</button>`   : ''}
          </div>
        </td>
      </tr>`).join('');
  }

  function openView(id) {
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    document.getElementById('modalTitle').textContent = 'Case Details â€” ' + c.id;
    document.getElementById('modalSubtitle').textContent = c.claimType + ' Â· ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div class="detail-grid" style="margin-bottom:14px;">
        <div class="detail-item"><div class="detail-label">Life Assured</div><div class="detail-value">${c.lifeAssuredName}</div></div>
        <div class="detail-item"><div class="detail-label">Claim Type</div><div class="detail-value">${UI.label('CLAIM_TYPE', c.claimType)}</div></div>
        <div class="detail-item"><div class="detail-label">Notification Date</div><div class="detail-value">${UI.fmtDate(c.notificationDate)}</div></div>
        <div class="detail-item"><div class="detail-label">Status</div><div class="detail-value">${UI.statusBadge(c.status)}</div></div>
      </div>
      ${c.evaluationNotes ? `
        <div class="divider"></div>
        <div class="detail-grid">
          <div class="detail-item"><div class="detail-label">Evaluated Amount</div>
            <div class="detail-value" style="font-weight:700;color:#0f3460;">${UI.fmtCurrency(c.evaluatedAmount)}</div></div>
          <div class="detail-item"><div class="detail-label">Risk Level</div><div class="detail-value">${UI.riskBadge(c.riskLevel)}</div></div>
          <div class="detail-item" style="grid-column:1/-1;">
            <div class="detail-label">Evaluation Notes</div>
            <div style="background:#faf5ff;padding:10px 14px;border-radius:8px;font-size:13px;margin-top:4px;">${c.evaluationNotes}</div>
          </div>
        </div>` : ''}`;
    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Close</button>
      ${c.status === 'ACCEPTED'         ? `<button class="btn btn-warning" onclick="doStartEval('${c.id}')">Start Evaluation</button>` : ''}
      ${c.status === 'UNDER_EVALUATION' ? `<button class="btn btn-purple"  onclick="openEvaluate('${c.id}')">Submit Evaluation</button>` : ''}`;
    UI.openModal('modalOverlay');
  }

  async function doStartEval(id) {
    try {
      await API.startEvaluation(id);
      UI.toast('Evaluation started.', 'info');
      UI.closeModal('modalOverlay');
      await loadCases();
    } catch (err) { UI.toast(err.message, 'error'); }
  }

  function openEvaluate(id) {
    currentId = id;
    const c = allCases.find(x => x.id === id);
    if (!c) return;
    document.getElementById('modalTitle').textContent = 'Submit Evaluation';
    document.getElementById('modalSubtitle').textContent = c.id + ' â€” ' + c.lifeAssuredName;
    document.getElementById('modalBody').innerHTML = `
      <div style="background:#f9fafb;border-radius:10px;padding:14px 16px;margin-bottom:20px;">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
          <div><div class="detail-label">Life Assured</div><div class="detail-value">${c.lifeAssuredName}</div></div>
          <div><div class="detail-label">Claim Type</div><div class="detail-value">${UI.label('CLAIM_TYPE', c.claimType)}</div></div>
        </div>
      </div>
      <div class="form-grid" style="margin-bottom:14px;">
        <div class="form-group">
          <label class="form-label">Evaluated Amount (BWP) <span class="required">*</span></label>
          <input type="number" class="form-control" id="evalAmount" min="0" step="0.01" placeholder="0.00"/>
          <div class="form-error" id="errAmt">Enter a valid amount.</div>
        </div>
        <div class="form-group">
          <label class="form-label">Risk Level <span class="required">*</span></label>
          <select class="form-control" id="riskLevel">
            <option value="">â€” Select â€”</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </select>
          <div class="form-error" id="errRisk">Required.</div>
        </div>
        <div class="form-group col-full">
          <label class="form-label">Evaluation Notes <span class="required">*</span></label>
          <textarea class="form-control" id="evalNotes" rows="4"
            placeholder="Summarise findings, document verification, deductionsâ€¦"></textarea>
          <div class="form-error" id="errNotes">Min 20 characters required.</div>
        </div>
        <div class="form-group col-full">
          <label class="form-label">Recommendation</label>
          <select class="form-control" id="recommendation">
            <option value="approve">Recommend Approval</option>
            <option value="review">Recommend Additional Review</option>
            <option value="deny">Recommend Denial</option>
          </select>
        </div>
      </div>`;
    document.getElementById('modalFooter').innerHTML = `
      <button class="btn btn-ghost" onclick="UI.closeModal('modalOverlay')">Cancel</button>
      <button class="btn btn-purple" onclick="submitEvaluation()">Submit Evaluation</button>`;
    UI.openModal('modalOverlay');
  }

  async function submitEvaluation() {
    const amount = parseFloat(document.getElementById('evalAmount').value);
    const risk   = document.getElementById('riskLevel').value;
    const notes  = document.getElementById('evalNotes').value.trim();
    let ok = true;
    if (!amount || amount <= 0) { document.getElementById('errAmt').classList.add('show');   ok = false; }
    if (!risk)                  { document.getElementById('errRisk').classList.add('show');  ok = false; }
    if (notes.length < 20)      { document.getElementById('errNotes').classList.add('show'); ok = false; }
    if (!ok) return;

    try {
      await API.evaluateClaim(currentId, amount, risk, notes,
          document.getElementById('recommendation').value);
      UI.toast('Evaluation submitted. Case ready for approval.', 'success');
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

