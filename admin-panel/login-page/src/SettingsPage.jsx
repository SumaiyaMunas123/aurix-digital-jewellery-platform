import React, { useState } from "react";
import "./SettingsPage.css";

const SettingsPage = () => {
  const [activeSection, setActiveSection] = useState("profile");
  const [saved, setSaved] = useState(false);

  const [profile, setProfile] = useState({
    name: "Sanuthmi Jayalath",
    email: "sanuthmi@aurix.lk",
    role: "Senior Admin",
    phone: "+94 77 123 4567",
  });

  const [platform, setPlatform] = useState({
    commissionRate: "3",
    escrowDays: "14",
    maxDisputeDays: "30",
    minOrderValue: "100",
    maintenanceMode: false,
    newRegistrations: true,
    emailAlerts: true,
    smsAlerts: false,
  });

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  const sections = [
    { id: "profile", label: "Profile Settings"},
    { id: "platform", label: "Platform Settings" },
    { id: "notifications", label: "Notifications" },
    { id: "security", label: "Security"},
  ];

  return (
    <div className="sp-page">
      <div className="sp-page-header">
        <h1>Settings</h1>
        {saved && <div className="sp-saved-toast"> Changes saved successfully</div>}
      </div>

      <div className="sp-layout">
        {/* Sidebar nav */}
        <div className="sp-side-nav">
          {sections.map((s) => (
            <button key={s.id} className={`sp-nav-btn ${activeSection === s.id ? "active" : ""}`} onClick={() => setActiveSection(s.id)}>
              <span className="sp-nav-icon">{s.icon}</span>
              {s.label}
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="sp-content">
          {activeSection === "profile" && (
            <div className="sp-section-card">
              <h2 className="sp-section-title">Profile Settings</h2>
              <p className="sp-section-desc">Update your account information and preferences.</p>
              <div className="sp-avatar-row">
                <div className="sp-avatar-big">SJ</div>
                <div>
                  <p className="sp-avatar-name">{profile.name}</p>
                  <p className="sp-avatar-role">{profile.role}</p>
                  <button className="sp-avatar-change-btn">Change Avatar</button>
                </div>
              </div>
              <div className="sp-form-grid">
                <div className="sp-form-group">
                  <label>Full Name</label>
                  <input value={profile.name} onChange={(e) => setProfile({ ...profile, name: e.target.value })} />
                </div>
                <div className="sp-form-group">
                  <label>Email Address</label>
                  <input value={profile.email} onChange={(e) => setProfile({ ...profile, email: e.target.value })} />
                </div>
                <div className="sp-form-group">
                  <label>Role</label>
                  <input value={profile.role} disabled className="sp-input-disabled" />
                </div>
                <div className="sp-form-group">
                  <label>Phone Number</label>
                  <input value={profile.phone} onChange={(e) => setProfile({ ...profile, phone: e.target.value })} />
                </div>
              </div>
              <div className="sp-save-row">
                <button className="sp-save-btn" onClick={handleSave}>Save Changes</button>
              </div>
            </div>
          )}

          {activeSection === "platform" && (
            <div className="sp-section-card">
              <h2 className="sp-section-title">Platform Settings</h2>
              <p className="sp-section-desc">Configure platform-wide rules and thresholds.</p>
              <div className="sp-form-grid">
                <div className="sp-form-group">
                  <label>Commission Rate (%)</label>
                  <input type="number" min="0" max="20" value={platform.commissionRate} onChange={(e) => setPlatform({ ...platform, commissionRate: e.target.value })} />
                </div>
                <div className="sp-form-group">
                  <label>Escrow Hold Days</label>
                  <input type="number" min="1" value={platform.escrowDays} onChange={(e) => setPlatform({ ...platform, escrowDays: e.target.value })} />
                </div>
                <div className="sp-form-group">
                  <label>Max Dispute Resolution Days</label>
                  <input type="number" min="1" value={platform.maxDisputeDays} onChange={(e) => setPlatform({ ...platform, maxDisputeDays: e.target.value })} />
                </div>
                <div className="sp-form-group">
                  <label>Minimum Order Value ($)</label>
                  <input type="number" min="0" value={platform.minOrderValue} onChange={(e) => setPlatform({ ...platform, minOrderValue: e.target.value })} />
                </div>
              </div>
              <div className="sp-toggles">
                {[
                  { key: "maintenanceMode", label: "Maintenance Mode", desc: "Temporarily disable the platform for users" },
                  { key: "newRegistrations", label: "Allow New Registrations", desc: "Enable or disable new jeweler registrations" },
                  { key: "emailAlerts", label: "Email Alerts", desc: "Send email alerts for important events" },
                  { key: "smsAlerts", label: "SMS Alerts", desc: "Send SMS alerts to administrators" },
                ].map((t) => (
                  <div key={t.key} className="sp-toggle-row">
                    <div>
                      <p className="sp-toggle-label">{t.label}</p>
                      <p className="sp-toggle-desc">{t.desc}</p>
                    </div>
                    <button
                      className={`sp-toggle-btn ${platform[t.key] ? "on" : "off"}`}
                      onClick={() => setPlatform({ ...platform, [t.key]: !platform[t.key] })}
                    >
                      <span className="sp-toggle-knob" />
                    </button>
                  </div>
                ))}
              </div>
              <div className="sp-save-row">
                <button className="sp-save-btn" onClick={handleSave}>Save Changes</button>
              </div>
            </div>
          )}

          {activeSection === "notifications" && (
            <div className="sp-section-card">
              <h2 className="sp-section-title">Notification Preferences</h2>
              <p className="sp-section-desc">Choose which events trigger notifications.</p>
              <div className="sp-toggles">
                {[
                  { label: "New Jeweler Registration", desc: "Notify when a new jeweler submits for verification" },
                  { label: "Order Placed", desc: "Notify when a new order is placed on the platform" },
                  { label: "Dispute Opened", desc: "Notify when a buyer opens a dispute" },
                  { label: "Escrow Release", desc: "Notify when escrow funds are automatically released" },
                  { label: "Low Inventory Alert", desc: "Notify when a product stock falls below threshold" },
                  { label: "Suspicious Activity", desc: "Notify on flagged or suspicious platform activity" },
                ].map((t, i) => (
                  <div key={i} className="sp-toggle-row">
                    <div>
                      <p className="sp-toggle-label">{t.label}</p>
                      <p className="sp-toggle-desc">{t.desc}</p>
                    </div>
                    <button className="sp-toggle-btn on"><span className="sp-toggle-knob" /></button>
                  </div>
                ))}
              </div>
              <div className="sp-save-row">
                <button className="sp-save-btn" onClick={handleSave}>Save Preferences</button>
              </div>
            </div>
          )}

          {activeSection === "security" && (
            <div className="sp-section-card">
              <h2 className="sp-section-title">Security</h2>
              <p className="sp-section-desc">Manage your password and security settings.</p>
              <div className="sp-form-grid">
                <div className="sp-form-group sp-full">
                  <label>Current Password</label>
                  <input type="password" placeholder="Enter current password" />
                </div>
                <div className="sp-form-group">
                  <label>New Password</label>
                  <input type="password" placeholder="Enter new password" />
                </div>
                <div className="sp-form-group">
                  <label>Confirm New Password</label>
                  <input type="password" placeholder="Confirm new password" />
                </div>
              </div>
              <div className="sp-security-info">
                <p>🔐 Two-Factor Authentication</p>
                <p className="sp-security-desc">Add an extra layer of security to your account by enabling 2FA.</p>
                <button className="sp-enable-2fa-btn">Enable 2FA</button>
              </div>
              <div className="sp-save-row">
                <button className="sp-save-btn" onClick={handleSave}>Update Password</button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
