import React, { useState } from "react";
import "./SettingsPage.css";

const SettingsPage = () => {
  const [saved, setSaved] = useState(false);

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

  return (
    <div className="sp-page">
      <div className="sp-page-header">
        <h1>Settings</h1>
        {saved && (
          <div className="sp-saved-toast">Changes saved successfully</div>
        )}
      </div>

      <div className="sp-stack">
        {/* Notifications */}
        <div className="sp-section-card">
          <h2 className="sp-section-title">Notification Preferences</h2>
          <div className="sp-toggles">
            {[
              {
                label: "New Jeweler Registration",
                desc: "Notify when a new jeweler submits for verification",
              },
              {
                label: "Order Placed",
                desc: "Notify when a new order is placed on the platform",
              },
              {
                label: "Dispute Opened",
                desc: "Notify when a buyer opens a dispute",
              },
              {
                label: "Escrow Release",
                desc: "Notify when escrow funds are automatically released",
              },
              {
                label: "Low Inventory Alert",
                desc: "Notify when a product stock falls below threshold",
              },
              {
                label: "Suspicious Activity",
                desc: "Notify on flagged or suspicious platform activity",
              },
            ].map((t, i) => (
              <div key={i} className="sp-toggle-row">
                <div>
                  <p className="sp-toggle-label">{t.label}</p>
                  <p className="sp-toggle-desc">{t.desc}</p>
                </div>
                <button className="sp-toggle-btn on">
                  <span className="sp-toggle-knob" />
                </button>
              </div>
            ))}
          </div>
          <div className="sp-save-row">
            <button className="sp-save-btn" onClick={handleSave}>
              Save Changes
            </button>
          </div>
        </div>
        {/* Platform Settings */}
        <div className="sp-section-card">
          <h2 className="sp-section-title">Platform Settings</h2>
          <div className="sp-form-grid">
            <div className="sp-form-group">
              <label>Commission Rate (%)</label>
              <input
                type="number"
                min="0"
                max="20"
                value={platform.commissionRate}
                onChange={(e) =>
                  setPlatform({ ...platform, commissionRate: e.target.value })
                }
              />
            </div>
            <div className="sp-form-group">
              <label>Escrow Hold Days</label>
              <input
                type="number"
                min="1"
                value={platform.escrowDays}
                onChange={(e) =>
                  setPlatform({ ...platform, escrowDays: e.target.value })
                }
              />
            </div>
            <div className="sp-form-group">
              <label>Max Dispute Resolution Days</label>
              <input
                type="number"
                min="1"
                value={platform.maxDisputeDays}
                onChange={(e) =>
                  setPlatform({ ...platform, maxDisputeDays: e.target.value })
                }
              />
            </div>
            <div className="sp-form-group">
              <label>Minimum Order Value ($)</label>
              <input
                type="number"
                min="0"
                value={platform.minOrderValue}
                onChange={(e) =>
                  setPlatform({ ...platform, minOrderValue: e.target.value })
                }
              />
            </div>
          </div>

          <div className="sp-toggles">
            {[
              {
                key: "maintenanceMode",
                label: "Maintenance Mode",
                desc: "Temporarily disable the platform for users",
              },
              {
                key: "newRegistrations",
                label: "Allow New Registrations",
                desc: "Enable or disable new jeweler registrations",
              },
              {
                key: "emailAlerts",
                label: "Email Alerts",
                desc: "Send email alerts for important events",
              },
              {
                key: "smsAlerts",
                label: "SMS Alerts",
                desc: "Send SMS alerts to administrators",
              },
            ].map((t) => (
              <div key={t.key} className="sp-toggle-row">
                <div>
                  <p className="sp-toggle-label">{t.label}</p>
                  <p className="sp-toggle-desc">{t.desc}</p>
                </div>
                <button
                  className={`sp-toggle-btn ${platform[t.key] ? "on" : "off"}`}
                  onClick={() =>
                    setPlatform({ ...platform, [t.key]: !platform[t.key] })
                  }
                >
                  <span className="sp-toggle-knob" />
                </button>
              </div>
            ))}
          </div>

          <div className="sp-save-row">
            <button className="sp-save-btn" onClick={handleSave}>
              Save Changes
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
