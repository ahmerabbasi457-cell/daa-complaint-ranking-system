/**
 * dashboard.js — Main dashboard controller
 * Handles: complaint submission, top-K rendering,
 *          filters, stats, sidebar nav, backend status
 */

// ─── State ───────────────────────────────────────────
let allComplaints = [];   // raw data from backend
let maxScore = 1;         // for score bar normalization
const likedSet = new Set(); // complaint IDs the user has liked this session

// ─── Init ────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initUser();
  initClock();
  initCharCounters();
  initSidebarNav();
  checkBackendStatus();
  loadComplaints();
});

// ─── User ─────────────────────────────────────────────
function initUser() {
  const name = sessionStorage.getItem('crUser') || 'User';
  document.getElementById('user-name-display').textContent = name;
  document.getElementById('user-avatar').textContent = name[0].toUpperCase();
}

function logout() {
  sessionStorage.removeItem('crUser');
  window.location.href = '../index.html';
}

// ─── Clock ────────────────────────────────────────────
function initClock() {
  function tick() {
    const now = new Date();
    document.getElementById('topbar-time').textContent =
      now.toLocaleTimeString('en-PK', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  }
  tick();
  setInterval(tick, 1000);
}

// ─── Backend Status ───────────────────────────────────
async function checkBackendStatus() {
  const dot  = document.querySelector('.status-dot');
  const text = document.querySelector('.status-text');

  const online = await API.ping();

  if (online) {
    dot.classList.add('online');
    dot.classList.remove('offline');
    text.textContent = 'Backend Online';
  } else {
    dot.classList.add('offline');
    dot.classList.remove('online');
    text.textContent = 'Backend Offline';
  }
}

// Re-check every 30 seconds
setInterval(checkBackendStatus, 30_000);

// ─── Sidebar Navigation ───────────────────────────────
function initSidebarNav() {
  const navItems = document.querySelectorAll('.nav-item');

  navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      // Smooth scroll is handled by href="#...", just update active class
      navItems.forEach(n => n.classList.remove('active'));
      item.classList.add('active');
    });
  });

  // Update active nav on scroll
  const sections = ['submit-section', 'complaints-section', 'algorithm-section'];
  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id.replace('-section', '');
        navItems.forEach(n => {
          n.classList.toggle('active', n.dataset.section === id);
        });
      }
    });
  }, { threshold: 0.3 });

  sections.forEach(id => {
    const el = document.getElementById(id);
    if (el) observer.observe(el);
  });
}

// ─── Character Counters ───────────────────────────────
function initCharCounters() {
  const titleInput = document.getElementById('title');
  const descInput  = document.getElementById('description');

  titleInput?.addEventListener('input', () => {
    document.getElementById('title-count').textContent = `${titleInput.value.length}/100`;
  });

  descInput?.addEventListener('input', () => {
    document.getElementById('desc-count').textContent = `${descInput.value.length}/500`;
  });
}

// ─── Reset Form ───────────────────────────────────────
function resetForm() {
  document.getElementById('complaint-form').reset();
  document.getElementById('title-count').textContent = '0/100';
  document.getElementById('desc-count').textContent  = '0/500';
  hideToast();
}

// ─── Submit Complaint ─────────────────────────────────
async function submitComplaint(e) {
  e.preventDefault();

  const urgencyEl = document.querySelector('input[name="urgency"]:checked');
  if (!urgencyEl) {
    showToast('error', '⚠', 'Please select an urgency level.');
    return;
  }

  const payload = {
    title:       document.getElementById('title').value.trim(),
    description: document.getElementById('description').value.trim(),
    category:    document.getElementById('category').value,
    urgency:     urgencyEl.value,
    location:    document.getElementById('location').value.trim()
  };

  // Loading state
  const btn    = document.getElementById('submit-btn');
  const text   = document.getElementById('submit-text');
  const spinner = document.getElementById('submit-spinner');

  btn.disabled = true;
  text.textContent = 'Submitting...';
  spinner.classList.remove('hidden');
  hideToast();

  try {
    await API.submitComplaint(payload);

    showToast('success', '✓', `"${payload.title}" submitted successfully! Rankings updating...`);
    document.getElementById('complaint-form').reset();
    document.getElementById('title-count').textContent = '0/100';
    document.getElementById('desc-count').textContent  = '0/500';

    // Auto-reload rankings after short delay
    setTimeout(() => loadComplaints(), 1200);

  } catch (err) {
    showToast('error', '✕', `Submission failed: ${err.message}`);
  } finally {
    btn.disabled = false;
    text.textContent = 'Submit Complaint';
    spinner.classList.add('hidden');
  }
}

// ─── Load Complaints ──────────────────────────────────
async function loadComplaints() {
  const grid      = document.getElementById('complaints-grid');
  const loading   = document.getElementById('loading-state');
  const emptyState = document.getElementById('empty-state');
  const refreshIcon = document.getElementById('refresh-icon');

  // Spin the refresh icon
  refreshIcon.classList.add('spinning');
  setTimeout(() => refreshIcon.classList.remove('spinning'), 600);

  // Show loading
  grid.innerHTML = '';
  loading.style.display = 'flex';
  emptyState.classList.add('hidden');

  try {
    const data = await API.getComplaints();
    allComplaints = data.complaints || [];

    loading.style.display = 'none';

    if (allComplaints.length === 0) {
      emptyState.classList.remove('hidden');
      updateStats([]);
      return;
    }

    // Compute max score for bar scaling
    maxScore = Math.max(...allComplaints.map(c => c.score || 0), 1);

    updateStats(allComplaints);
    applyFilters();

  } catch (err) {
    loading.style.display = 'none';
    grid.innerHTML = `
      <div class="loading-state">
        <span style="font-size:2rem">⚠️</span>
        <p>Could not reach backend: <strong>${err.message}</strong></p>
        <p style="font-size:0.78rem;margin-top:4px;">Make sure Flask is running on <code>localhost:5000</code></p>
      </div>`;
    checkBackendStatus();
  }
}

// ─── Filter & Render ──────────────────────────────────
function applyFilters() {
  const urgency  = document.getElementById('filter-urgency').value;
  const category = document.getElementById('filter-category').value;

  let filtered = [...allComplaints];

  if (urgency)  filtered = filtered.filter(c => c.urgency  === urgency);
  if (category) filtered = filtered.filter(c => c.category === category);

  renderComplaints(filtered);
}

function renderComplaints(complaints) {
  const grid = document.getElementById('complaints-grid');
  const empty = document.getElementById('empty-state');

  grid.innerHTML = '';

  if (complaints.length === 0) {
    empty.classList.remove('hidden');
    return;
  }

  empty.classList.add('hidden');

  complaints.forEach((c, index) => {
    const card = buildCard(c, index + 1);
    grid.appendChild(card);
  });
}

// ─── Card Builder ─────────────────────────────────────
function buildCard(c, rank) {
  const card = document.createElement('div');
  const urgencyClass = `urgency-${(c.urgency || 'low').toLowerCase()}`;
  card.className = `complaint-card ${urgencyClass}`;
  card.style.animationDelay = `${(rank - 1) * 60}ms`;

  const rankMedal = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : '';
  const score     = typeof c.score === 'number' ? c.score.toFixed(2) : '—';
  const barWidth  = c.score ? Math.min((c.score / maxScore) * 100, 100).toFixed(1) : 0;
  const ago       = c.created_at ? formatTime(c.created_at) : '';
  const likes     = c.likes ?? 0;
  const liked     = likedSet.has(c.id);

  card.innerHTML = `
    ${rankMedal ? `<div class="card-rank">${rankMedal}</div>` : ''}

    <div class="card-header">
      <div class="card-num">#${rank}</div>
      <div class="card-title">${escHtml(c.title || 'Untitled')}</div>
    </div>

    <div class="card-description">${escHtml(c.description || 'No description provided.')}</div>

    <div class="card-score-row">
      <div>
        <span class="score-label">Dynamic Score</span>
      </div>
      <div class="score-bar-wrap">
        <div class="score-bar" style="width:${barWidth}%"></div>
      </div>
      <span class="score-value">${score}</span>
    </div>

    <div class="card-footer">
      <div class="card-meta">
        <span class="meta-tag ${urgencyClass}">
          ${urgencyIcon(c.urgency)} ${c.urgency || 'Unknown'}
        </span>
        <span class="meta-tag">
          🗂 ${escHtml(c.category || 'Uncategorized')}
        </span>
        <span class="meta-tag">
          📍 ${escHtml(c.location || 'N/A')}
        </span>
        ${ago ? `<span class="meta-tag">🕐 ${ago}</span>` : ''}
      </div>

      <button
        class="like-btn${liked ? ' liked' : ''}"
        data-id="${c.id}"
        aria-label="Like this complaint"
        title="${liked ? 'Already liked' : 'Like this complaint'}"
      >
        <span class="like-icon">👍</span>
        <span class="like-count" data-id="${c.id}">${likes}</span>
      </button>
    </div>
  `;

  // Attach click handler directly — avoids inline onclick + escaping issues
  card.querySelector('.like-btn').addEventListener('click', () => handleLike(c.id));

  return card;
}

// ─── Like Handler ─────────────────────────────────────
async function handleLike(id) {
  const btn       = document.querySelector(`.like-btn[data-id="${id}"]`);
  const countEl   = document.querySelector(`.like-count[data-id="${id}"]`);
  if (!btn || btn.classList.contains('like-loading')) return;

  // Optimistic UI update
  const prevCount  = parseInt(countEl.textContent, 10) || 0;
  const alreadyLiked = likedSet.has(id);

  btn.classList.add('like-loading');
  btn.disabled = true;

  // Instant count bump + animation before server confirms
  if (!alreadyLiked) {
    countEl.textContent = prevCount + 1;
    countEl.classList.add('like-pop');
    btn.classList.add('liked');
    setTimeout(() => countEl.classList.remove('like-pop'), 400);
  }

  try {
    await API.likeComplaint(id);
    likedSet.add(id);

    // Silently refresh rankings in background — no spinner, no flash
    const data = await API.getComplaints();
    allComplaints = data.complaints || [];
    maxScore = Math.max(...allComplaints.map(c => c.score || 0), 1);
    updateStats(allComplaints);
    applyFilters();   // re-renders cards; liked state preserved via likedSet

  } catch (err) {
    // Rollback optimistic update on failure
    if (!alreadyLiked) {
      countEl.textContent = prevCount;
      btn.classList.remove('liked');
    }
    showToast('error', '✕', `Could not like complaint: ${err.message}`);
  } finally {
    btn.classList.remove('like-loading');
    btn.disabled = false;
  }
}

// ─── Update Stats Bar ─────────────────────────────────
function updateStats(complaints) {
  document.getElementById('stat-total').textContent = complaints.length;

  const high = complaints.filter(c => c.urgency === 'High').length;
  document.getElementById('stat-high').textContent = high;

  const top = complaints.length > 0
    ? Math.max(...complaints.map(c => c.score || 0)).toFixed(2)
    : '—';
  document.getElementById('stat-top-score').textContent = top;

  const cats = new Set(complaints.map(c => c.category).filter(Boolean));
  document.getElementById('stat-categories').textContent = cats.size;
}

// ─── Helpers ──────────────────────────────────────────
function urgencyIcon(urgency) {
  const map = { High: '🔴', Medium: '🟡', Low: '🟢' };
  return map[urgency] || '⚪';
}

function escHtml(str) {
  const div = document.createElement('div');
  div.appendChild(document.createTextNode(String(str)));
  return div.innerHTML;
}

function formatTime(timestamp) {
  // timestamp can be Unix seconds or ms
  const ts = timestamp > 1e10 ? timestamp : timestamp * 1000;
  const diff = Date.now() - ts;
  const mins  = Math.floor(diff / 60_000);
  const hours = Math.floor(diff / 3_600_000);
  const days  = Math.floor(diff / 86_400_000);

  if (mins < 1)  return 'just now';
  if (mins < 60) return `${mins}m ago`;
  if (hours < 24) return `${hours}h ago`;
  return `${days}d ago`;
}

// ─── Toast ────────────────────────────────────────────
function showToast(type, icon, msg) {
  const toast = document.getElementById('toast');
  toast.className = `toast ${type}`;
  document.getElementById('toast-icon').textContent = icon;
  document.getElementById('toast-msg').textContent  = msg;
  toast.classList.remove('hidden');

  // Auto-hide after 5s
  clearTimeout(window._toastTimer);
  window._toastTimer = setTimeout(hideToast, 5000);
}

function hideToast() {
  document.getElementById('toast')?.classList.add('hidden');
}
