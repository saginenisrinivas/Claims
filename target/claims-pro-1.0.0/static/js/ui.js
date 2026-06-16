/**
 * ui.js — UI utilities only.
 * No business logic, no data fetching. Pure DOM / display helpers.
 */
const UI = {

    /* ── Formatters ──────────────────────────────────────────────── */
    fmtDate(d) {
        if (!d) return '—';
        return new Date(d).toLocaleDateString('en-US',
            { year: 'numeric', month: 'short', day: 'numeric' });
    },

    fmtDateTime(d) {
        if (!d) return '—';
        return new Date(d).toLocaleString('en-US',
            { year: 'numeric', month: 'short', day: 'numeric',
              hour: '2-digit', minute: '2-digit' });
    },

    fmtCurrency(n) {
        if (n === undefined || n === null || n === '') return '—';
        return new Intl.NumberFormat('en-BW',
            { style: 'currency', currency: 'BWP' }).format(n);
    },

    /* ── Lookup label helpers ────────────────────────────────────── */
    _lookups: {},

    async loadLookups(categories) {
        const results = await Promise.all(
            categories.map(cat => API.getLookupValues(cat).catch(() => []))
        );
        categories.forEach((cat, i) => {
            const map = {};
            (results[i] || []).forEach(lv => { map[lv.code] = lv.label; });
            this._lookups[cat] = map;
        });
    },

    label(category, code) {
        if (!code) return '—';
        const map = this._lookups[category] || {};
        return map[code] || code;
    },

    /* ── Status display ──────────────────────────────────────────── */
    statusLabel(s) {
        const map = {
            SUBMITTED:        'Submitted',
            ACCEPTED:         'Accepted',
            REJECTED:         'Rejected',
            UNDER_EVALUATION: 'Under Evaluation',
            EVALUATED:        'Evaluated',
            APPROVED:         'Approved',
            DENIED:           'Denied'
        };
        return map[s] || s;
    },

    statusBadge(s) {
        const cls = {
            SUBMITTED:        'badge-gray',
            ACCEPTED:         'badge-blue',
            REJECTED:         'badge-red',
            UNDER_EVALUATION: 'badge-yellow',
            EVALUATED:        'badge-purple',
            APPROVED:         'badge-green',
            DENIED:           'badge-red'
        }[s] || 'badge-gray';
        return `<span class="badge ${cls}">${this.statusLabel(s)}</span>`;
    },

    riskBadge(r) {
        if (!r) return '—';
        const cls = { low: 'badge-green', medium: 'badge-yellow', high: 'badge-red' }[r] || 'badge-gray';
        return `<span class="badge ${cls}">${r.charAt(0).toUpperCase() + r.slice(1)}</span>`;
    },

    /* ── Toast ───────────────────────────────────────────────────── */
    toast(msg, type = 'success') {
        let container = document.getElementById('toastContainer');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toastContainer';
            container.style.cssText =
                'position:fixed;bottom:24px;right:24px;z-index:9999;' +
                'display:flex;flex-direction:column;gap:8px;';
            document.body.appendChild(container);
        }
        const colors = {
            success: '#10b981', error: '#ef4444',
            info: '#3b82f6',    warning: '#f59e0b'
        };
        const t = document.createElement('div');
        t.style.cssText =
            `background:#1f2937;color:#fff;padding:12px 18px;border-radius:10px;` +
            `font-size:13.5px;font-weight:500;box-shadow:0 4px 20px rgba(0,0,0,0.25);` +
            `display:flex;align-items:center;gap:10px;min-width:240px;max-width:340px;` +
            `border-left:4px solid ${colors[type] || colors.success};` +
            `animation:slideIn .25s ease;`;
        t.innerHTML = `<span>${msg}</span>`;
        container.appendChild(t);
        setTimeout(() => t.remove(), 3500);
    },

    /* ── Modal helpers ───────────────────────────────────────────── */
    openModal(overlayId)  { document.getElementById(overlayId).classList.add('open'); },
    closeModal(overlayId) { document.getElementById(overlayId).classList.remove('open'); },

    /* ── Loading state ───────────────────────────────────────────── */
    setLoading(btn, loading) {
        btn.disabled = loading;
        btn.dataset.originalText = btn.dataset.originalText || btn.textContent;
        btn.textContent = loading ? 'Please wait…' : btn.dataset.originalText;
    },

    /* ── Sidebar HTML ────────────────────────────────────────────── */
    _role: '',

    sidebarHTML(activePage, navBadges = {}) {
        const role = this._role;
        const navItems = [
            { page: 'dashboard',         href: '/dashboard',        label: 'Dashboard',
              roles: ['Administrator', 'Claims Officer', 'Case Manager'],
              icon: `<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>` },
            { page: 'case-registration', href: '/case-registration', label: 'Case Registration',
              roles: ['Claims Officer'],
              icon: `<path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="12" y1="11" x2="12" y2="17"/><line x1="9" y1="14" x2="15" y2="14"/>` },
            { page: 'case-acceptance',   href: '/case-acceptance',   label: 'Case Acceptance',   badgeKey: 'submitted',
              roles: ['Claims Officer'],
              icon: `<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>` },
            { page: 'case-evaluation',   href: '/case-evaluation',   label: 'Case Evaluation',   badgeKey: 'underEval',
              roles: ['Claims Officer'],
              icon: `<path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/><rect x="9" y="3" width="6" height="4" rx="1"/><line x1="9" y1="12" x2="15" y2="12"/><line x1="9" y1="16" x2="12" y2="16"/>` },
            { page: 'case-approval',     href: '/case-approval',     label: 'Case Approval',     badgeKey: 'evaluated',
              roles: ['Case Manager'],
              icon: `<circle cx="12" cy="8" r="6"/><path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/>` }
        ];

        const visible = role
            ? navItems.filter(item => item.roles.includes(role))
            : navItems;

        const links = visible.map(item => {
            const active = item.page === activePage ? ' active' : '';
            const count  = item.badgeKey ? (navBadges[item.badgeKey] || 0) : 0;
            const badge  = count > 0
                ? `<span class="nav-badge">${count}</span>` : '';
            return `
              <a href="${item.href}" class="nav-link${active}" data-page="${item.page}">
                <svg width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  ${item.icon}
                </svg>
                ${item.label}${badge}
              </a>`;
        }).join('');

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
            ${links}
          </nav>
          <div class="sidebar-footer">
            <div class="sidebar-user">
              <div class="user-avatar" id="sidebarAvatar">?</div>
              <div>
                <div class="user-name" id="sidebarUserName">Loading…</div>
                <div class="user-role"  id="sidebarUserRole"></div>
              </div>
            </div>
            <button class="btn-logout" onclick="UI.logout()">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
                <polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
              </svg>
              Sign Out
            </button>
          </div>`;
    },

    /* ── Page initialiser ────────────────────────────────────────── */
    async initPage(activePage) {
        try {
            const user = await API.getCurrentUser();
            this._role = user.role || '';

            /* Rebuild sidebar with role-filtered nav */
            const sidebar = document.getElementById('sidebar');
            if (sidebar) sidebar.innerHTML = this.sidebarHTML(activePage);

            const nameEl = document.getElementById('sidebarUserName');
            const roleEl = document.getElementById('sidebarUserRole');
            const avEl   = document.getElementById('sidebarAvatar');
            const hdrEl  = document.getElementById('headerUserName');
            if (nameEl) nameEl.textContent = user.name || user.email;
            if (roleEl) roleEl.textContent = user.role || '';
            if (avEl)   avEl.textContent   = (user.name || user.email).charAt(0).toUpperCase();
            if (hdrEl)  hdrEl.textContent  = user.name || user.email;

            return user;
        } catch {
            window.location.href = '/login';
        }
    },

    logout() {
        API.logout().finally(() => { window.location.href = '/login'; });
    },

    /* ── Section accordion ───────────────────────────────────────── */
    toggleSection(header) {
        const toggle = header.querySelector('.section-toggle');
        const body   = header.nextElementSibling;
        if (toggle) toggle.classList.toggle('collapsed');
        if (body)   body.classList.toggle('hidden');
    },

    /* ── Empty state ─────────────────────────────────────────────── */
    emptyRow(cols, title, subtitle) {
        return `<tr><td colspan="${cols}">
          <div class="empty-state">
            <svg width="40" height="40" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2"/>
              <rect x="9" y="3" width="6" height="4" rx="1"/>
            </svg>
            <h3>${title}</h3><p>${subtitle}</p>
          </div></td></tr>`;
    }
};

/* Slide-in animation for toasts */
const _s = document.createElement('style');
_s.textContent = `@keyframes slideIn{from{opacity:0;transform:translateX(20px)}to{opacity:1;transform:translateX(0)}}`;
document.head.appendChild(_s);
