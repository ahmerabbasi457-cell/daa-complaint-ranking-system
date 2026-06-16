/**
 * admin.js — ComplaintRank Admin Console
 * ----------------------------------------
 * Handles: live data fetch, Top-K table render,
 *          cluster analytics, stat cards,
 *          auto-refresh (5s), filter/search,
 *          backend status, countdown ring
 */

'use strict';

// ══════════════════════════════════════════
// CONFIG
// ══════════════════════════════════════════
const API_BASE        = 'http://127.0.0.1:5000';
const REFRESH_SECS    = 5;
const SPAM_THRESHOLD  = 0.5;   // scores above this are "spam"
const CLUSTER_KEYS    = ['Network', 'Food', 'Education', 'General'];

// Cluster → CSS class map
const CLUSTER_CLASS = {
  Network:   'c-network',
  Food:      'c-food',
  Education: 'c-education',
  General:   'c-general',
  Other:     'c-other',
};

// Cluster → chart bar colour
const CLUSTER_COLOR = {
  Network:   'var(--blue)',
  Food:      'var(--green)',
  Education: 'var(--amber)',
  General:   'var(--violet)',
  Other:     'var(--teal)',
};

// ══════════════════════════════════════════
// STATE
// ══════════════════════════════════════════
let allComplaints  = [];   // raw from backend
let filtered       = [];   // after search/filter
let maxScore       = 1;    // for sparkbar scaling
let prevIds        = new Set(); // for flash-new animation
let refreshTimer   = null;
let countdownVal   = REFRESH_SECS;

// ══════════════════════════════════════════
// INIT
// ══════════════════════════════════════════
document.addEventListener('DOMContentLoaded', () => {
  initClock();
  initClusterGrid();   // render static cluster cards
  bindControls();
  fetchData();
  startRefreshCycle();
});

// ══════════════════════════════════════════
// CLOCK
// ══════════════════════════════════════════
function initClock() {
  const el = document.getElementById('header-clock');
  function tick() {
    el.textContent = new Date().toLocaleTimeString('en-PK', {
      hour: '2-digit', minute: '2-digit', second: '2-digit'
    });
  }
  tick();
  setInterval(tick, 1000);
}

// ══════════════════════════════════════════
// COUNTDOWN RING
// ══════════════════════════════════════════
function startRefreshCycle() {
  clearInterval(refreshTimer);
  countdownVal = REFRESH_SECS;
  updateRing();

  refreshTimer = setInterval(() => {
    countdownVal--;
    updateRing();
    if (countdownVal <= 0) {
      fetchData();
      countdownVal = REFRESH_SECS;
    }
  }, 1000);
}

function updateRing() {
  const ringC = 94.25; // 2π × 15
  const frac  = countdownVal / REFRESH_SECS;
  const offset = ringC * (1 - frac);

  const fill = document.getElementById('ring-fill');
  const cnt  = document.getElementById('refresh-count');
  if (fill) fill.style.strokeDashoffset = offset;
  if (cnt)  cnt.textContent = countdownVal;
}

// ══════════════════════════════════════════
// API FETCH
// ══════════════════════════════════════════
async function fetchData() {
  try {
    const res  = await fetch(`${API_BASE}/get-complaints`, {
      headers: { 'Accept': 'application/json' },
      signal: AbortSignal.timeout(4000),
    });

    if (!res.ok) throw new Error(`HTTP ${res.status}`);

    const data = await res.json();
    allComplaints = data.complaints || [];
    maxScore = Math.max(...allComplaints.map(c => c.score || 0), 1);

    setBackendStatus(true);
    updateStats();
    applyFilters();
    updateClusters();
    updateLastFetch();

  } catch (err) {
    setBackendStatus(false);
    showTableError(err.message);
  }
}

// ══════════════════════════════════════════
// BACKEND STATUS BADGE
// ══════════════════════════════════════════
function setBackendStatus(online) {
  const badge = document.getElementById('backend-badge');
  const label = document.getElementById('badge-label');
  if (!badge || !label) return;

  badge.className = 'backend-badge ' + (online ? 'online' : 'offline');
  label.textContent = online ? 'Backend Online' : 'Backend Offline';
}

// ══════════════════════════════════════════
// STAT CARDS
// ══════════════════════════════════════════
function updateStats() {
  const total = allComplaints.length;
  animateNumber('val-total', total);

  // Spam: derive from score field or mark as spam if score < threshold heuristic
  // We use a computed spam score: complaints with urgency=Low and very low score
  const spamCount = computeSpamCount(allComplaints);
  animateNumber('val-spam', spamCount);

  const spamPct = total > 0 ? (spamCount / total) * 100 : 0;
  const spamBar = document.getElementById('spam-bar');
  if (spamBar) spamBar.style.width = spamPct.toFixed(1) + '%';

  const trendSpam = document.getElementById('trend-total');
  if (trendSpam) trendSpam.textContent = `${total} complaints indexed`;

  // Top ranked
  if (allComplaints.length > 0) {
    const top = allComplaints[0];
    setEl('val-top', (top.score || 0).toFixed(2));
    setEl('val-top-title', truncate(top.title || '—', 28));
  } else {
    setEl('val-top', '—');
    setEl('val-top-title', 'No data');
  }

  // Clusters
  const clusterMap = buildClusterMap(allComplaints);
  const clusterCount = Object.keys(clusterMap).filter(k => clusterMap[k] > 0).length;
  animateNumber('val-clusters', clusterCount);

  const trendCl = document.getElementById('trend-clusters');
  if (trendCl) {
    const cats = [...new Set(allComplaints.map(c => c.category).filter(Boolean))];
    trendCl.textContent = cats.slice(0, 3).join(' · ') || '—';
  }
}

/**
 * Compute spam count heuristically from backend data.
 * If the backend returns a spam_score field, use that.
 * Otherwise, flag complaints with a suspiciously low score
 * relative to their urgency, or duplicate titles.
 */
function computeSpamCount(complaints) {
  if (complaints.length === 0) return 0;

  // If backend supplies spam_score field, use it
  if (complaints[0].spam_score !== undefined) {
    return complaints.filter(c => (c.spam_score || 0) >= SPAM_THRESHOLD).length;
  }

  // Heuristic: flag duplicates (same title) + low-urgency with very low scores
  const seenTitles = new Map();
  let spam = 0;

  for (const c of complaints) {
    const titleKey = (c.title || '').toLowerCase().trim();
    if (seenTitles.has(titleKey)) {
      spam++;
    } else {
      seenTitles.set(titleKey, true);
    }
  }
  return spam;
}

// ══════════════════════════════════════════
// TABLE
// ══════════════════════════════════════════
function bindControls() {
  document.getElementById('table-search')?.addEventListener('input', applyFilters);
  document.getElementById('table-filter-cat')?.addEventListener('change', applyFilters);
}

function applyFilters() {
  const q   = (document.getElementById('table-search')?.value || '').toLowerCase().trim();
  const cat = document.getElementById('table-filter-cat')?.value || '';

  filtered = allComplaints.filter(c => {
    const matchQ   = !q   || (c.title || '').toLowerCase().includes(q) || (c.description || '').toLowerCase().includes(q);
    const matchCat = !cat || (c.category || '') === cat;
    return matchQ && matchCat;
  });

  renderTable(filtered);
}

function renderTable(complaints) {
  const tbody = document.getElementById('complaints-tbody');
  const countLabel = document.getElementById('table-count-label');
  if (!tbody) return;

  if (countLabel) {
    countLabel.textContent = `${complaints.length} complaint${complaints.length !== 1 ? 's' : ''} loaded`;
  }

  if (complaints.length === 0) {
    tbody.innerHTML = `
      <tr class="empty-row">
        <td colspan="6">
          ${allComplaints.length === 0
            ? '📭 &nbsp;No complaints in backend yet. Submit one from the main dashboard.'
            : '🔍 &nbsp;No complaints match your current filter.'}
        </td>
      </tr>`;
    return;
  }

  const currentIds = new Set(complaints.map(c => c.id));

  tbody.innerHTML = '';

  complaints.forEach((c, i) => {
    const rank     = i + 1;
    const isNew    = !prevIds.has(c.id);
    const spamScore   = getSpamScore(c, i);
    const clusterW    = getClusterWeight(c, complaints);
    const finalScore  = c.score || 0;
    const barW        = ((finalScore / maxScore) * 100).toFixed(1);

    const tr = document.createElement('tr');
    if (isNew) tr.classList.add('row-new');

    tr.innerHTML = `
      <td class="td-rank">
        <span class="rank-badge ${rankClass(rank)}">${rankEmoji(rank)}</span>
      </td>
      <td class="td-title">
        <span class="complaint-title" title="${esc(c.title || '')}">${esc(truncate(c.title || 'Untitled', 50))}</span>
        <span class="complaint-id">#${c.id || '—'} · ${timeAgo(c.created_at)}</span>
      </td>
      <td>
        <span class="category-pill">${esc(c.category || 'General')}</span>
      </td>
      <td class="td-spam">
        <span class="num-val spam-val">${spamScore.toFixed(3)}</span>
      </td>
      <td class="td-cluster">
        <span class="num-val cluster-val">${clusterW.toFixed(3)}</span>
      </td>
      <td class="td-score">
        <div class="score-cell">
          <div class="score-sparkbar">
            <div class="score-sparkfill" style="width:${barW}%"></div>
          </div>
          <span class="score-num">${finalScore.toFixed(2)}</span>
        </div>
      </td>`;

    tbody.appendChild(tr);
  });

  prevIds = currentIds;
}

function showTableError(msg) {
  const tbody = document.getElementById('complaints-tbody');
  if (!tbody) return;
  tbody.innerHTML = `
    <tr class="empty-row">
      <td colspan="6">
        ⚠️ &nbsp;Could not reach backend — <strong>${esc(msg)}</strong>.
        Make sure Flask is running on <code>localhost:5000</code>.
      </td>
    </tr>`;
}

// ──── Score derivations ────────────────────
/**
 * Derive spam score per row.
 * Uses backend spam_score if present, otherwise computes heuristic.
 */
function getSpamScore(c, rank) {
  if (c.spam_score !== undefined) return c.spam_score;

  // Heuristic: low-urgency + low rank = low spam probability
  // high-rank complaints with Low urgency = suspicious
  const urgencyW = { High: 0.05, Medium: 0.12, Low: 0.25 }[c.urgency] || 0.15;
  const rankPenalty = rank === 0 ? 0 : Math.min(rank * 0.02, 0.3);
  return Math.max(0, urgencyW + rankPenalty - (c.score || 0) * 0.05);
}

/**
 * Compute cluster weight for this complaint relative to its peers.
 */
function getClusterWeight(c, all) {
  if (c.cluster_weight !== undefined) return c.cluster_weight;

  // Group by category, weight = fraction of same-category items
  const cat = c.category || 'General';
  const sameCount = all.filter(x => (x.category || 'General') === cat).length;
  return sameCount > 0 ? (sameCount / all.length) : 0;
}

// ══════════════════════════════════════════
// CLUSTER ANALYTICS
// ══════════════════════════════════════════
function initClusterGrid() {
  const grid = document.getElementById('cluster-grid');
  if (!grid) return;

  // Pre-render cluster cards for the 4 required + catch-all
  const clusters = [...CLUSTER_KEYS, 'Other'];

  clusters.forEach(name => {
    const cls = CLUSTER_CLASS[name] || 'c-other';
    const card = document.createElement('div');
    card.className = `cluster-card ${cls}`;
    card.id = `clcard-${name}`;
    card.innerHTML = `
      <div class="cluster-card-header">
        <span class="cluster-name">${name}</span>
        <span class="cluster-icon-lbl">${clusterEmoji(name)}</span>
      </div>
      <div class="cluster-count" id="clcount-${name}">—</div>
      <div class="cluster-bar-wrap">
        <div class="cluster-bar-fill" id="clbar-${name}" style="width:0%"></div>
      </div>`;
    grid.appendChild(card);
  });
}

function updateClusters() {
  const clMap = buildClusterMap(allComplaints);
  const total = allComplaints.length || 1;
  const clusters = [...CLUSTER_KEYS, 'Other'];

  clusters.forEach(name => {
    const count = clMap[name] || 0;
    const pct   = ((count / total) * 100).toFixed(1);
    setEl(`clcount-${name}`, count);
    const bar = document.getElementById(`clbar-${name}`);
    if (bar) bar.style.width = pct + '%';
  });

  renderChartBars(clMap, total);
}

function buildClusterMap(complaints) {
  const map = {};
  CLUSTER_KEYS.forEach(k => (map[k] = 0));
  map['Other'] = 0;

  complaints.forEach(c => {
    const cat = c.category || 'General';
    if (CLUSTER_KEYS.includes(cat)) {
      map[cat]++;
    } else {
      map['Other']++;
    }
  });
  return map;
}

function renderChartBars(clMap, total) {
  const wrap = document.getElementById('chart-bars');
  if (!wrap) return;

  const clusters = [...CLUSTER_KEYS, 'Other'];
  const maxCount = Math.max(...clusters.map(k => clMap[k] || 0), 1);

  wrap.innerHTML = '';
  clusters.forEach(name => {
    const count = clMap[name] || 0;
    const heightPct = (count / maxCount) * 100;
    const color = CLUSTER_COLOR[name] || 'var(--teal)';

    const item = document.createElement('div');
    item.className = 'chart-bar-item';
    item.innerHTML = `
      <div class="chart-bar-col" style="height:${heightPct}%;background:${color};opacity:0.8"></div>
      <span class="chart-bar-lbl">${name.slice(0, 3)}<br>${count}</span>`;
    wrap.appendChild(item);
  });
}

// ══════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════
function rankClass(rank) {
  if (rank === 1) return 'gold';
  if (rank === 2) return 'silver';
  if (rank === 3) return 'bronze';
  return '';
}

function rankEmoji(rank) {
  if (rank === 1) return '🥇';
  if (rank === 2) return '🥈';
  if (rank === 3) return '🥉';
  return rank;
}

function clusterEmoji(name) {
  const map = { Network: '📡', Food: '🍔', Education: '📚', General: '🗂', Other: '📌' };
  return map[name] || '⬡';
}

function esc(str) {
  const d = document.createElement('div');
  d.appendChild(document.createTextNode(String(str)));
  return d.innerHTML;
}

function truncate(str, max) {
  return str.length <= max ? str : str.slice(0, max) + '…';
}

function setEl(id, val) {
  const el = document.getElementById(id);
  if (el) el.textContent = val;
}

function timeAgo(ts) {
  if (!ts) return '';
  const stamp = ts > 1e10 ? ts : ts * 1000;
  const diff  = Date.now() - stamp;
  const m = Math.floor(diff / 60_000);
  const h = Math.floor(diff / 3_600_000);
  const d = Math.floor(diff / 86_400_000);
  if (m < 1)  return 'just now';
  if (m < 60) return `${m}m ago`;
  if (h < 24) return `${h}h ago`;
  return `${d}d ago`;
}

function updateLastFetch() {
  const el = document.getElementById('last-fetch');
  if (el) el.textContent = new Date().toLocaleTimeString();
}

function animateNumber(id, target) {
  const el = document.getElementById(id);
  if (!el) return;

  const start = parseInt(el.textContent) || 0;
  const diff  = target - start;
  if (diff === 0) return;

  const steps = 20;
  let step    = 0;
  const timer = setInterval(() => {
    step++;
    const val = Math.round(start + (diff * step / steps));
    el.textContent = val;
    if (step >= steps) {
      clearInterval(timer);
      el.textContent = target;
    }
  }, 20);
}
