/**
 * api.js — UI layer for HTTP calls only.
 * No business logic. Calls Java REST endpoints and returns parsed responses.
 */
const API = {

    BASE: '/api',

    /* ── Internal fetch wrapper ──────────────────────────────────── */
    async _request(method, path, body) {
        const opts = {
            method,
            headers: { 'Content-Type': 'application/json' },
            credentials: 'same-origin'
        };
        if (body !== undefined) opts.body = JSON.stringify(body);

        const res = await fetch(this.BASE + path, opts);
        const json = await res.json();

        if (!res.ok || !json.success) {
            const msg = json.message || 'An error occurred';
            throw new Error(msg);
        }
        return json.data;
    },

    _get(path)              { return this._request('GET',    path); },
    _post(path, body)       { return this._request('POST',   path, body); },
    _put(path, body = {})   { return this._request('PUT',    path, body); },

    /* ── Auth ────────────────────────────────────────────────────── */
    login(email, password)  { return this._post('/auth/login',  { email, password }); },
    logout()                { return this._post('/auth/logout', {}); },
    getCurrentUser()        { return this._get('/auth/me'); },

    /* ── Claims ──────────────────────────────────────────────────── */
    getClaims(params = {}) {
        const qs = new URLSearchParams(
            Object.fromEntries(Object.entries(params).filter(([, v]) => v))
        ).toString();
        return this._get('/claims' + (qs ? '?' + qs : ''));
    },

    getStats()              { return this._get('/claims/stats'); },
    getClaim(id)            { return this._get(`/claims/${id}`); },
    registerClaim(data)     { return this._post('/claims', data); },

    /* ── Acceptance ──────────────────────────────────────────────── */
    acceptClaim(id, notes)  { return this._put(`/claims/${id}/accept`,  { notes }); },
    rejectClaim(id, notes)  { return this._put(`/claims/${id}/reject`,  { notes }); },

    /* ── Evaluation ──────────────────────────────────────────────── */
    startEvaluation(id)     { return this._put(`/claims/${id}/start-evaluation`); },

    evaluateClaim(id, evaluatedAmount, riskLevel, evaluationNotes, recommendation) {
        return this._put(`/claims/${id}/evaluate`, {
            evaluatedAmount, riskLevel, evaluationNotes, recommendation
        });
    },

    /* ── Approval ────────────────────────────────────────────────── */
    approveClaim(id, approvedAmount, notes) {
        return this._put(`/claims/${id}/approve`, { approvedAmount, notes });
    },
    denyClaim(id, notes)    { return this._put(`/claims/${id}/deny`, { notes }); },

    /* ── Policy lookup ───────────────────────────────────────────────── */
    lookupPolicies(idNumber) {
        return this._get(`/policies/lookup?idNumber=${encodeURIComponent(idNumber)}`);
    },

    /* ── Lookup values ───────────────────────────────────────────────── */
    getLookupValues(category) {
        return this._get(`/lookup/${encodeURIComponent(category)}`);
    }
};
