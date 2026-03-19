import React, { useState } from "react";
import "./AdminManagement.css";

/* ─── Data ─── */
const initialAdmins = [
  {
    id: 1, initials: "SJ", name: "Sanuthmi Jayalath", email: "sanuthmi@aurix.lk",
    role: "Senior Admin", department: "Platform Operations",
    joined: "Jan 2023", lastActive: "Today, 9:41 AM", status: "Active", isCurrent: true,
    permissions: ["jewelers", "products", "orders", "escrow", "disputes", "settings", "admins"],
  },
  {
    id: 2, initials: "KM", name: "Kavya Mendis", email: "kavya@aurix.lk",
    role: "Admin", department: "Verification",
    joined: "Mar 2023", lastActive: "Today, 8:12 AM", status: "Active", isCurrent: false,
    permissions: ["jewelers", "products", "orders"],
  },
  {
    id: 3, initials: "RP", name: "Ruchith Perera", email: "ruchith@aurix.lk",
    role: "Admin", department: "Finance",
    joined: "Jun 2023", lastActive: "Yesterday", status: "Active", isCurrent: false,
    permissions: ["orders", "escrow", "disputes"],
  },
  {
    id: 4, initials: "NW", name: "Nadeesha Wickrama", email: "nadeesha@aurix.lk",
    role: "Junior Admin", department: "Support",
    joined: "Sep 2023", lastActive: "3 days ago", status: "Inactive", isCurrent: false,
    permissions: ["jewelers", "products"],
  },
];

const roleMeta = {
  "Senior Admin": { dot: "#D4AF37", color: "#92680a", border: "#fde68a" },
  "Admin":        { dot: "#7c3aed", color: "#5b21b6", border: "#ddd6fe" },
  "Junior Admin": { dot: "#2563eb", color: "#1d4ed8", border: "#bfdbfe" },
};

// Activity: 12 values 0–3 (last 12 weeks, 0=none 1=low 2=mid 3=high)
const adminActivity = {
  1: [3, 3, 2, 3, 3, 2, 3, 3, 2, 3, 3, 3],
  2: [1, 2, 2, 1, 3, 2, 2, 3, 3, 2, 2, 3],
  3: [0, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1],
  4: [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0],
};

const allPermissions = [
  { key: "jewelers", label: "Jeweler Verification", icon: "👤" },
  { key: "products", label: "Product Moderation",   icon: "💎" },
  { key: "orders",   label: "Orders",               icon: "📋" },
  { key: "escrow",   label: "Escrow & Finance",     icon: "💰" },
  { key: "disputes", label: "Dispute Resolution",   icon: "⚠️" },
  { key: "settings", label: "Platform Settings",    icon: "⚙️" },
  { key: "admins",   label: "Admin Management",     icon: "👑" },
];

const departments = [
  "Platform Operations",
  "Verification",
  "Finance",
  "Support",
  "Compliance",
  "Engineering",
  "Marketing",
  "Legal",
];

const countryCodes = [
  { code: "+94",  flag: "🇱🇰" },
  { code: "+1",   flag: "🇺🇸" },
  { code: "+44",  flag: "🇬🇧" },
  { code: "+91",  flag: "🇮🇳" },
  { code: "+61",  flag: "🇦🇺" },
  { code: "+971", flag: "🇦🇪" },
  { code: "+65",  flag: "🇸🇬" },
  { code: "+60",  flag: "🇲🇾" },
];

const ACT_COLORS = ["#f0f0f0", "#d1fae5", "#6ee7b7", "#059669"];

/* ─── Icons ─── */
const IconEdit = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
  </svg>
);

const IconTrash = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <polyline points="3 6 5 6 21 6" />
    <path d="M19 6l-1 14H6L5 6" />
    <path d="M10 11v6M14 11v6" />
    <path d="M9 6V4h6v2" />
  </svg>
);

const IconSearch = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <circle cx="11" cy="11" r="8" />
    <line x1="21" y1="21" x2="16.65" y2="16.65" />
  </svg>
);

const IconPlus = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
    <line x1="12" y1="5" x2="12" y2="19" />
    <line x1="5" y1="12" x2="19" y2="12" />
  </svg>
);

const IconCheck = () => (
  <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="3">
    <polyline points="20 6 9 17 4 12" />
  </svg>
);

const IconX = () => (
  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
    <line x1="18" y1="6" x2="6" y2="18" />
    <line x1="6" y1="6" x2="18" y2="18" />
  </svg>
);

const IconEyeOpen = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
    <circle cx="12" cy="12" r="3" />
  </svg>
);

const IconEyeClosed = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
    <line x1="1" y1="1" x2="23" y2="23" />
  </svg>
);

/* ─── Helpers ─── */
function getStrength(pw) {
  if (!pw) return { score: 0, label: "", color: "#f0f0f0" };
  let score = 0;
  if (pw.length >= 8) score++;
  if (/[A-Z]/.test(pw)) score++;
  if (/[0-9]/.test(pw)) score++;
  if (/[^A-Za-z0-9]/.test(pw)) score++;
  const map = [
    { label: "",       color: "#f0f0f0" },
    { label: "Weak",   color: "#ef4444" },
    { label: "Fair",   color: "#f97316" },
    { label: "Good",   color: "#eab308" },
    { label: "Strong", color: "#16a34a" },
  ];
  return { score, ...map[score] };
}

/* ─── Shared sub-components ─── */
function PasswordField({ label, value, onChange, error, placeholder, hint }) {
  const [show, setShow] = useState(false);
  const strength = getStrength(value);

  return (
    <div className="am-form-group full">
      <label>
        {label}
        {hint && (
          <span style={{ fontWeight: 400, textTransform: "none", color: "#ccc", marginLeft: 6 }}>
            {hint}
          </span>
        )}
      </label>
      <div className="am-pw-wrap">
        <input
          type={show ? "text" : "password"}
          value={value}
          onChange={e => onChange(e.target.value)}
          placeholder={placeholder || "••••••••"}
          className={error ? "error" : ""}
        />
        <button type="button" className="am-pw-eye" onClick={() => setShow(v => !v)}>
          {show ? <IconEyeOpen /> : <IconEyeClosed />}
        </button>
      </div>
      {value && (
        <div className="am-pw-strength">
          <div className="am-pw-strength-bar">
            <div
              className="am-pw-strength-fill"
              style={{ width: `${(strength.score / 4) * 100}%`, background: strength.color }}
            />
          </div>
          {strength.label && (
            <div className="am-pw-strength-label" style={{ color: strength.color }}>
              {strength.label}
            </div>
          )}
        </div>
      )}
      {error && <div className="am-field-error">{error}</div>}
    </div>
  );
}

function PhoneField({ value, phoneCode, onValueChange, onCodeChange, error }) {
  return (
    <div className="am-form-group full">
      <label>
        Phone Number{" "}
        <span style={{ fontWeight: 400, color: "#ccc", textTransform: "none" }}>(optional)</span>
      </label>
      <div className="am-phone-wrap">
        <select className="am-phone-code" value={phoneCode} onChange={e => onCodeChange(e.target.value)}>
          {countryCodes.map(c => (
            <option key={c.code} value={c.code}>{c.flag} {c.code}</option>
          ))}
        </select>
        <input
          className={`am-phone-num${error ? " error" : ""}`}
          type="tel"
          value={value}
          onChange={e => onValueChange(e.target.value.replace(/[^\d\s]/g, ""))}
          placeholder="71 234 5678"
        />
      </div>
      {error && <div className="am-field-error">{error}</div>}
    </div>
  );
}

/* ─── Main Component ─── */
export default function AdminManagement() {
  const [admins, setAdmins]           = useState(initialAdmins);
  const [search, setSearch]           = useState("");
  const [showAdd, setShowAdd]         = useState(false);
  const [editAdmin, setEditAdmin]     = useState(null);
  const [deleteAdmin, setDeleteAdmin] = useState(null);
  const [toast, setToast]             = useState(null);

  const notify = (msg, type = "success") => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 2800);
  };

  const filtered = admins.filter(a => {
    const q = search.toLowerCase();
    return !q
      || a.name.toLowerCase().includes(q)
      || a.email.toLowerCase().includes(q)
      || a.role.toLowerCase().includes(q);
  });

  const handleAdd = (data) => {
    const fullName = `${data.firstName} ${data.lastName}`.trim();
    const initials = `${data.firstName[0]}${data.lastName[0]}`.toUpperCase();
    setAdmins(prev => [...prev, {
      ...data,
      name: fullName,
      id: Date.now(),
      initials,
      isCurrent: false,
      lastActive: "Never",
      joined: new Date().toLocaleDateString("en-US", { month: "short", year: "numeric" }),
    }]);
    setShowAdd(false);
    notify(`${fullName} has been added.`);
  };

  const handleSave = (updated) => {
    setAdmins(prev => prev.map(a => a.id === updated.id ? updated : a));
    setEditAdmin(null);
    notify(`${updated.name}'s profile updated.`);
  };

  const handleDelete = (id) => {
    const a = admins.find(a => a.id === id);
    setAdmins(prev => prev.filter(a => a.id !== id));
    setDeleteAdmin(null);
    setEditAdmin(null);
    notify(`${a.name} has been removed.`);
  };

  return (
    <div className="am">
      {/* Header */}
      <div className="am-header">
        <div>
          <h1>Admin Management</h1>
          <p>Manage administrator accounts and access.</p>
        </div>
        <button className="am-add-btn" onClick={() => setShowAdd(true)}>
          <IconPlus /> Add Admin
        </button>
      </div>

      {/* Stats */}
      <div className="am-stats">
        {[
          { label: "Total Admins",  value: admins.length,                                          cls: ""      },
          { label: "Active",        value: admins.filter(a => a.status === "Active").length,       cls: "green" },
          { label: "Inactive",      value: admins.filter(a => a.status === "Inactive").length,     cls: "red"   },
          { label: "Senior Admins", value: admins.filter(a => a.role === "Senior Admin").length,   cls: "gold"  },
        ].map(s => (
          <div key={s.label} className="am-stat">
            <p className="am-stat-label">{s.label}</p>
            <p className={`am-stat-value ${s.cls}`}>{s.value}</p>
          </div>
        ))}
      </div>

      {/* Search */}
      <div className="am-toolbar">
        <div className="am-search">
          <IconSearch />
          <input
            placeholder="Search by name, email or role…"
            value={search}
            onChange={e => setSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Table */}
      <div className="am-table-wrap">
        <table className="am-table">
          <thead>
            <tr>
              <th>Administrator</th>
              <th>Role</th>
              <th>Department</th>
              <th>Last Login</th>
              <th>Activity</th>
              <th>Status</th>
              <th style={{ textAlign: "right" }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={7}>
                  <div className="am-empty">No admins found.</div>
                </td>
              </tr>
            ) : filtered.map(admin => {
              const rm       = roleMeta[admin.role] || roleMeta["Admin"];
              const activity = adminActivity[admin.id] || Array(12).fill(0);
              const parts    = admin.lastActive.includes(",")
                ? admin.lastActive.split(",").map(s => s.trim())
                : [admin.lastActive, null];

              return (
                <tr key={admin.id}>
                  {/* Administrator */}
                  <td>
                    <div className="am-admin-cell">
                      <div className="am-admin-name-row">
                        <span className="am-admin-name">{admin.name}</span>
                        {admin.isCurrent && <span className="am-you-pill">You</span>}
                      </div>
                      <span className="am-admin-email">{admin.email}</span>
                    </div>
                  </td>

                  {/* Role */}
                  <td>
                    <span className="am-role-chip" style={{ color: rm.color, borderColor: rm.border }}>
                      <span className="am-role-dot" style={{ background: rm.dot }} />
                      {admin.role}
                    </span>
                  </td>

                  {/* Department */}
                  <td><span className="am-meta-text">{admin.department}</span></td>

                  {/* Last Login */}
                  <td>
                    <div className="am-login-cell">
                      <span className="am-login-time">{parts[0]}</span>
                      {parts[1] && <span className="am-login-date">{parts[1]}</span>}
                    </div>
                  </td>

                  {/* Activity */}
                  <td>
                    <div className="am-activity-bar-wrap">
                      <div className="am-activity-bar">
                        {activity.map((v, i) => (
                          <div
                            key={i}
                            className="am-activity-seg"
                            style={{ background: ACT_COLORS[v] }}
                          />
                        ))}
                      </div>
                      <span className="am-activity-label">12w</span>
                    </div>
                  </td>

                  {/* Status */}
                  <td>
                    <span className={`am-status ${admin.status === "Active" ? "active" : "inactive"}`}>
                      {admin.status}
                    </span>
                  </td>

                  {/* Actions */}
                  <td>
                    <div className="am-actions">
                      <button className="am-icon-btn" title="Edit" onClick={() => setEditAdmin(admin)}>
                        <IconEdit />
                      </button>
                      {!admin.isCurrent && (
                        <button
                          className="am-icon-btn danger"
                          title="Remove"
                          onClick={() => setDeleteAdmin(admin)}
                        >
                          <IconTrash />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Modals */}
      {showAdd && (
        <AddModal onClose={() => setShowAdd(false)} onAdd={handleAdd} />
      )}

      {editAdmin && (
        <EditModal
          admin={editAdmin}
          onClose={() => setEditAdmin(null)}
          onSave={handleSave}
          onDelete={() => setDeleteAdmin(editAdmin)}
        />
      )}

      {deleteAdmin && (
        <div className="am-overlay" onClick={() => setDeleteAdmin(null)}>
          <div className="am-modal" onClick={e => e.stopPropagation()}>
            <div className="am-confirm">
              <div className="am-confirm-icon">🗑️</div>
              <h3>Remove Administrator</h3>
              <p>
                Are you sure you want to remove <strong>{deleteAdmin.name}</strong>?
                <br />This action cannot be undone.
              </p>
              <div className="am-confirm-btns">
                <button className="am-btn-cancel" onClick={() => setDeleteAdmin(null)}>Cancel</button>
                <button className="am-btn-delete" onClick={() => handleDelete(deleteAdmin.id)}>Remove</button>
              </div>
            </div>
          </div>
        </div>
      )}

      {toast && (
        <div className={`am-toast ${toast.type}`}>✓ {toast.msg}</div>
      )}
    </div>
  );
}

/* ─── Add Modal ─── */
function AddModal({ onClose, onAdd }) {
  const [form, setForm] = useState({
    firstName: "", lastName: "",
    email: "",
    phone: "", phoneCode: "+94",
    password: "", confirmPassword: "",
    role: "Admin", department: "", status: "Active",
    permissions: ["jewelers", "products"],
  });
  const [errors, setErrors] = useState({});

  const set = (field, val) => {
    setForm(prev => ({ ...prev, [field]: val }));
    setErrors(prev => ({ ...prev, [field]: undefined }));
  };

  const validate = () => {
    const e = {};
    if (!form.firstName.trim())  e.firstName = "First name is required.";
    if (!form.lastName.trim())   e.lastName  = "Last name is required.";
    if (!form.email.trim())      e.email     = "Email is required.";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) e.email = "Enter a valid email address.";
    if (form.phone && !/^\d{7,15}$/.test(form.phone.replace(/\s/g, ""))) e.phone = "Enter a valid phone number.";
    if (!form.password)          e.password     = "Password is required.";
    else if (form.password.length < 8)           e.password = "Password must be at least 8 characters.";
    if (!form.confirmPassword)   e.confirmPassword = "Please confirm your password.";
    else if (form.password !== form.confirmPassword) e.confirmPassword = "Passwords do not match.";
    return e;
  };

  const handleSubmit = () => {
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    const { confirmPassword, ...rest } = form;
    onAdd(rest);
  };

  return (
    <div className="am-overlay" onClick={onClose}>
      <div className="am-modal" onClick={e => e.stopPropagation()}>
        <div className="am-modal-hdr">
          <h3>Add New Administrator</h3>
          <button className="am-modal-close" onClick={onClose}><IconX /></button>
        </div>
        <div className="am-modal-body">

          {/* Basic Information */}
          <span className="am-section-title">Basic Information</span>
          <div className="am-form-grid">
            <div className="am-form-group">
              <label>First Name</label>
              <input
                value={form.firstName}
                onChange={e => set("firstName", e.target.value)}
                placeholder="First name"
                className={errors.firstName ? "error" : ""}
              />
              {errors.firstName && <div className="am-field-error">{errors.firstName}</div>}
            </div>
            <div className="am-form-group">
              <label>Last Name</label>
              <input
                value={form.lastName}
                onChange={e => set("lastName", e.target.value)}
                placeholder="Last name"
                className={errors.lastName ? "error" : ""}
              />
              {errors.lastName && <div className="am-field-error">{errors.lastName}</div>}
            </div>
            <div className="am-form-group">
              <label>Role</label>
              <select value={form.role} onChange={e => set("role", e.target.value)}>
                <option>Senior Admin</option>
                <option>Admin</option>
                <option>Junior Admin</option>
              </select>
            </div>
            <div className="am-form-group">
              <label>Department</label>
              <select value={form.department} onChange={e => set("department", e.target.value)}>
                <option value="">Select department</option>
                {departments.map(d => <option key={d}>{d}</option>)}
              </select>
            </div>
          </div>

          <hr className="am-section-divider" />

          {/* Contact Details */}
          <span className="am-section-title">Contact Details</span>
          <div className="am-form-grid">
            <div className="am-form-group full">
              <label>Email</label>
              <input
                type="email"
                value={form.email}
                onChange={e => set("email", e.target.value)}
                placeholder="admin@aurix.lk"
                className={errors.email ? "error" : ""}
              />
              {errors.email && <div className="am-field-error">{errors.email}</div>}
            </div>
            <PhoneField
              value={form.phone}
              phoneCode={form.phoneCode}
              onValueChange={v => set("phone", v)}
              onCodeChange={v => set("phoneCode", v)}
              error={errors.phone}
            />
          </div>

          <hr className="am-section-divider" />

          {/* Password */}
          <span className="am-section-title">Set Password</span>
          <div className="am-form-grid">
            <PasswordField
              label="Password"
              value={form.password}
              onChange={v => set("password", v)}
              error={errors.password}
              placeholder="Min. 8 characters"
            />
            <PasswordField
              label="Confirm Password"
              value={form.confirmPassword}
              onChange={v => set("confirmPassword", v)}
              error={errors.confirmPassword}
              placeholder="Re-enter password"
            />
          </div>

          <div className="am-modal-footer">
            <button className="am-btn-cancel" onClick={onClose}>Cancel</button>
            <button className="am-btn-submit" onClick={handleSubmit}>Add Administrator</button>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ─── Edit Modal ─── */
function EditModal({ admin, onClose, onSave, onDelete }) {
  const nameParts = (admin.name || "").split(" ");
  const [form, setForm] = useState({
    ...admin,
    firstName:       nameParts[0] || "",
    lastName:        nameParts.slice(1).join(" ") || "",
    phone:           admin.phone     || "",
    phoneCode:       admin.phoneCode || "+94",
    password:        "",
    confirmPassword: "",
  });
  const [errors, setErrors] = useState({});

  const set = (field, val) => {
    setForm(prev => ({ ...prev, [field]: val }));
    setErrors(prev => ({ ...prev, [field]: undefined }));
  };

  const validate = () => {
    const e = {};
    if (!form.firstName.trim()) e.firstName = "First name is required.";
    if (!form.lastName.trim())  e.lastName  = "Last name is required.";
    if (!form.email.trim())     e.email     = "Email is required.";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) e.email = "Enter a valid email address.";
    if (form.phone && !/^\d{7,15}$/.test(form.phone.replace(/\s/g, ""))) e.phone = "Enter a valid phone number.";
    if (form.password) {
      if (form.password.length < 8) e.password = "Password must be at least 8 characters.";
      if (form.password !== form.confirmPassword) e.confirmPassword = "Passwords do not match.";
    }
    return e;
  };

  const handleSave = () => {
    const e = validate();
    if (Object.keys(e).length) { setErrors(e); return; }
    const { password, confirmPassword, firstName, lastName, ...rest } = form;
    onSave({
      ...rest,
      name:     `${firstName} ${lastName}`.trim(),
      initials: `${firstName[0]}${lastName[0]}`.toUpperCase(),
    });
  };

  const togglePerm = (key) => {
    if (form.isCurrent && key === "admins") return;
    setForm(prev => ({
      ...prev,
      permissions: prev.permissions.includes(key)
        ? prev.permissions.filter(x => x !== key)
        : [...prev.permissions, key],
    }));
  };

  return (
    <div className="am-overlay" onClick={onClose}>
      <div className="am-modal" onClick={e => e.stopPropagation()}>
        <div className="am-modal-hdr">
          <h3>Edit Administrator</h3>
          <button className="am-modal-close" onClick={onClose}><IconX /></button>
        </div>
        <div className="am-modal-body">

          {/* Basic Information */}
          <span className="am-section-title">Basic Information</span>
          <div className="am-form-grid">
            <div className="am-form-group">
              <label>First Name</label>
              <input
                value={form.firstName}
                onChange={e => set("firstName", e.target.value)}
                className={errors.firstName ? "error" : ""}
              />
              {errors.firstName && <div className="am-field-error">{errors.firstName}</div>}
            </div>
            <div className="am-form-group">
              <label>Last Name</label>
              <input
                value={form.lastName}
                onChange={e => set("lastName", e.target.value)}
                className={errors.lastName ? "error" : ""}
              />
              {errors.lastName && <div className="am-field-error">{errors.lastName}</div>}
            </div>
            <div className="am-form-group">
              <label>Role</label>
              <select
                value={form.role}
                onChange={e => set("role", e.target.value)}
                disabled={form.isCurrent}
              >
                <option>Senior Admin</option>
                <option>Admin</option>
                <option>Junior Admin</option>
              </select>
            </div>
            <div className="am-form-group">
              <label>Department</label>
              <select value={form.department} onChange={e => set("department", e.target.value)}>
                <option value="">Select department</option>
                {departments.map(d => <option key={d}>{d}</option>)}
              </select>
            </div>
          </div>

          <hr className="am-section-divider" />

          {/* Contact Details */}
          <span className="am-section-title">Contact Details</span>
          <div className="am-form-grid">
            <div className="am-form-group full">
              <label>Email</label>
              <input
                type="email"
                value={form.email}
                onChange={e => set("email", e.target.value)}
                className={errors.email ? "error" : ""}
              />
              {errors.email && <div className="am-field-error">{errors.email}</div>}
            </div>
            <PhoneField
              value={form.phone}
              phoneCode={form.phoneCode}
              onValueChange={v => set("phone", v)}
              onCodeChange={v => set("phoneCode", v)}
              error={errors.phone}
            />
          </div>

          <hr className="am-section-divider" />

          {/* Change Password */}
          <span className="am-section-title">
            Change Password{" "}
            <span style={{ fontWeight: 400, textTransform: "none", color: "#ccc", fontSize: 10 }}>
              (leave blank to keep current)
            </span>
          </span>
          <div className="am-form-grid">
            <PasswordField
              label="New Password"
              value={form.password}
              onChange={v => set("password", v)}
              error={errors.password}
              placeholder="New password"
            />
            <PasswordField
              label="Confirm New Password"
              value={form.confirmPassword}
              onChange={v => set("confirmPassword", v)}
              error={errors.confirmPassword}
              placeholder="Re-enter new password"
            />
          </div>

          <hr className="am-section-divider" />

          {/* Permissions */}
          <span className="am-section-title">Permissions</span>
          {allPermissions.map(p => {
            const on     = form.permissions.includes(p.key);
            const locked = form.isCurrent && p.key === "admins";
            return (
              <div
                key={p.key}
                className={`am-perm-row ${on ? "on" : "off"}`}
                style={{ cursor: locked ? "not-allowed" : "pointer", opacity: locked ? 0.5 : 1 }}
                onClick={() => togglePerm(p.key)}
              >
                <div className={`am-perm-check ${on ? "on" : "off"}`}>
                  {on && <IconCheck />}
                </div>
                <span>{p.icon}</span>
                <span className={`pname ${on ? "" : "off"}`}>{p.label}</span>
              </div>
            );
          })}

          <div className="am-modal-footer">
            {!form.isCurrent && (
              <button
                className="am-btn-cancel"
                style={{ color: "#dc2626", borderColor: "#fca5a5" }}
                onClick={onDelete}
              >
                Remove
              </button>
            )}
            <div style={{ marginLeft: "auto", display: "flex", gap: 8 }}>
              <button className="am-btn-cancel" onClick={onClose}>Cancel</button>
              <button className="am-btn-submit" onClick={handleSave}>Save Changes</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}