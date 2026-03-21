import React, { useState } from "react";
import "./UserProfile.css";

const currentUser = {
  name: "Sanuthmi Jayalath",
  initials: "SJ",
  email: "sanuthmi@aurix.lk",
  role: "Senior Admin",
  phone: "+94 77 123 4567",
  department: "Platform Operations",
  location: "Colombo, Sri Lanka",
  joined: "January 2023",
  lastLogin: "Today at 9:41 AM",
  bio: "Senior platform administrator responsible for jeweler verification, dispute resolution, and overall platform governance.",
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
  approve: { bg: "#d1fae5", color: "#059669" },
  resolve: { bg: "#dbeafe", color: "#2563eb" },
  reject: { bg: "#fee2e2", color: "#dc2626" },
  admin: { bg: "#ede9fe", color: "#7c3aed" },
  finance: { bg: "#fef3c7", color: "#d97706" },
  settings: { bg: "#f3f4f6", color: "#6b7280" },
};

/* ─── SVG icons ─── */
const IcEdit = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
  </svg>
);
const IcCamera = () => (
  <svg
    width="13"
    height="13"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
    <circle cx="12" cy="13" r="4" />
  </svg>
);
const IcPin = () => (
  <svg
    width="13"
    height="13"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
    <circle cx="12" cy="10" r="3" />
  </svg>
);
const IcCalendar = () => (
  <svg
    width="13"
    height="13"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <rect x="3" y="4" width="18" height="18" rx="2" />
    <line x1="16" y1="2" x2="16" y2="6" />
    <line x1="8" y1="2" x2="8" y2="6" />
    <line x1="3" y1="10" x2="21" y2="10" />
  </svg>
);
const IcClock = () => (
  <svg
    width="13"
    height="13"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <circle cx="12" cy="12" r="10" />
    <polyline points="12 6 12 12 16 14" />
  </svg>
);
const IcCheck = () => (
  <svg
    width="10"
    height="10"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2.5"
  >
    <polyline points="20 6 9 17 4 12" />
  </svg>
);
const IcChevron = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <polyline points="9 18 15 12 9 6" />
  </svg>
);
const IcShield = () => (
  <svg
    width="20"
    height="20"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.5"
  >
    <path d="M12 2L3 7v6c0 5.25 3.75 10.15 9 11.25C17.25 23.15 21 18.25 21 13V7l-9-5z" />
  </svg>
);
const IcUser = () => (
  <svg
    width="20"
    height="20"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.5"
  >
    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
    <circle cx="12" cy="7" r="4" />
  </svg>
);
const IcActivity = () => (
  <svg
    width="20"
    height="20"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.5"
  >
    <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
  </svg>
);
const IcApprove = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <polyline points="20 6 9 17 4 12" />
  </svg>
);
const IcResolve = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <circle cx="12" cy="12" r="10" />
    <polyline points="12 6 12 12 16 14" />
  </svg>
);
const IcReject = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <line x1="18" y1="6" x2="6" y2="18" />
    <line x1="6" y1="6" x2="18" y2="18" />
  </svg>
);
const IcAdmin = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
    <circle cx="12" cy="7" r="4" />
  </svg>
);
const IcFinance = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <line x1="12" y1="1" x2="12" y2="23" />
    <path d="M17 5H9.5a3.5 3.5 0 1 0 0 7h5a3.5 3.5 0 1 1 0 7H6" />
  </svg>
);
const IcSettings = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <circle cx="12" cy="12" r="3" />
    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
  </svg>
);
const IcMonitor = () => (
  <svg
    width="16"
    height="16"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <rect x="2" y="3" width="20" height="14" rx="2" />
    <line x1="8" y1="21" x2="16" y2="21" />
    <line x1="12" y1="17" x2="12" y2="21" />
  </svg>
);
const IcLink = () => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
  >
    <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
    <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
  </svg>
);
const IcLock = () => (
  <svg
    width="20"
    height="20"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.5"
  >
    <rect x="3" y="11" width="18" height="11" rx="2" />
    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
  </svg>
);

const typeIcon = {
  approve: <IcApprove />,
  resolve: <IcResolve />,
  reject: <IcReject />,
  admin: <IcAdmin />,
  finance: <IcFinance />,
  settings: <IcSettings />,
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
  { label: "Manage Admins", page: "admins", icon: <IcAdmin /> },
  { label: "View Disputes", page: "disputes", icon: <IcResolve /> },
  { label: "Platform Settings", page: "settings", icon: <IcSettings /> },
];

const tabs = [
  { id: "overview", label: "Overview", icon: <IcUser /> },
  { id: "activity", label: "Activity", icon: <IcActivity /> },
  { id: "security", label: "Security", icon: <IcShield /> },
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
      {/* Page header */}
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
              <IcEdit /> Edit Profile
            </button>
          )}
        </div>
      </div>

      {/* Profile card */}
      <div className="up-profile-card">
        <div className="up-profile-banner" />
        <div className="up-profile-body">
          <div className="up-avatar-wrap">
            <div className="up-avatar">{currentUser.initials}</div>
            {editing && (
              <button className="up-avatar-btn" title="Change photo">
                <IcCamera />
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
              <span className="up-meta-item">
                <IcPin />
                {form.location}
              </span>
              <span className="up-meta-item">
                <IcCalendar />
                Joined {form.joined}
              </span>
              <span className="up-meta-item">
                <IcClock />
                Last login: {currentUser.lastLogin}
              </span>
            </div>
          </div>

          <div className="up-stats-strip">
            {[
              { label: "Actions Today", value: "12" },
              { label: "This Month", value: "248" },
              { label: "Disputes Resolved", value: "34" },
              { label: "Jewelers Verified", value: "87" },
            ].map((s, i) => (
              <div key={i} className="up-stat">
                <span className="up-stat-value">{s.value}</span>
                <span className="up-stat-label">{s.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="up-tabs-bar">
        {tabs.map((t) => (
          <button
            key={t.id}
            className={`up-tab ${activeTab === t.id ? "active" : ""}`}
            onClick={() => setActiveTab(t.id)}
          >
            {t.icon}
            {t.label}
          </button>
        ))}
      </div>

      {/* ── Overview ── */}
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
              <div className="up-form-group up-form-full">
                <label>Bio</label>
                {editing ? (
                  <textarea
                    rows={3}
                    value={form.bio}
                    onChange={(e) => set("bio", e.target.value)}
                    className="up-input up-textarea"
                  />
                ) : (
                  <p className="up-field-val">{form.bio}</p>
                )}
              </div>
            </div>
          </div>

          <div className="up-card">
            <h3 className="up-card-title">Role & Permissions</h3>
            <div className="up-role-header">
              <div className="up-role-icon-wrap">
                <IcShield />
              </div>
              <div>
                <p className="up-role-name">{form.role}</p>
                <p className="up-role-desc">Full platform access</p>
              </div>
            </div>
            <div className="up-permissions-list">
              {permissions.map((p, i) => (
                <div key={i} className="up-permission-item">
                  <span className="up-permission-check">
                    <IcCheck />
                  </span>
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
                  <span className="up-ql-icon">{link.icon}</span>
                  {link.label}
                  <IcChevron />
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* ── Activity ── */}
      {activeTab === "activity" && (
        <div className="up-card">
          <h3 className="up-card-title">Recent Activity</h3>
          <div className="up-activity-list">
            {activityLog.map((log, i) => {
              const s = typeStyle[log.type];
              return (
                <div key={i} className="up-activity-row">
                  <div
                    className="up-activity-icon"
                    style={{ background: s.bg, color: s.color }}
                  >
                    {typeIcon[log.type]}
                  </div>
                  <div className="up-activity-body">
                    <p className="up-activity-action">{log.action}</p>
                    <p className="up-activity-target">{log.target}</p>
                  </div>
                  <span className="up-activity-time">{log.time}</span>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* ── Security ── */}
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
                <IcLock />
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
              {
                device: "Safari — iPhone 14",
                location: "Colombo, LK",
                status: "2 days ago",
                current: false,
              },
            ].map((s, i) => (
              <div key={i} className="up-session-row">
                <div className="up-session-icon-wrap">
                  <IcMonitor />
                </div>
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
