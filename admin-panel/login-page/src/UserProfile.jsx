import React, { useState } from "react";
import "./UserProfile.css";

const currentUser = {
  name: "Sanuthmi Jayalath",
  initials: "SJ",
  email: "aurixsanu@gmail.com",
  role: "Senior Admin",
  phone: "+94 77 123 4567",
  department: "Platform Operations",
  location: "Colombo, Sri Lanka",
  joined: "January 2023",
  lastLogin: "Today at 9:41 AM",
};

const activityLog = [
  {
    action: "Approved jeweler verification",
    target: "Golden Aura Jewelry",
    time: "2 hours ago",
    type: "approve",
  },
  {
    action: "Resolved dispute",
    target: "DIS-300 — Priya Rajan vs Legacy Jewels",
    time: "5 hours ago",
    type: "resolve",
  },
  {
    action: "Rejected product listing",
    target: "SKU-XX-991 by Orchid Gem House",
    time: "Yesterday",
    type: "reject",
  },
  {
    action: "Added new admin",
    target: "Kavya Mendis (Admin)",
    time: "2 days ago",
    type: "admin",
  },
  {
    action: "Released escrow funds",
    target: "ESC-1041 — $1,200.00",
    time: "3 days ago",
    type: "finance",
  },
  {
    action: "Updated platform settings",
    target: "Commission rate → 3%",
    time: "1 week ago",
    type: "settings",
  },
];

const typeStyle = {
  approve: { bg: "#d1fae5", color: "#059669", label: "AP" },
  resolve: { bg: "#dbeafe", color: "#2563eb", label: "RE" },
  reject: { bg: "#fee2e2", color: "#dc2626", label: "RJ" },
  admin: { bg: "#ede9fe", color: "#7c3aed", label: "AD" },
  finance: { bg: "#fef3c7", color: "#d97706", label: "FN" },
  settings: { bg: "#f3f4f6", color: "#6b7280", label: "ST" },
};

const permissions = [
  "Jeweler verification & approval",
  "Product moderation",
  "Order management",
  "Escrow & finance oversight",
  "Dispute resolution",
  "Admin management",
  "Platform settings",
  "Report generation",
];

const quickLinks = [
  { label: "Manage Admins", page: "admins" },
  { label: "View Disputes", page: "disputes" },
  { label: "Platform Settings", page: "settings" },
];

const tabs = [
  { id: "overview", label: "Overview" },
  { id: "activity", label: "Activity" },
  { id: "security", label: "Security" },
];

const UserProfile = ({ onNavigate }) => {
  const [editing, setEditing] = useState(false);
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({ ...currentUser });
  const [activeTab, setActiveTab] = useState("overview");

  const handleSave = () => {
    setEditing(false);
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  const set = (key, val) => setForm((prev) => ({ ...prev, [key]: val }));

  return (
    <div className="up-page">
      <div className="up-page-header">
        <h1>My Profile</h1>
        <div className="up-header-actions">
          {saved && <span className="up-saved-toast">Profile updated</span>}
          {editing ? (
            <>
              <button
                className="up-cancel-btn"
                onClick={() => setEditing(false)}
              >
                Cancel
              </button>
              <button className="up-save-btn" onClick={handleSave}>
                Save Changes
              </button>
            </>
          ) : (
            <button className="up-edit-btn" onClick={() => setEditing(true)}>
              Edit Profile
            </button>
          )}
        </div>
      </div>

      <div className="up-profile-card">
        <div className="up-profile-banner" />
        <div className="up-profile-body">
          <div className="up-avatar-wrap">
            <div className="up-avatar">{currentUser.initials}</div>
            {editing && (
              <button className="up-avatar-btn" title="Change photo">
                Change
              </button>
            )}
          </div>

          <div className="up-profile-info">
            <div className="up-name-row">
              <h2 className="up-name">{form.name}</h2>
              <span className="up-role-badge">{form.role}</span>
            </div>
            <p className="up-email">{form.email}</p>
            <div className="up-meta-row">
              <span className="up-meta-item">{form.location}</span>
              <span className="up-meta-sep" />
              <span className="up-meta-item">Joined {form.joined}</span>
              <span className="up-meta-sep" />
              <span className="up-meta-item">
                Last login: {currentUser.lastLogin}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="up-tabs-bar">
        {tabs.map((t) => (
          <button
            key={t.id}
            className={`up-tab ${activeTab === t.id ? "active" : ""}`}
            onClick={() => setActiveTab(t.id)}
          >
            {t.label}
          </button>
        ))}
      </div>

      {activeTab === "overview" && (
        <div className="up-two-col">
          <div className="up-card">
            <h3 className="up-card-title">Personal Information</h3>
            <div className="up-form-grid">
              {[
                { label: "Full Name", key: "name" },
                { label: "Email Address", key: "email" },
                { label: "Phone Number", key: "phone" },
                { label: "Location", key: "location" },
                { label: "Department", key: "department" },
              ].map((f) => (
                <div key={f.key} className="up-form-group">
                  <label>{f.label}</label>
                  {editing ? (
                    <input
                      value={form[f.key]}
                      onChange={(e) => set(f.key, e.target.value)}
                      className="up-input"
                    />
                  ) : (
                    <p className="up-field-val">{form[f.key]}</p>
                  )}
                </div>
              ))}
            </div>
          </div>

          <div className="up-card">
            <h3 className="up-card-title">Role &amp; Permissions</h3>
            <div className="up-role-header">
              <div>
                <p className="up-role-name">{form.role}</p>
                <p className="up-role-desc">Full platform access</p>
              </div>
            </div>
            <div className="up-permissions-list">
              {permissions.map((p, i) => (
                <div key={i} className="up-permission-item">
                  <span className="up-permission-check" />
                  {p}
                </div>
              ))}
            </div>

            <h3 className="up-card-title up-card-title-gap">
              Quick Navigation
            </h3>
            <div className="up-quick-links">
              {quickLinks.map((link) => (
                <button
                  key={link.page}
                  className="up-quick-link"
                  onClick={() => onNavigate(link.page)}
                >
                  {link.label}
                  <span className="up-ql-arrow">›</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {activeTab === "activity" && (
        <div className="up-card">
          <h3 className="up-card-title">Recent Activity</h3>
          <div className="up-activity-list">
            {activityLog.map((log, i) => (
              <div key={i} className="up-activity-row">
                <div className="up-activity-body">
                  <p className="up-activity-action">{log.action}</p>
                  <p className="up-activity-target">{log.target}</p>
                </div>
                <span className="up-activity-time">{log.time}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === "security" && (
        <div className="up-two-col">
          <div className="up-card">
            <h3 className="up-card-title">Change Password</h3>
            <div className="up-form-grid up-form-grid-1">
              {["Current Password", "New Password", "Confirm New Password"].map(
                (lbl, i) => (
                  <div key={i} className="up-form-group">
                    <label>{lbl}</label>
                    <input
                      type="password"
                      placeholder="••••••••"
                      className="up-input"
                    />
                  </div>
                ),
              )}
            </div>
            <div className="up-password-strength">
              <p className="up-strength-label">Strength</p>
              <div className="up-strength-bars">
                <div className="up-bar filled" />
                <div className="up-bar filled" />
                <div className="up-bar filled" />
                <div className="up-bar" />
              </div>
              <span className="up-strength-text">Good</span>
            </div>
            <button className="up-save-btn up-mt">Update Password</button>
          </div>

          <div className="up-card">
            <h3 className="up-card-title">Two-Factor Authentication</h3>
            <div className="up-2fa-block">
              <div className="up-2fa-icon-wrap">
                <span className="up-2fa-label">2FA</span>
              </div>
              <p className="up-2fa-status">
                2FA is <strong>not enabled</strong>
              </p>
              <p className="up-2fa-desc">
                Add an extra layer of security. Once enabled, you'll enter a
                code from your authenticator app each time you sign in.
              </p>
              <button className="up-save-btn">Enable 2FA</button>
            </div>

            <h3 className="up-card-title up-card-title-gap">Active Sessions</h3>
            {[
              {
                device: "Chrome — Windows 11",
                location: "Colombo, LK",
                status: "Current session",
                current: true,
              },
            ].map((s, i) => (
              <div key={i} className="up-session-row">
                <div className="up-session-info">
                  <p className="up-session-device">{s.device}</p>
                  <p className="up-session-meta">
                    {s.location} · {s.status}
                  </p>
                </div>
                {s.current ? (
                  <span className="up-current-badge">Active</span>
                ) : (
                  <button className="up-revoke-btn">Revoke</button>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default UserProfile;
