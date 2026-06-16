<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Case Registration â€" ClaimsPro</title>
  <link rel="stylesheet" href="/static/css/style.css"/>
  <style>
    .form-section { border:1px solid #e5e7eb; border-radius:10px; margin-bottom:16px; overflow:hidden; }
    .section-header { display:flex; align-items:center; gap:10px; padding:11px 18px; background:linear-gradient(90deg,#eef2ff,#f8fafc); border-bottom:1px solid #e5e7eb; cursor:pointer; user-select:none; }
    .section-header:hover { background:linear-gradient(90deg,#e0e7ff,#f1f5f9); }
    .section-toggle { width:18px; height:18px; background:#0f3460; border-radius:50%; display:flex; align-items:center; justify-content:center; flex-shrink:0; transition:transform .2s; }
    .section-toggle.collapsed { transform:rotate(-90deg); }
    .section-title { font-size:13.5px; font-weight:700; color:#0f3460; }
    .section-body { padding:18px 20px; background:#fff; }
    .section-body.hidden { display:none; }
    .row-4 { display:grid; grid-template-columns:repeat(4,1fr); gap:14px 20px; }
    .row-3 { display:grid; grid-template-columns:repeat(3,1fr); gap:14px 20px; }
    .row-2 { display:grid; grid-template-columns:repeat(2,1fr); gap:14px 20px; }
    .span-2 { grid-column:span 2; }
    .col-full { grid-column:1/-1; }
    .field { display:flex; flex-direction:column; gap:4px; }
    .field label { font-size:12px; font-weight:600; color:#374151; }
    .field label .req { color:#e94560; margin-left:2px; }
    .field input, .field select, .field textarea { padding:7px 11px; border:1px solid #d1d5db; border-radius:6px; font-size:13.5px; color:#111; background:#fff; outline:none; font-family:inherit; transition:border-color .18s; width:100%; }
    .field input:focus, .field select:focus, .field textarea:focus { border-color:#0f3460; box-shadow:0 0 0 3px rgba(15,52,96,.08); }
    .field input[readonly], .field input[disabled] { background:#f3f4f6; color:#6b7280; }
    .field input.err, .field select.err, .field textarea.err { border-color:#ef4444; }
    .field .errmsg { font-size:11px; color:#ef4444; display:none; }
    .field .errmsg.show { display:block; }
    .agent-pair { display:flex; gap:6px; }
    .agent-pair input:first-child { width:110px; flex-shrink:0; }
    .agent-pair input:last-child { flex:1; }
    .checkbox-group { display:flex; align-items:center; gap:24px; padding:6px 0; }
    .chk-item { display:flex; align-items:center; gap:6px; font-size:13.5px; color:#374151; cursor:pointer; }
    .chk-item input[type=checkbox] { width:15px; height:15px; accent-color:#0f3460; }
    .action-bar { position:sticky; bottom:0; background:#fff; border-top:1px solid #e5e7eb; padding:12px 24px; display:flex; align-items:center; justify-content:center; gap:10px; z-index:40; box-shadow:0 -2px 8px rgba(0,0,0,.06); }
    .action-bar .btn { min-width:110px; justify-content:center; }
    #pageAlert { margin:0 28px 16px; padding:11px 16px; border-radius:8px; font-size:13px; display:none; }
    #pageAlert.success { background:#f0fdf4; color:#166534; border:1px solid #bbf7d0; display:block; }
    #pageAlert.error   { background:#fff5f5; color:#991b1b; border:1px solid #fecaca; display:block; }
    @media(max-width:900px){ .row-4,.row-3{ grid-template-columns:1fr 1fr; } }
    @media(max-width:600px){ .row-4,.row-3,.row-2{ grid-template-columns:1fr; } .span-2,.col-full{ grid-column:span 1; } }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
<div class="app-layout">
  <aside class="sidebar" id="sidebar"></aside>
  <div class="main">
    <header class="top-header">
      <div class="header-left"><h2>Case Registration</h2><p>Register a new insurance claim</p></div>
      <div class="header-right">
        <div class="header-user">
          <svg width="15" height="15" fill="none" stroke="#6b7280" stroke-width="2" viewBox="0 0 24 24">
            <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/>
          </svg>
          <span id="headerUserName">â€"</span>
        </div>
        <span id="caseIdBadge" style="font-size:13px;font-weight:700;color:#0f3460;background:#eef2ff;padding:5px 14px;border-radius:7px;"></span>
      </div>
    </header>

    <div id="pageAlert"></div>

    <main class="page-content" style="padding-bottom:0;">

      <!-- â‘  Insured Information -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Insured Information</span>
        </div>
        <div class="section-body">
          <div class="row-4">
            <div class="field span-2">
              <label>Life Assured Name <span class="req">*</span></label>
              <input type="text" id="lifeAssuredName" placeholder="First Name and Last Name"/>
              <span class="errmsg" id="e_lifeAssuredName">Required.</span>
            </div>
            <div class="field">
              <label>Gender</label>
              <select id="gender"><option value="">— Select —</option></select>
            </div>
            <div class="field">
              <label>ID Type</label>
              <select id="idType"><option value="">— Select —</option></select>
            </div>
            <div class="field">
              <label>ID No.</label>
              <input type="text" id="idNo" placeholder="Identity number"/>
            </div>
          </div>
        </div>
      </div>

      <!-- ② Policy Information -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Policy Information</span>
          <span id="policyBadge" style="margin-left:12px;font-size:11.5px;font-weight:600;color:#0f3460;background:#eef2ff;padding:2px 10px;border-radius:10px;display:none;"></span>
        </div>
        <div class="section-body">

          <div style="display:flex;align-items:center;gap:12px;margin-bottom:16px;flex-wrap:wrap;">
            <button type="button" class="btn btn-outline" id="btnFetchPolicies" onclick="fetchPolicies()">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
              </svg>
              Fetch Policies
            </button>
            <span style="font-size:12.5px;color:#6b7280;">Searches the policy system using the <strong>ID No.</strong> entered above.</span>
          </div>

          <!-- Selected policy highlight -->
          <div id="selectedPolicyBanner" style="display:none;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:10px 16px;margin-bottom:14px;display:none;align-items:center;gap:10px;">
            <svg width="16" height="16" fill="none" stroke="#16a34a" stroke-width="2.5" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <span style="font-size:13px;color:#166534;">Selected Policy: <strong id="selPolicyNum" style="color:#0f3460;"></strong> &mdash; <span id="selPolicyName" style="font-style:italic;"></span></span>
            <button type="button" onclick="clearSelectedPolicy()" style="margin-left:auto;font-size:11px;color:#6b7280;background:none;border:none;cursor:pointer;">&#10005; Clear</button>
          </div>

          <!-- Results table -->
          <div id="policyResults"></div>

        </div>
      </div>

      <!-- ③ Claim Information -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Claim Information</span>
        </div>
        <div class="section-body">
          <div class="row-4">
            <div class="field">
              <label>Type of Claim <span class="req">*</span></label>
              <select id="claimType"><option value="">Please Select</option></select>
              <span class="errmsg" id="e_claimType">Required.</span>
            </div>
            <div class="field">
              <label>Notification Date <span class="req">*</span></label>
              <input type="date" id="notificationDate"/>
              <span class="errmsg" id="e_notificationDate">Required.</span>
            </div>
            <div class="field">
              <label>Claim Nature <span class="req">*</span></label>
              <select id="claimNature"><option value="">Please Select</option></select>
              <span class="errmsg" id="e_claimNature">Required.</span>
            </div>
            <div class="field">
              <label>Case Classification</label>
              <select id="caseClassification"><option value="">Please Select</option></select>
            </div>
            <div class="field">
              <label>Event Date <span class="req">*</span></label>
              <input type="date" id="eventDate"/>
              <span class="errmsg" id="e_eventDate">Required.</span>
            </div>
            <div class="field">
              <label>Cause of Death</label>
              <input type="text" id="causeOfDeath" placeholder="e.g. 20"/>
            </div>
          </div>
        </div>
      </div>

      <!-- â’¢ Reporter Information -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Reporter Information</span>
        </div>
        <div class="section-body">
          <div class="row-4" style="margin-bottom:14px;">
            <div class="field">
              <label>Reporter Name <span class="req">*</span></label>
              <input type="text" id="reporterName" placeholder="Full name"/>
              <span class="errmsg" id="e_reporterName">Required.</span>
            </div>
            <div class="field">
              <label>Relation With Life Assured <span class="req">*</span></label>
              <select id="relation"></select>
            </div>
            <div class="field">
              <label>Report Via <span class="req">*</span></label>
              <select id="reportVia"></select>
            </div>
            <div class="field">
              <label>Reporter ID Number</label>
              <input type="text" id="reporterId" placeholder="e.g. 650002090"/>
            </div>
            <div class="field">
              <label>Mobile Phone <span class="req">*</span></label>
              <input type="tel" id="mobilePhone" placeholder="e.g. 60123456789"/>
              <span class="errmsg" id="e_mobilePhone">Required.</span>
            </div>
            <div class="field">
              <label>SMS <span class="req">*</span></label>
              <select id="smsConsent"><option value="Yes">Yes</option><option value="No">No</option></select>
            </div>
            <div class="field">
              <label>Contact Number</label>
              <input type="tel" id="contactNumber" placeholder="Home / office number"/>
            </div>
            <div class="field">
              <label>Email Address <span class="req">*</span></label>
              <input type="email" id="emailAddress" placeholder="reporter@email.com"/>
              <span class="errmsg" id="e_emailAddress">Valid email required.</span>
            </div>
          </div>
          <div class="row-2" style="margin-bottom:14px;">
            <div class="field">
              <label>Address <span class="req">*</span></label>
              <input type="text" id="addr1" placeholder="Address line 1" style="margin-bottom:5px;"/>
              <input type="text" id="addr2" placeholder="Address line 2" style="margin-bottom:5px;"/>
              <input type="text" id="addr3" placeholder="City / Town"    style="margin-bottom:5px;"/>
              <input type="text" id="addr4" placeholder="State / Province"/>
              <span class="errmsg" id="e_addr1">Address is required.</span>
            </div>
            <div class="field" style="align-self:start;">
              <label>Postal Code</label>
              <input type="text" id="postalCode" placeholder="e.g. 50000" style="max-width:180px;"/>
            </div>
          </div>
          <div class="row-4">
            <div class="field span-2">
              <label>Agent</label>
              <div class="agent-pair">
                <input type="text" id="agentCode" readonly/>
                <input type="text" id="agentName" readonly/>
              </div>
            </div>
            <div class="field">
              <label>Mobile Phone</label>
              <input type="tel" id="agentMobile" readonly/>
            </div>
            <div class="field">
              <label>SMS</label>
              <select id="agentSms" disabled>
                <option value="Yes">Yes</option><option value="No">No</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- ④ Policy Type -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Policy Type</span>
        </div>
        <div class="section-body">
          <div class="checkbox-group">
            <label class="chk-item"><input type="checkbox" id="polIndividual" checked/> Individual</label>
            <label class="chk-item"><input type="checkbox" id="polGroup"/> Group</label>
            <label class="chk-item"><input type="checkbox" id="polBanca"/> Bancassurance</label>
          </div>
        </div>
      </div>

      <!-- ⑤ Supporting Documents -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Supporting Documents</span>
          <span id="docCountBadge" style="margin-left:12px;font-size:11.5px;font-weight:600;color:#0f3460;background:#eef2ff;padding:2px 10px;border-radius:10px;display:none;"></span>
        </div>
        <div class="section-body">
          <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;flex-wrap:wrap;">
            <select id="docTypeSelect"
                    style="padding:7px 11px;border:1px solid #d1d5db;border-radius:6px;font-size:13.5px;color:#111;background:#fff;outline:none;min-width:200px;transition:border-color .18s;"
                    onchange="this.style.borderColor=''">
              <option value="">-- Select Document Type --</option>
              <option>Death Certificate</option>
              <option>Registration Form</option>
              <option>ID Proof</option>
              <option>Bank Proof</option>
              <option>Other</option>
            </select>
            <button type="button" class="btn btn-outline" id="btnBrowse"
                    onclick="checkDocTypeAndBrowse()">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>
              </svg>
              Browse &amp; Add
            </button>
            <input type="file" id="docFileInput" accept=".pdf,.jpg,.jpeg,.png,.docx,.doc"
                   style="position:fixed;left:-9999px;opacity:0;width:0;height:0;"
                   onchange="stageFile(this)"/>
            <span style="font-size:12px;color:#6b7280;">Accepted: PDF, JPG, PNG, DOCX &mdash; max 10 MB each</span>
          </div>
          <div id="docList">
            <div style="text-align:center;color:#9ca3af;font-size:13px;padding:18px 0;border:1px dashed #e5e7eb;border-radius:8px;">
              No documents added yet. Select a type and click Browse &amp; Add.
            </div>
          </div>
        </div>
      </div>

      <!-- ⑥ Claim Comments -->
      <div class="form-section">
        <div class="section-header" onclick="UI.toggleSection(this)">
          <div class="section-toggle"><svg width="10" height="10" fill="none" stroke="#fff" stroke-width="3" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg></div>
          <span class="section-title">Claim Comments</span>
        </div>
        <div class="section-body">
          <div class="row-4" style="margin-bottom:14px;">
            <div class="field">
              <label>Claim Officer</label>
              <select id="claimOfficer"><option value="">Please Select</option></select>
            </div>
            <div class="field">
              <label>Pending Status</label>
              <input type="text" id="pendingStatus" placeholder="e.g. Awaiting documents"/>
            </div>
            <div class="field">
              <label>Review Date</label>
              <input type="date" id="reviewDate"/>
            </div>
          </div>
          <div class="row-2">
            <div class="field">
              <label>Comments History</label>
              <textarea style="min-height:90px;resize:vertical;" id="commentsHistory" rows="4" readonly
                placeholder="Previous comments will appear hereâ€¦"></textarea>
            </div>
            <div class="field">
              <label>General Comments <span class="req">*</span></label>
              <textarea style="min-height:90px;resize:vertical;" id="generalComments" rows="4"
                placeholder="Enter remarks or notes about this claimâ€¦"></textarea>
              <span class="errmsg" id="e_generalComments">Required.</span>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div class="action-bar">
      <button class="btn btn-primary" id="btnSubmit" onclick="handleSubmit()">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        Submit
      </button>
      <button class="btn btn-warning" onclick="handlePend()">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        Pend
      </button>
      <button class="btn btn-outline" onclick="handleQueryComments()">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
        </svg>
        Query Comments
      </button>
      <button class="btn btn-ghost" onclick="handleExit()">Exit</button>
    </div>
  </div>
</div>

<!-- Success Confirmation Modal -->
<div class="modal-overlay" id="successOverlay" style="z-index:200;">
  <div class="modal" style="max-width:500px;">
    <div class="modal-header">
      <div>
        <div class="modal-title" style="color:#166534;">Case Registered Successfully</div>
        <div style="font-size:12px;color:#6b7280;margin-top:2px;">The case has been registered with THITO and is awaiting acceptance.</div>
      </div>
    </div>
    <div class="modal-body" id="successModalBody"></div>
    <div class="modal-footer">
      <button class="btn btn-ghost" onclick="closeSuccessAndReset()">Close</button>
      <button class="btn btn-primary" onclick="goToAcceptance()">Continue with Acceptance</button>
    </div>
  </div>
</div>

<script src="/static/js/api.js"></script>
<script src="/static/js/ui.js"></script>
<script>
  /* ── Module-level state ───────────────────────────────────────────── */
  var _stagedDocs    = [];   // files staged before submission
  var _selectedPolicy = null;

  /* ── Dropdown helpers ─────────────────────────────────────────────── */
  function populateSelect(id, items, blankLabel, defaultCode) {
    const sel = document.getElementById(id);
    sel.innerHTML = '';
    if (blankLabel !== null) {
      const opt = document.createElement('option');
      opt.value = ''; opt.textContent = blankLabel;
      sel.appendChild(opt);
    }
    (items || []).forEach(item => {
      const opt = document.createElement('option');
      opt.value = item.code; opt.textContent = item.label;
      sel.appendChild(opt);
    });
    if (defaultCode !== undefined) sel.value = defaultCode;
  }
  /* â"€â"€ Page initialisation â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
  (async () => {
    document.getElementById('sidebar').innerHTML = UI.sidebarHTML('case-registration');
    await UI.initPage('case-registration');

    const today = new Date().toISOString().split('T')[0];
    document.getElementById('notificationDate').value = today;
    document.getElementById('eventDate').max = today;

    const rd = new Date();
    rd.setDate(rd.getDate() + 8);
    document.getElementById('reviewDate').value = rd.toISOString().split('T')[0];

    // Load all dropdowns from DB
    const [dvGender, dvIdType, dvClaimType, dvClaimNature, dvCaseClass,
           dvRelation, dvReportVia, dvOfficer] =
      await Promise.all([
        API.getLookupValues('GENDER'),
        API.getLookupValues('ID_TYPE'),
        API.getLookupValues('CLAIM_TYPE'),
        API.getLookupValues('CLAIM_NATURE'),
        API.getLookupValues('CASE_CLASSIFICATION'),
        API.getLookupValues('RELATION'),
        API.getLookupValues('REPORT_VIA'),
        API.getLookupValues('CLAIM_OFFICER')
      ]).catch(() => [[],[],[],[],[],[],[],[]]);

    populateSelect('gender',             dvGender,      '— Select —',   '');
    populateSelect('idType',             dvIdType,      '— Select —',   '');
    populateSelect('claimType',          dvClaimType,   'Please Select','');
    populateSelect('claimNature',        dvClaimNature, 'Please Select','');
    populateSelect('caseClassification', dvCaseClass,   'Please Select','');
    populateSelect('relation',           dvRelation,    null,           'Self');
    populateSelect('reportVia',          dvReportVia,   null,           'Post / Mail');
    populateSelect('claimOfficer',       dvOfficer,     'Please Select','');

    // Prefill agent from session user
    const user = await API.getCurrentUser().catch(() => ({}));
    document.getElementById('agentCode').value   = 'AGT-001';
    document.getElementById('agentName').value   = user.name || '';
    document.getElementById('agentMobile').value = '—';

    refreshNextId();
  })();

  async function refreshNextId() {
    // Show approximate next ID based on current count
    const stats = await API.getStats().catch(() => ({ total: 0 }));
    const year = new Date().getFullYear();
    const seq  = String(stats.total + 1).padStart(4, '0');
    document.getElementById('caseIdBadge').textContent = `CLM-${year}-${seq}`;
  }

  /* â"€â"€ Validation â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
  const REQUIRED = [
    { id:'lifeAssuredName', err:'e_lifeAssuredName', check: v => v.trim().length > 0 },
    { id:'claimType',       err:'e_claimType',       check: v => v !== '' },
    { id:'notificationDate',err:'e_notificationDate',check: v => v !== '' },
    { id:'claimNature',     err:'e_claimNature',     check: v => v !== '' },
    { id:'eventDate',       err:'e_eventDate',       check: v => v !== '' },
    { id:'reporterName',    err:'e_reporterName',    check: v => v.trim().length > 0 },
    { id:'mobilePhone',     err:'e_mobilePhone',     check: v => v.trim().length > 0 },
    { id:'emailAddress',    err:'e_emailAddress',    check: v => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) },
    { id:'addr1',           err:'e_addr1',           check: v => v.trim().length > 0 },
    { id:'generalComments', err:'e_generalComments', check: v => v.trim().length > 0 }
  ];

  REQUIRED.forEach(f => {
    const el = document.getElementById(f.id);
    const fn = () => { if (f.check(el.value)) { el.classList.remove('err'); document.getElementById(f.err).classList.remove('show'); } };
    el.addEventListener('input', fn);
    el.addEventListener('change', fn);
  });

  function validate() {
    let ok = true;
    REQUIRED.forEach(f => {
      const el  = document.getElementById(f.id);
      const err = document.getElementById(f.err);
      const bad = !f.check(el.value);
      el.classList.toggle('err', bad);
      err.classList.toggle('show', bad);
      if (bad) ok = false;
    });
    return ok;
  }

  function buildPayload() {
    const policyType = [];
    if (document.getElementById('polIndividual').checked) policyType.push('Individual');
    if (document.getElementById('polGroup').checked)      policyType.push('Group');
    if (document.getElementById('polBanca').checked)      policyType.push('Bancassurance');

    return {
      lifeAssuredName:  document.getElementById('lifeAssuredName').value.trim(),
      gender:           document.getElementById('gender').value,
      idType:           document.getElementById('idType').value,
      idNo:             document.getElementById('idNo').value.trim(),
      policyNumber:     _selectedPolicy ? _selectedPolicy.number : '',
      claimType:        document.getElementById('claimType').value,
      notificationDate: document.getElementById('notificationDate').value,
      claimNature:      document.getElementById('claimNature').value,
      caseClassification: document.getElementById('caseClassification').value,
      eventDate:        document.getElementById('eventDate').value || null,
      causeOfDeath:     document.getElementById('causeOfDeath').value.trim() || null,
      reporterId:       document.getElementById('reporterId').value.trim() || null,
      reporterName:     document.getElementById('reporterName').value.trim(),
      relation:         document.getElementById('relation').value,
      reportVia:        document.getElementById('reportVia').value,
      phone:            document.getElementById('mobilePhone').value.trim(),
      smsConsent:       document.getElementById('smsConsent').value,
      contactNumber:    document.getElementById('contactNumber').value.trim(),
      email:            document.getElementById('emailAddress').value.trim(),
      addressLine1:     document.getElementById('addr1').value.trim(),
      addressLine2:     document.getElementById('addr2').value.trim(),
      addressLine3:     document.getElementById('addr3').value.trim(),
      addressLine4:     document.getElementById('addr4').value.trim(),
      postalCode:       document.getElementById('postalCode').value.trim(),
      agentCode:        document.getElementById('agentCode').value,
      agentName:        document.getElementById('agentName').value,
      agentMobile:      document.getElementById('agentMobile').value,
      policyType,
      claimOfficer:     document.getElementById('claimOfficer').value,
      pendingStatus:    document.getElementById('pendingStatus').value.trim(),
      reviewDate:       document.getElementById('reviewDate').value || null,
      generalComments:  document.getElementById('generalComments').value.trim()
    };
  }

  function showAlert(type, msg) {
    const el = document.getElementById('pageAlert');
    el.className = type;
    el.textContent = msg;
    setTimeout(() => el.className = '', 6000);
  }

  /* ── Success modal ─────────────────────────────────────────────────── */
  var _lastRegisteredId = null;

  function showSuccessModal(result) {
    _lastRegisteredId = result.id;
    const bcpRef    = result.externalCaseNo || '—';
    const bcpStatus = result.bcpCaseStatus  || 'N/A';
    document.getElementById('successModalBody').innerHTML =
      '<div style="text-align:center;padding:4px 0 16px;">' +
        '<svg width="52" height="52" fill="none" stroke="#16a34a" stroke-width="1.5" viewBox="0 0 24 24" style="margin-bottom:10px;">' +
          '<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>' +
        '</svg>' +
      '</div>' +
      '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:14px;">' +
        '<div style="background:#f0fdf4;border-radius:8px;padding:12px;">' +
          '<div style="font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;margin-bottom:4px;">System Case No.</div>' +
          '<div style="font-size:16px;font-weight:700;color:#0f3460;">' + result.id + '</div>' +
        '</div>' +
        '<div style="background:#eef2ff;border-radius:8px;padding:12px;">' +
          '<div style="font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;margin-bottom:4px;">THITO Case Number</div>' +
          '<div style="font-size:16px;font-weight:700;color:#0f3460;">' + bcpRef + '</div>' +
        '</div>' +
        '<div style="background:#f9fafb;border-radius:8px;padding:12px;grid-column:1/-1;">' +
          '<div style="font-size:11px;font-weight:600;color:#6b7280;text-transform:uppercase;margin-bottom:4px;">THITO Case Status</div>' +
          '<div style="font-size:13.5px;font-weight:600;color:#374151;">' + bcpStatus + '</div>' +
        '</div>' +
      '</div>' +
      '<p style="font-size:13px;color:#374151;text-align:center;">Click <strong>Continue with Acceptance</strong> to review and accept this case, or <strong>Close</strong> to register another case.</p>';
    document.getElementById('successOverlay').classList.add('open');
  }

  function closeSuccessAndReset() {
    document.getElementById('successOverlay').classList.remove('open');
    resetForm();
    refreshNextId();
  }

  function goToAcceptance() {
    window.location.href = '/case-acceptance?openCase=' + _lastRegisteredId;
  }

  /* â"€â"€ Button handlers â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€ */
  async function handleSubmit() {
    if (!validate()) { showAlert('error', 'Please fill all required fields.'); return; }

    // Policy status validation: if ID No. is provided, an Active policy must be selected
    const idNoVal = document.getElementById('idNo').value.trim();
    if (idNoVal) {
      if (!_selectedPolicy) {
        showAlert('error', 'Please fetch and select a policy before submitting.');
        document.getElementById('idNo').focus();
        return;
      }
      const status = (_selectedPolicy.status || '').toLowerCase();
      if (status !== 'active' && status !== 'inforce') {
        showAlert('error',
          `Registration is not allowed. The selected policy (${_selectedPolicy.number}) ` +
          `has status "${_selectedPolicy.status}". Only Active policies are eligible.`);
        return;
      }
    }

    const btn = document.getElementById('btnSubmit');
    const origHTML = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="animation:spin 1s linear infinite;vertical-align:middle;margin-right:6px;"><path d="M21 12a9 9 0 11-6.219-8.56"/></svg>Submitting...';

    try {
      const result = await API.registerClaim(buildPayload());

      if (_stagedDocs.length > 0) {
        UI.toast('Uploading documents...', 'info');
        await uploadStagedDocs(result.id);
      }

      _stagedDocs = [];
      renderDocList();
      showSuccessModal(result);
    } catch (err) {
      showAlert('error', err.message);
    } finally {
      btn.disabled = false;
      btn.innerHTML = origHTML;
    }
  }

  /* ── Document staging ─────────────────────────────────────────────── */

  function checkDocTypeAndBrowse() {
    const docType = document.getElementById('docTypeSelect').value;
    if (!docType) {
      document.getElementById('docTypeSelect').style.borderColor = '#ef4444';
      UI.toast('Please select a document type before choosing a file.', 'warning');
      document.getElementById('docTypeSelect').focus();
      return;
    }
    document.getElementById('docTypeSelect').style.borderColor = '';
    document.getElementById('docFileInput').click();
  }

  function stageFile(input) {
    const file = input.files[0];
    if (!file) return;
    const docType = document.getElementById('docTypeSelect').value;
    if (!docType) {
      UI.toast('Please select a document type first.', 'warning');
      input.value = '';
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      UI.toast('File exceeds 10 MB limit.', 'error');
      input.value = '';
      return;
    }
    _stagedDocs.push({ file, docType, uid: Date.now() + '_' + Math.floor(Math.random() * 9999) });
    input.value = '';
    document.getElementById('docTypeSelect').value = '';
    renderDocList();
  }

  function removeDoc(uid) {
    _stagedDocs = _stagedDocs.filter(d => d.uid !== uid);
    renderDocList();
  }

  function fmtFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  function renderDocList() {
    const list  = document.getElementById('docList');
    const badge = document.getElementById('docCountBadge');
    if (_stagedDocs.length === 0) {
      badge.style.display = 'none';
      list.innerHTML =
        '<div style="text-align:center;color:#9ca3af;font-size:13px;padding:18px 0;' +
        'border:1px dashed #e5e7eb;border-radius:8px;">' +
        'No documents added yet. Select a type and click Browse &amp; Add.</div>';
      return;
    }
    const n = _stagedDocs.length;
    badge.textContent   = n + ' document' + (n > 1 ? 's' : '') + ' staged';
    badge.style.display = 'inline-block';
    const typeColor = {
      'Death Certificate': '#ef4444',
      'Registration Form': '#3b82f6',
      'ID Proof':          '#f59e0b',
      'Bank Proof':        '#10b981',
      'Other':             '#6b7280'
    };
    const rows = _stagedDocs.map(d => {
      const color = typeColor[d.docType] || '#6b7280';
      return '<tr id="docrow_' + d.uid + '">' +
        '<td><span style="display:inline-block;padding:2px 10px;border-radius:10px;font-size:11.5px;' +
        'font-weight:600;background:' + color + '22;color:' + color + ';">' + d.docType + '</span></td>' +
        '<td style="font-size:13px;max-width:240px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"' +
        ' title="' + d.file.name + '">' + d.file.name + '</td>' +
        '<td style="font-size:12.5px;color:#6b7280;">' + fmtFileSize(d.file.size) + '</td>' +
        '<td id="docstatus_' + d.uid + '">' +
        '<span style="font-size:12px;color:#6b7280;font-style:italic;">Pending upload</span></td>' +
        '<td><button type="button" onclick="removeDoc(\'' + d.uid + '\')"' +
        ' style="background:none;border:none;cursor:pointer;color:#ef4444;font-size:17px;' +
        'line-height:1;padding:2px 6px;" title="Remove">&#10005;</button></td>' +
        '</tr>';
    }).join('');
    list.innerHTML =
      '<div class="table-wrapper">' +
      '<table><thead><tr>' +
      '<th>Document Type</th><th>File Name</th>' +
      '<th>Size</th><th>Status</th><th style="width:40px;"></th>' +
      '</tr></thead><tbody>' + rows + '</tbody></table></div>';
  }

  async function uploadStagedDocs(claimId) {
    for (const staged of _stagedDocs) {
      const statusEl = document.getElementById('docstatus_' + staged.uid);
      if (statusEl) statusEl.innerHTML =
        '<span style="color:#f59e0b;font-size:12px;">Uploading...</span>';
      try {
        const fd = new FormData();
        fd.append('claimId', claimId);
        fd.append('docType', staged.docType);
        fd.append('file', staged.file);
        const res  = await fetch('/api/documents/upload', { method: 'POST', body: fd });
        const data = await res.json();
        if (res.ok && data.success) {
          if (statusEl) statusEl.innerHTML =
            '<span style="color:#10b981;font-size:12px;font-weight:600;">&#10003; Uploaded</span>';
        } else {
          if (statusEl) statusEl.innerHTML =
            '<span style="color:#ef4444;font-size:12px;">Failed: ' + (data.message || 'Error') + '</span>';
        }
      } catch (e) {
        if (statusEl) statusEl.innerHTML =
          '<span style="color:#ef4444;font-size:12px;">Upload failed</span>';
      }
    }
  }

  async function handlePend() {
    if (!document.getElementById('lifeAssuredName').value.trim()) {
      showAlert('error', 'Life Assured Name is required to save as pending.');
      return;
    }
    const payload = buildPayload();
    payload.pendingStatus = payload.pendingStatus || 'Pending â€" Incomplete';
    try {
      const result = await API.registerClaim(payload);
      UI.toast(`Case ${result.id} saved as pending.`, 'info');
      showAlert('success', `Case ${result.id} saved as pending.`);
      refreshNextId();
    } catch (err) { showAlert('error', err.message); }
  }

  function handleQueryComments() {
    const hist    = document.getElementById('commentsHistory');
    const general = document.getElementById('generalComments').value.trim();
    if (!general) { UI.toast('Enter a comment first.', 'error'); return; }
    const ts = new Date().toLocaleString('en-US', { dateStyle:'medium', timeStyle:'short' });
    hist.value = (hist.value ? hist.value + '\n\n' : '') + `[${ts}] ${general}`;
    document.getElementById('generalComments').value = '';
    UI.toast('Comment added to history.', 'success');
  }

  function handleExit() {
    if (confirm('Exit registration? Unsaved data will be lost.')) {
      window.location.href = '/dashboard';
    }
  }

  function resetForm() {
    ['lifeAssuredName','idNo','reporterName','mobilePhone','contactNumber',
     'emailAddress','addr1','addr2','addr3','addr4','postalCode',
     'pendingStatus','generalComments','commentsHistory'].forEach(id => {
      document.getElementById(id).value = '';
    });
    ['gender','idType','claimType','claimNature','caseClassification',
     'claimOfficer'].forEach(id => { document.getElementById(id).value = ''; });
    document.getElementById('relation').value  = 'Self';
    document.getElementById('reportVia').value = 'Post / Mail';
    document.getElementById('smsConsent').value= 'Yes';
    document.getElementById('polIndividual').checked = true;
    document.getElementById('polGroup').checked  = false;
    document.getElementById('polBanca').checked  = false;
    document.querySelectorAll('.err').forEach(el => el.classList.remove('err'));
    document.querySelectorAll('.errmsg.show').forEach(el => el.classList.remove('show'));
    document.getElementById('pageAlert').className = '';
    clearSelectedPolicy();
    _stagedDocs = [];
    renderDocList();
    document.getElementById('docTypeSelect').value = '';
  }

  /* ── Policy Lookup ─────────────────────────────────────────────────── */

  async function fetchPolicies() {
    const idNo = document.getElementById('idNo').value.trim();
    if (!idNo) {
      UI.toast('Please enter an ID No. in Insured Information first.', 'warning');
      document.getElementById('idNo').focus();
      return;
    }

    const btn     = document.getElementById('btnFetchPolicies');
    const results = document.getElementById('policyResults');

    UI.setLoading(btn, true);
    results.innerHTML =
      '<div style="display:flex;align-items:center;gap:10px;color:#6b7280;font-size:13px;padding:12px 0;">' +
      '<svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" style="animation:spin 1s linear infinite;">' +
      '<path d="M21 12a9 9 0 11-6.219-8.56"/></svg>Fetching policies for <strong>' + idNo + '</strong>…</div>';

    try {
      const policies = await API.lookupPolicies(idNo);
      renderPolicyTable(policies);
    } catch (err) {
      results.innerHTML =
        '<div style="background:#fff5f5;border:1px solid #fecaca;border-radius:8px;padding:12px 16px;font-size:13px;color:#991b1b;">' +
        '<strong>Error:</strong> ' + err.message + '</div>';
    } finally {
      UI.setLoading(btn, false);
    }
  }

  function renderPolicyTable(policies) {
    const badge   = document.getElementById('policyBadge');
    const results = document.getElementById('policyResults');

    if (!policies || policies.length === 0) {
      badge.style.display = 'none';
      results.innerHTML =
        '<div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:16px;' +
        'text-align:center;color:#6b7280;font-size:13px;">No policies found for this ID number.</div>';
      return;
    }

    badge.textContent  = policies.length + ' policy found';
    badge.style.display = 'inline-block';

    const statusColor = s => ({
      'Active':   '#10b981', 'Inforce': '#10b981',
      'Lapsed':   '#f59e0b',
      'Paid-Up':  '#3b82f6',
      'Cancelled':'#ef4444', 'Void':   '#ef4444'
    }[s] || '#6b7280');

    const isSelectable = s => s === 'Active' || s === 'Inforce';

    const rows = policies.map(p => {
      const selectable = isSelectable(p.policyStatus);
      const rowStyle   = selectable ? 'cursor:pointer;' : 'opacity:.6;';
      const rowClick   = selectable
        ? `onclick="selectPolicy('${p.policyNumber}','${escJs(p.policyName)}','${escJs(p.policyHolderName)}','${escJs(p.policyStatus)}')"`
        : '';
      const btnHtml    = selectable
        ? `<button type="button" class="btn btn-outline btn-sm" id="selbtn_${p.policyNumber}"
                onclick="event.stopPropagation();selectPolicy('${p.policyNumber}','${escJs(p.policyName)}','${escJs(p.policyHolderName)}','${escJs(p.policyStatus)}')">
            Select</button>`
        : `<span style="font-size:11.5px;color:#9ca3af;font-style:italic;">Not eligible</span>`;
      return `
      <tr id="polrow_${p.policyNumber}" style="${rowStyle}" ${rowClick}>
        <td class="td-bold">${p.policyNumber}</td>
        <td>${p.policyName}</td>
        <td>${p.policyHolderName}</td>
        <td><span style="display:inline-block;padding:2px 10px;border-radius:10px;font-size:11.5px;font-weight:600;
                  background:${statusColor(p.policyStatus)}22;color:${statusColor(p.policyStatus)};">${p.policyStatus}</span></td>
        <td style="font-weight:600;">P ${p.premium}</td>
        <td class="td-muted">${p.nextDueDate}</td>
        <td><span style="font-size:11.5px;font-weight:600;color:#0f3460;background:#eef2ff;padding:2px 8px;border-radius:8px;">${p.roleType}</span></td>
        <td>${btnHtml}</td>
      </tr>`;
    }).join('');

    results.innerHTML = `
      <div class="table-wrapper" style="margin-top:4px;">
        <table>
          <thead>
            <tr>
              <th>Policy No.</th><th>Policy Name</th><th>Policy Holder</th>
              <th>Status</th><th>Premium (BWP)</th><th>Next Due Date</th>
              <th>Role</th><th style="width:80px;"></th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>`;
  }

  function selectPolicy(number, name, holder, status) {
    /* Highlight selected row */
    document.querySelectorAll('[id^="polrow_"]').forEach(r => {
      r.style.background = '';
      const btn = document.getElementById('selbtn_' + r.id.replace('polrow_',''));
      if (btn) { btn.textContent = 'Select'; btn.classList.remove('btn-primary'); }
    });
    const row = document.getElementById('polrow_' + number);
    if (row) row.style.background = '#eff6ff';
    const selBtn = document.getElementById('selbtn_' + number);
    if (selBtn) { selBtn.textContent = '✓ Selected'; selBtn.classList.add('btn-primary'); }

    _selectedPolicy = { number, name, holder, status };

    /* Show banner */
    const banner = document.getElementById('selectedPolicyBanner');
    document.getElementById('selPolicyNum').textContent  = number;
    document.getElementById('selPolicyName').textContent = name;
    banner.style.display = 'flex';

    /* Pre-fill Life Assured Name if blank */
    const nameEl = document.getElementById('lifeAssuredName');
    if (!nameEl.value.trim() && holder) {
      nameEl.value = holder;
      nameEl.classList.remove('err');
      document.getElementById('e_lifeAssuredName').classList.remove('show');
    }

    UI.toast('Policy ' + number + ' selected.', 'success');
  }

  function clearSelectedPolicy() {
    _selectedPolicy = null;
    document.getElementById('selectedPolicyBanner').style.display = 'none';
    document.getElementById('policyBadge').style.display = 'none';
    document.getElementById('policyResults').innerHTML = '';
  }

  function escJs(s) {
    return (s || '').replace(/\\/g,'\\\\').replace(/'/g,"\\'");
  }
</script>
</body>
</html>

