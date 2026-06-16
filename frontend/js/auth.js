/**
 * auth.js — Login / Signup page logic
 * No backend auth — UI only
 */

// ─── Tab switching ───────────────────────────────────
document.querySelectorAll('.auth-tab').forEach(tab => {
  tab.addEventListener('click', () => {
    const target = tab.dataset.tab;

    // Update tabs
    document.querySelectorAll('.auth-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');

    // Update forms
    document.querySelectorAll('.auth-form').forEach(f => f.classList.remove('active'));
    document.getElementById(`${target}-form`).classList.add('active');
  });
});

// ─── Login handler ───────────────────────────────────
function handleLogin(e) {
  e.preventDefault();

  const username = e.target.querySelector('input[type="text"]').value.trim();
  const btn = e.target.querySelector('button[type="submit"]');

  // Simulate loading
  btn.disabled = true;
  btn.innerHTML = `<div class="btn-spinner" style="display:inline-block;margin:0 auto;border-color:rgba(0,0,0,0.2);border-top-color:#0a0e1a;width:16px;height:16px;border-width:2px;border-style:solid;border-radius:50%;animation:spin 0.7s linear infinite;"></div>`;

  setTimeout(() => {
    // Store username for dashboard
    sessionStorage.setItem('crUser', username || 'User');
    // Redirect to dashboard
    window.location.href = "dashboard.html";
  }, 800);
}

// ─── Signup handler ──────────────────────────────────
function handleSignup(e) {
  e.preventDefault();

  const username = e.target.querySelector('input[placeholder="Choose a username"]').value.trim();
  const btn = e.target.querySelector('button[type="submit"]');

  btn.disabled = true;
  btn.innerHTML = `<div class="btn-spinner" style="display:inline-block;margin:0 auto;border-color:rgba(0,0,0,0.2);border-top-color:#0a0e1a;width:16px;height:16px;border-width:2px;border-style:solid;border-radius:50%;animation:spin 0.7s linear infinite;"></div>`;

  setTimeout(() => {
    sessionStorage.setItem('crUser', username || 'User');
    window.location.href = "dashboard.html";
  }, 900);
}
