/**
 * api.js — Backend API interface
 * All fetch calls to Flask backend at localhost:5000
 */

const API_BASE = 'http://127.0.0.1:5000';

const API = {
  /**
   * Submit a new complaint
   * POST /submit-complaint
   * @param {Object} complaint - { title, description, category, urgency, location }
   * @returns {Promise<Object>}
   */
  async submitComplaint(complaint) {
    const res = await fetch(`${API_BASE}/submit-complaint`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(complaint)
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || `Server error: ${res.status}`);
    }

    return res.json();
  },

  /**
   * Get Top-K ranked complaints
   * GET /get-complaints
   * @returns {Promise<Object>} - { complaints: [...] }
   */
  async getComplaints() {
    const res = await fetch(`${API_BASE}/get-complaints`, {
      method: 'GET',
      headers: { 'Accept': 'application/json' }
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || `Server error: ${res.status}`);
    }

    return res.json();
  },

  /**
   * Like a complaint
   * POST /like-complaint/{id}
   * @param {number} id - complaint ID
   * @returns {Promise<Object>}
   */
  async likeComplaint(id) {
    const res = await fetch(`${API_BASE}/like-complaint/${id}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || `Server error: ${res.status}`);
    }

    return res.json();
  },

  /**
   * Health check — test if backend is reachable
   * @returns {Promise<boolean>}
   */
  async ping() {
    try {
      const res = await fetch(`${API_BASE}/get-complaints`, {
        method: 'GET',
        signal: AbortSignal.timeout(3000)
      });
      return res.ok;
    } catch {
      return false;
    }
  }
};
