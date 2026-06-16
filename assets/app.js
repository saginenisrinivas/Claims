const App = {

  /* ── Auth ──────────────────────────────── */
  getUser()       { return JSON.parse(localStorage.getItem('claimsUser') || 'null'); },
  setUser(u)      { localStorage.setItem('claimsUser', JSON.stringify(u)); },
  logout()        { localStorage.removeItem('claimsUser'); window.location.href = 'login.html'; },
  requireAuth()   { if (!this.getUser()) { window.location.href = 'login.html'; } },

  /* ── Cases CRUD ────────────────────────── */
  getCases()      { return JSON.parse(localStorage.getItem('claimsCases') || '[]'); },
  saveCases(list) { localStorage.setItem('claimsCases', JSON.stringify(list)); },

  getCaseById(id) {
    return this.getCases().find(c => c.id === id) || null;
  },

  addCase(data) {
    const list = this.getCases();
    list.unshift(data);
    this.saveCases(list);
  },

  updateCase(id, patch) {
    const list = this.getCases();
    const i = list.findIndex(c => c.id === id);
    if (i !== -1) {
      list[i] = Object.assign({}, list[i], patch);
      this.saveCases(list);
      return list[i];
    }
    return null;
  },

  getCasesByStatus(...statuses) {
    return this.getCases().filter(c => statuses.includes(c.status));
  },

  /* ── ID Generator ──────────────────────── */
  generateId() {
    const year = new Date().getFullYear();
    const list = this.getCases();
    const num  = String(list.length + 1).padStart(4, '0');
    return `CLM-${year}-${num}`;
  },

  /* ── Formatters ────────────────────────── */
  fmtDate(d) {
    if (!d) return '—';
    return new Date(d).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  },

  fmtDateTime(d) {
    if (!d) return '—';
    return new Date(d).toLocaleString('en-US', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
  },

  fmtCurrency(n) {
    if (n === undefined || n === null || n === '') return '—';
    return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n);
  },

  /* ── Status helpers ────────────────────── */
  statusLabel(s) {
    return { submitted: 'Submitted', accepted: 'Accepted', rejected: 'Rejected',
             under_evaluation: 'Under Evaluation', evaluated: 'Evaluated',
             approved: 'Approved', denied: 'Denied' }[s] || s;
  },

  statusBadge(s) {
    const cls = { submitted: 'badge-gray', accepted: 'badge-blue', rejected: 'badge-red',
                  under_evaluation: 'badge-yellow', evaluated: 'badge-purple',
                  approved: 'badge-green', denied: 'badge-red' }[s] || 'badge-gray';
    return `<span class="badge ${cls}">${this.statusLabel(s)}</span>`;
  },

  riskBadge(r) {
    if (!r) return '—';
    const cls = { low: 'badge-green', medium: 'badge-yellow', high: 'badge-red' }[r] || 'badge-gray';
    return `<span class="badge ${cls}">${r.charAt(0).toUpperCase() + r.slice(1)}</span>`;
  },

  /* ── Seed data ─────────────────────────── */
  seedData() {
    if (this.getCases().length > 0) return;
    const now = new Date();
    const daysAgo = n => new Date(now - n * 86400000).toISOString();

    const samples = [
      {
        id: 'CLM-2026-0001',
        claimantName: 'Alice Johnson', email: 'alice@example.com', phone: '555-0101',
        claimType: 'Medical', incidentDate: '2026-04-10',
        description: 'Emergency surgery and post-operative hospital bills for appendectomy.',
        amount: 12500, status: 'submitted', submittedAt: daysAgo(18)
      },
      {
        id: 'CLM-2026-0002',
        claimantName: 'Bob Williams', email: 'bob@example.com', phone: '555-0102',
        claimType: 'Auto', incidentDate: '2026-04-12',
        description: 'Vehicle damage from rear-end collision on Highway 45.',
        amount: 8700, status: 'submitted', submittedAt: daysAgo(16)
      },
      {
        id: 'CLM-2026-0003',
        claimantName: 'Carol Martinez', email: 'carol@example.com', phone: '555-0103',
        claimType: 'Property', incidentDate: '2026-04-08',
        description: 'Flood damage to home foundation and personal belongings.',
        amount: 35000, status: 'accepted', submittedAt: daysAgo(20),
        acceptedAt: daysAgo(17), acceptanceNotes: 'Documents verified and complete. Proceeding to evaluation.'
      },
      {
        id: 'CLM-2026-0004',
        claimantName: 'David Lee', email: 'david@example.com', phone: '555-0104',
        claimType: 'Auto', incidentDate: '2026-04-05',
        description: 'Total loss of vehicle in multi-car accident.',
        amount: 22000, status: 'under_evaluation', submittedAt: daysAgo(25),
        acceptedAt: daysAgo(22), acceptanceNotes: 'Valid documentation.',
        evaluationStartedAt: daysAgo(20)
      },
      {
        id: 'CLM-2026-0005',
        claimantName: 'Emma Davis', email: 'emma@example.com', phone: '555-0105',
        claimType: 'Medical', incidentDate: '2026-03-15',
        description: 'Ongoing physical therapy and rehabilitation after spinal injury.',
        amount: 28000, status: 'evaluated', submittedAt: daysAgo(40),
        acceptedAt: daysAgo(38), acceptanceNotes: 'All medical records received.',
        evaluationStartedAt: daysAgo(36),
        evaluatedAt: daysAgo(30), evaluationNotes: 'Medical expenses verified against submitted bills. Deducted non-covered items.',
        evaluatedAmount: 24500, riskLevel: 'medium'
      },
      {
        id: 'CLM-2026-0006',
        claimantName: 'Frank Wilson', email: 'frank@example.com', phone: '555-0106',
        claimType: 'Property', incidentDate: '2026-03-01',
        description: 'Fire damage to commercial property, including structural and equipment loss.',
        amount: 85000, status: 'approved', submittedAt: daysAgo(55),
        acceptedAt: daysAgo(53), acceptanceNotes: 'Fire incident report and insurance policy confirmed.',
        evaluationStartedAt: daysAgo(50),
        evaluatedAt: daysAgo(42), evaluationNotes: 'On-site assessment completed. Equipment list cross-checked.',
        evaluatedAmount: 80000, riskLevel: 'high',
        approvedAt: daysAgo(35), approvalNotes: 'Approved after legal review. Payment authorized.',
        approvedAmount: 80000
      },
      {
        id: 'CLM-2026-0007',
        claimantName: 'Grace Kim', email: 'grace@example.com', phone: '555-0107',
        claimType: 'Medical', incidentDate: '2026-02-20',
        description: 'Pre-existing condition claim rejected per policy exclusion clause.',
        amount: 6500, status: 'rejected', submittedAt: daysAgo(65),
        rejectedAt: daysAgo(62), rejectionNotes: 'Claim rejected — pre-existing condition not covered under current policy.'
      }
    ];
    this.saveCases(samples);
  },

  /* ── Stats ─────────────────────────────── */
  getStats() {
    const cases = this.getCases();
    return {
      total:           cases.length,
      submitted:       cases.filter(c => c.status === 'submitted').length,
      accepted:        cases.filter(c => c.status === 'accepted').length,
      under_eval:      cases.filter(c => c.status === 'under_evaluation').length,
      evaluated:       cases.filter(c => c.status === 'evaluated').length,
      approved:        cases.filter(c => c.status === 'approved').length,
      rejected:        cases.filter(c => ['rejected','denied'].includes(c.status)).length,
      totalApproved:   cases.filter(c => c.status === 'approved').reduce((s,c) => s + (c.approvedAmount||0), 0)
    };
  },

  /* ── Page init ─────────────────────────── */
  init(activePage) {
    this.requireAuth();
    this.seedData();
    this.renderSidebarUser();
    this.setActiveNav(activePage);
    this.renderHeaderUser(activePage);
    this.renderBadges();
  },

  renderSidebarUser() {
    const u = this.getUser();
    if (!u) return;
    const el = document.getElementById('sidebarUserName');
    if (el) el.textContent = u.name || u.email;
    const av = document.getElementById('sidebarAvatar');
    if (av) av.textContent = (u.name || u.email).charAt(0).toUpperCase();
  },

  renderHeaderUser(page) {
    const u = this.getUser();
    if (!u) return;
    const el = document.getElementById('headerUserName');
    if (el) el.textContent = u.name || u.email;
  },

  setActiveNav(page) {
    document.querySelectorAll('.nav-link[data-page]').forEach(a => {
      a.classList.toggle('active', a.dataset.page === page);
    });
  },

  renderBadges() {
    const stats = this.getStats();
    const map = {
      'badge-acceptance': stats.submitted,
      'badge-evaluation': stats.under_eval,
      'badge-approval':   stats.evaluated
    };
    Object.entries(map).forEach(([id, count]) => {
      const el = document.getElementById(id);
      if (el) {
        el.textContent = count;
        el.style.display = count > 0 ? '' : 'none';
      }
    });
  },

  /* ── Sidebar HTML (shared) ─────────────── */
  sidebarHTML() {
    return `
    <div class="sidebar-brand">
      <div class="brand-icon">
        <svg width="20" height="20" fill="none" stroke="#fff" stroke-width="2" viewBox="0 0 24 24">
          <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
      </div>
      <div>
        <div class="brand-name">ClaimsPro</div>
        <div class="brand-tag">Management System</div>
      </div>
    </div>
    <nav class="sidebar-nav">
      <div class="nav-section">Main Menu</div>
      <a href="dashboard.html" class="nav-link" data-page="dashboard">
        <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
          <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
        </svg>
        Dashboard
      </a>
      <a href="case-registration.html" class="nav-link" data-page="registration">
        <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
          <polyline points="14 2 14 8 20 8"/><line x1="12" y1="11" x2="12" y2="17"/>
          <line x1="9" y1="14" x2="15" y2="14"/>
        </svg>
        Case Registration
      </a>
      <a href="case-acceptance.html" class="nav-link" data-page="acceptance">
        <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M22 11.08V12a10 10 0 11-5.93-9.14"/>
          <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        Case Acceptance
        <span class="nav-badge" id="badge-acceptance" style="display:none"></span>
      </a>
      <a href="case-evaluation.html" class="nav-link" data-page="evaluation">
        <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/>
          <rect x="9" y="3" width="6" height="4" rx="1"/>
          <line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="12" y2="16"/>
        </svg>
        Case Evaluation
        <span class="nav-badge" id="badge-evaluation" style="display:none"></span>
      </a>
      <a href="case-approval.html" class="nav-link" data-page="approval">
        <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/>
        </svg>
        Case Approval
        <span class="nav-badge" id="badge-approval" style="display:none"></span>
      </a>
    </nav>
    <div class="sidebar-footer">
      <div class="sidebar-user">
        <div class="user-avatar" id="sidebarAvatar">A</div>
        <div>
          <div class="user-name" id="sidebarUserName">User</div>
          <div class="user-role">Claims Officer</div>
        </div>
      </div>
      <button class="btn-logout" onclick="App.logout()">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
          <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        Sign Out
      </button>
    </div>`;
  },

  /* ── Toast notifications ───────────────── */
  toast(msg, type = 'success') {
    let container = document.getElementById('toastContainer');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toastContainer';
      container.style.cssText = 'position:fixed;bottom:24px;right:24px;z-index:9999;display:flex;flex-direction:column;gap:8px;';
      document.body.appendChild(container);
    }
    const t = document.createElement('div');
    const colors = { success: '#10b981', error: '#ef4444', info: '#3b82f6', warning: '#f59e0b' };
    t.style.cssText = `background:#1f2937;color:#fff;padding:12px 18px;border-radius:10px;font-size:13.5px;font-weight:500;
      box-shadow:0 4px 20px rgba(0,0,0,0.25);display:flex;align-items:center;gap:10px;min-width:240px;max-width:340px;
      border-left:4px solid ${colors[type]||colors.success};
      animation:slideIn .25s ease;`;
    t.innerHTML = `<span>${msg}</span>`;
    container.appendChild(t);
    setTimeout(() => t.remove(), 3500);
  }
};

/* Global animation */
const style = document.createElement('style');
style.textContent = `@keyframes slideIn{from{opacity:0;transform:translateX(20px)}to{opacity:1;transform:translateX(0)}}`;
document.head.appendChild(style);
