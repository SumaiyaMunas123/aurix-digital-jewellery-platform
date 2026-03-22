import React, { useState, useEffect, useCallback } from "react";
import "./OrdersDashboard.css";
import { apiCall } from "./api/client";

// Map DB status values to display labels
const STATUS_LABELS = {
  pending_payment:   "Pending",
  payment_confirmed: "Confirmed",
  processing:        "Processing",
  in_production:     "In Production",
  ready_for_pickup:  "Ready",
  completed:         "Completed",
  cancelled:         "Cancelled",
};

const STATUS_CLASS = {
  pending_payment:   "od-pill od-pending",
  payment_confirmed: "od-pill od-processing",
  processing:        "od-pill od-processing",
  in_production:     "od-pill od-shipped",
  ready_for_pickup:  "od-pill od-shipped",
  completed:         "od-pill od-delivered",
  cancelled:         "od-pill od-cancelled",
};

const tabs = [
  { label: "All Orders",    value: null },
  { label: "Pending",       value: "pending_payment" },
  { label: "Confirmed",     value: "payment_confirmed" },
  { label: "Processing",    value: "processing" },
  { label: "In Production", value: "in_production" },
  { label: "Ready",         value: "ready_for_pickup" },
  { label: "Completed",     value: "completed" },
  { label: "Cancelled",     value: "cancelled" },
];

const formatDate = (dateStr) => {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("en-US", {
    month: "short", day: "numeric", year: "numeric",
  });
};

// ── Order detail modal ──
const OrderModal = ({ order, onClose, onStatusChange }) => {
  const [newStatus, setNewStatus] = useState(order.status);
  const [note, setNote] = useState("");
  const [saving, setSaving] = useState(false);

  const validStatuses = [
    "pending_payment", "payment_confirmed", "processing",
    "in_production", "ready_for_pickup", "completed", "cancelled",
  ];

  const handleSave = async () => {
    if (newStatus === order.status) { onClose(); return; }
    setSaving(true);
    try {
      await apiCall(`/admin/orders/${order.id}/status`, {
        method: "PATCH",
        body: JSON.stringify({ status: newStatus, note }),
      });
      onStatusChange(order.id, newStatus);
      onClose();
    } catch (err) {
      alert("Failed to update status: " + err.message);
    } finally {
      setSaving(false);
    }
  };

  const customer  = order.customer;
  const jeweller  = order.jeweller;
  const product   = order.product;

  return (
    <>
      <div className="od-modal-backdrop" onClick={onClose} />
      <div className="od-modal">
        <div className="od-modal-header">
          <div>
            <p className="od-modal-order-num">{order.order_number}</p>
            <p className="od-modal-date">Placed {formatDate(order.created_at)}</p>
          </div>
          <button className="od-modal-close" onClick={onClose}>✕</button>
        </div>

        <div className="od-modal-body">
          {/* Customer */}
          <div className="od-modal-section">
            <h4 className="od-modal-section-title">Customer</h4>
            <p className="od-modal-val">{customer?.name || "—"}</p>
            <p className="od-modal-sub">{customer?.email || "—"}</p>
            {customer?.phone && <p className="od-modal-sub">{customer.phone}</p>}
          </div>

          {/* Jeweller */}
          <div className="od-modal-section">
            <h4 className="od-modal-section-title">Jeweller</h4>
            <p className="od-modal-val">{jeweller?.business_name || jeweller?.name || "—"}</p>
            <p className="od-modal-sub">{jeweller?.email || "—"}</p>
          </div>

          {/* Product */}
          <div className="od-modal-section">
            <h4 className="od-modal-section-title">Product</h4>
            <p className="od-modal-val">{product?.name || "—"}</p>
            <p className="od-modal-sub">{product?.category || "—"}</p>
          </div>

          {/* Order details */}
          <div className="od-modal-section">
            <h4 className="od-modal-section-title">Order Details</h4>
            <div className="od-modal-details-grid">
              <div><span className="od-modal-key">Qty</span><span className="od-modal-val">{order.quantity}</span></div>
              <div><span className="od-modal-key">Unit Price</span><span className="od-modal-val">LKR {(order.unit_price || 0).toLocaleString("en-LK")}</span></div>
              <div><span className="od-modal-key">Total</span><span className="od-modal-val od-modal-total">LKR {(order.total_price || 0).toLocaleString("en-LK")}</span></div>
            </div>
          </div>

          {/* Status update */}
          <div className="od-modal-section">
            <h4 className="od-modal-section-title">Update Status</h4>
            <select
              className="od-modal-select"
              value={newStatus}
              onChange={(e) => setNewStatus(e.target.value)}
            >
              {validStatuses.map((s) => (
                <option key={s} value={s}>{STATUS_LABELS[s]}</option>
              ))}
            </select>
            <textarea
              className="od-modal-note"
              placeholder="Add a note (optional)…"
              value={note}
              rows={2}
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </div>

        <div className="od-modal-footer">
          <button className="od-modal-cancel" onClick={onClose}>Cancel</button>
          <button className="od-modal-save" onClick={handleSave} disabled={saving}>
            {saving ? "Saving…" : "Save Changes"}
          </button>
        </div>
      </div>
    </>
  );
};

// ── Main component ──
const OrdersDashboard = () => {
  const [activeTab, setActiveTab]     = useState(null);
  const [search, setSearch]           = useState("");
  const [orders, setOrders]           = useState([]);
  const [stats, setStats]             = useState(null);
  const [loading, setLoading]         = useState(true);
  const [error, setError]             = useState(null);
  const [viewOrder, setViewOrder]     = useState(null);

  const loadOrders = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const params = new URLSearchParams({ limit: 100 });
      if (activeTab) params.set("status", activeTab);
      const res = await apiCall(`/admin/orders?${params}`);
      setOrders(res.orders || []);
    } catch (err) {
      setError(err.message || "Failed to load orders.");
    } finally {
      setLoading(false);
    }
  }, [activeTab]);

  const loadStats = useCallback(async () => {
    try {
      const res = await apiCall("/admin/orders/stats");
      if (res.success) setStats(res.stats);
    } catch {}
  }, []);

  useEffect(() => { loadOrders(); }, [loadOrders]);
  useEffect(() => { loadStats(); }, [loadStats]);

  const handleStatusChange = (id, newStatus) => {
    setOrders((prev) => prev.map((o) => o.id === id ? { ...o, status: newStatus } : o));
    loadStats();
  };

  const filtered = orders.filter((o) => {
    const q = search.toLowerCase();
    return !q ||
      (o.order_number || "").toLowerCase().includes(q) ||
      (o.customer?.name || "").toLowerCase().includes(q) ||
      (o.product?.name || "").toLowerCase().includes(q);
  });

  const summary = [
    { label: "Total Orders",   value: stats ? stats.total              : "—" },
    { label: "Pending",        value: stats ? stats.pending_payment    : "—" },
    { label: "In Production",  value: stats ? stats.in_production      : "—" },
    { label: "Completed",      value: stats ? stats.completed          : "—" },
    { label: "Cancelled",      value: stats ? stats.cancelled          : "—" },
  ];

  return (
    <div className="od-page">
      <div className="od-page-header">
        <h1>Orders Management</h1>
      </div>

      {/* Stats */}
      <div className="od-stats-grid">
        {summary.map((s, i) => (
          <div key={i} className="od-stat-card">
            <p className="od-stat-label">{s.label}</p>
            <p className="od-stat-value">{s.value}</p>
          </div>
        ))}
      </div>

      {/* Tabs */}
      <div className="od-controls-bar">
        <div className="od-tabs">
          {tabs.map((tab) => (
            <button
              key={tab.label}
              className={`od-tab ${activeTab === tab.value ? "active" : ""}`}
              onClick={() => setActiveTab(tab.value)}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Search */}
      <div className="od-search-filter-bar">
        <div className="od-search-wrap">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            type="text"
            placeholder="Search by order ID, customer or item..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="od-search-input"
          />
        </div>
      </div>

      {/* Table */}
      <div className="od-card">
        <div className="od-table-wrapper">
          <table className="od-table">
            <thead>
              <tr>
                <th>ORDER ID</th>
                <th>CUSTOMER</th>
                <th>JEWELLER</th>
                <th>ITEM</th>
                <th>AMOUNT</th>
                <th>DATE</th>
                <th>STATUS</th>
                <th>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan="8" className="od-empty">Loading orders…</td></tr>
              ) : error ? (
                <tr><td colSpan="8" className="od-empty" style={{ color: "#dc2626" }}>{error}</td></tr>
              ) : filtered.length === 0 ? (
                <tr><td colSpan="8" className="od-empty">No orders found.</td></tr>
              ) : (
                filtered.map((o) => (
                  <tr key={o.id}>
                    <td className="od-order-id">{o.order_number}</td>
                    <td>
                      <div className="od-customer-cell">
                        <div className="od-customer-info">
                          <p className="od-customer-name">{o.customer?.name || "—"}</p>
                          <p className="od-customer-email">{o.customer?.email || "—"}</p>
                        </div>
                      </div>
                    </td>
                    <td className="od-jeweler">
                      {o.jeweller?.business_name || o.jeweller?.name || "—"}
                    </td>
                    <td className="od-item">{o.product?.name || "—"}</td>
                    <td className="od-amount">
                      LKR {(o.total_price || 0).toLocaleString("en-LK", { maximumFractionDigits: 2 })}
                    </td>
                    <td className="od-date">{formatDate(o.created_at)}</td>
                    <td>
                      <span className={STATUS_CLASS[o.status] || "od-pill od-pending"}>
                        {STATUS_LABELS[o.status] || o.status}
                      </span>
                    </td>
                    <td>
                      <button className="od-view-btn" onClick={() => setViewOrder(o)}>
                        View
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
        <div className="od-footer-row">
          <p className="od-results">
            Showing {filtered.length} of {orders.length} results
          </p>
          <div className="od-pagination">
            {["‹", "1", "2", "3", "›"].map((p, i) => (
              <button key={i} className={`od-page-btn ${p === "1" ? "active" : ""}`}>{p}</button>
            ))}
          </div>
        </div>
      </div>

      {/* Order detail modal */}
      {viewOrder && (
        <OrderModal
          order={viewOrder}
          onClose={() => setViewOrder(null)}
          onStatusChange={handleStatusChange}
        />
      )}
    </div>
  );
};

export default OrdersDashboard;