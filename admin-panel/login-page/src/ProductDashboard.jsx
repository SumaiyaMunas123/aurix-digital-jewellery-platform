import React, { useState, useEffect, useCallback } from "react";
import "./ProductDashboard.css";
import {
  adminGetAllProducts,
  adminApproveProduct,
  adminRejectProduct,
  adminDeleteProduct,
  adminToggleProductVisibility,
} from "./api/client";

const ProductDashboard = ({ defaultFilter = "All Categories" }) => {
  const [activeTab, setActiveTab] = useState("All Products");
  const [searchQuery, setSearchQuery] = useState("");
  const [viewProduct, setViewProduct] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [actionLoading, setActionLoading] = useState(false);

  // Rejection feedback state
  const [rejectTarget, setRejectTarget] = useState(null);
  const [rejectReason, setRejectReason] = useState("");
  const [rejectError, setRejectError] = useState("");

  const loadProducts = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await adminGetAllProducts({ limit: 100 });
      setProducts(res.products || []);
    } catch (err) {
      setError("Failed to load products. Please try again.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadProducts(); }, [loadProducts]);

  // ── Counts ──────────────────────────────────────────────────
  const pendingCount = products.filter(
    (p) => p.admin_status === "pending",
  ).length;
  const approvedCount = products.filter(
    (p) => p.admin_status === "approved",
  ).length;
  const flaggedCount = products.filter(
    (p) => p.admin_status === "flagged",
  ).length;
  const rejectedCount = products.filter(
    (p) => p.admin_status === "rejected",
  ).length;

  const tabs = ["All Products", "Pending", "Approved", "Flagged", "Rejected"];

  const stats = [
    { label: "TOTAL PRODUCTS", value: loading ? "—" : products.length },
    { label: "PENDING ",       value: loading ? "—" : pendingCount },
    { label: "APPROVED",       value: loading ? "—" : approvedCount },
    { label: "REJECTED",       value: loading ? "—" : rejectedCount },
    { label: "FLAGGED",        value: loading ? "—" : flaggedCount },
  ];

  const getStatusClass = (status) => {
    switch (status) {
      case "approved": return "status-approved";
      case "pending":  return "status-pending";
      case "flagged":  return "status-flagged";
      case "rejected": return "status-rejected";
      default: return "";
    }
  };

  const statusLabel = (status) =>
    status ? status.charAt(0).toUpperCase() + status.slice(1) : "";

  // Tab filter maps to admin_status values
  const tabKey = activeTab === "All Products" ? null : activeTab.toLowerCase();
  const tabFiltered = tabKey
    ? products.filter((p) => p.admin_status === tabKey)
    : products;

  const filtered =
    searchQuery.trim() === ""
      ? tabFiltered
      : tabFiltered.filter(
          (p) =>
            p.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            p.sku?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            p.category?.toLowerCase().includes(searchQuery.toLowerCase()),
        );

  // Helper: jeweller display name from joined relation
  const jeweller = (p) =>
    p.jeweller?.business_name || p.jeweller?.name || "Unknown Jeweller";

  // ── Sync updated product into local state ─────────────────
  const syncProduct = (updated) => {
    setProducts((prev) => prev.map((p) => p.id === updated.id ? updated : p));
    if (viewProduct?.id === updated.id) setViewProduct(updated);
  };

  // ── Actions ───────────────────────────────────────────────

  // PATCH /api/admin/products/:id/approve
  const handleApprove = async (id) => {
    try {
      setActionLoading(true);
      const res = await adminApproveProduct(id);
      syncProduct(res.product);
    } catch (err) {
      alert(err.message || "Could not approve product.");
    } finally {
      setActionLoading(false);
    }
  };

  // Opens rejection modal — does NOT reject immediately
  const openRejectModal = (product) => {
    setRejectTarget(product);
    setRejectReason("");
    setRejectError("");
  };

  // PATCH /api/admin/products/:id/reject  body: { reason }
  const handleConfirmReject = async () => {
    if (!rejectReason.trim()) {
      setRejectError("Please provide a reason before rejecting.");
      return;
    }
    try {
      setActionLoading(true);
      const res = await adminRejectProduct(rejectTarget.id, rejectReason.trim());
      syncProduct(res.product);
      setRejectTarget(null);
      setRejectReason("");
      setRejectError("");
    } catch (err) {
      setRejectError(err.message || "Could not reject product.");
    } finally {
      setActionLoading(false);
    }
  };

  // PATCH /api/admin/products/:id/visibility  body: { is_active }
  const handleToggleVisibility = async (id, currentStatus) => {
    try {
      setActionLoading(true);
      const res = await adminToggleProductVisibility(id, !currentStatus);
      syncProduct(res.product);
    } catch (err) {
      alert(err.message || "Could not toggle visibility.");
    } finally {
      setActionLoading(false);
    }
  };

  // DELETE /api/admin/products/:id
  const handleDelete = async (id) => {
    try {
      setActionLoading(true);
      await adminDeleteProduct(id);
      setProducts((prev) => prev.filter((p) => p.id !== id));
      setDeleteTarget(null);
      if (viewProduct?.id === id) setViewProduct(null);
    } catch (err) {
      alert(err.message || "Could not delete product.");
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="pd-container">
      <div className="pd-header">
        <h1>Product Management</h1>
      </div>

      {/* Stats */}
      <div className="pd-stats-grid">
        {stats.map((stat, i) => (
          <div key={i} className="pd-stat-card">
            <div className="pd-stat-label">{stat.label}</div>
            <div className="pd-stat-value">{stat.value}</div>
          </div>
        ))}
      </div>

      {/* Tabs with pending badge */}
      <div className="pd-controls-bar">
        <div className="od-tabs">
          {tabs.map((tab) => (
            <button
              key={tab}
              className={`od-tab ${activeTab === tab ? "active" : ""}`}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
              {tab === "Pending" && pendingCount > 0 && (
                <span className="pd-tab-badge">{pendingCount}</span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Search */}
      <div className="pd-search-filter-bar">
        <div className="pd-search-wrap">
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
          >
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>
          <input
            type="text"
            placeholder="Search by product name, SKU or category..."
            className="pd-search"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* Table */}
      <div className="pd-table-wrapper">
        <table className="pd-table">
          <thead>
            <tr>
              <th>PRODUCT NAME</th>
              <th>SKU</th>
              <th>CATEGORY</th>
              <th>PRICE</th>
              <th>STOCK</th>
              <th>STATUS</th>
              <th>ACTIONS</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="7" className="pd-empty">Loading products...</td>
              </tr>
            ) : error ? (
              <tr>
                <td colSpan="7" className="pd-empty" style={{ color: "#dc2626" }}>{error}</td>
              </tr>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan="7" className="pd-empty">
                  No products found.
                </td>
              </tr>
            ) : (
              filtered.map((product) => (
                <tr
                  key={product.id}
                  className={!product.is_active ? "pd-row-hidden" : ""}
                >
                  <td>
                    <div className="pd-name-cell">
                      <div className="pd-product-name">
                        {product.name}
                        {!product.is_active && (
                          <span className="pd-hidden-tag">Hidden</span>
                        )}
                      </div>
                      <div className="pd-product-desc">{jeweller(product)}</div>
                    </div>
                  </td>
                  <td className="pd-sku">{product.sku || "—"}</td>
                  <td>
                    <span className="pd-category-badge">
                      {product.category || "—"}
                    </span>
                  </td>
                  <td className="pd-price">
                    {product.price_mode === "on_request"
                      ? "On Request"
                      : `LKR ${(product.price || 0).toLocaleString("en-LK", { maximumFractionDigits: 2 })}`}
                  </td>
                  <td
                    className={`pd-stock ${product.stock_quantity === 0 ? "out-of-stock" : ""}`}
                  >
                    {product.stock_quantity === 0
                      ? "Out of Stock"
                      : product.stock_quantity}
                  </td>
                  <td>
                    <span
                      className={`pd-status-badge ${getStatusClass(product.admin_status)}`}
                    >
                      {statusLabel(product.admin_status)}
                    </span>
                  </td>
                  <td>
                    <button
                      className="od-view-btn"
                      onClick={() => setViewProduct(product)}
                    >
                      View
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
        <div className="pd-pagination">
          <p className="pd-pagination-info">
            Showing <strong>{filtered.length}</strong> of{" "}
            <strong>{products.length}</strong> products
          </p>
          <div className="pd-pagination-controls">
            {["‹", "1", "2", "3", "›"].map((p, i) => (
              <button
                key={i}
                className={`pd-page-btn ${p === "1" ? "active" : ""}`}
              >
                {p}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/*  VIEW MODAL  */}
      {viewProduct && (
        <div className="pd-modal-overlay" onClick={() => setViewProduct(null)}>
          <div className="pd-modal" onClick={(e) => e.stopPropagation()}>
            <button
              className="pd-modal-close"
              onClick={() => setViewProduct(null)}
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.5"
              >
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>

            <div className="pd-modal-image">
              {viewProduct.primary_image_url || viewProduct.image_url ? (
                <img
                  src={viewProduct.primary_image_url || viewProduct.image_url}
                  alt={viewProduct.name}
                  style={{ width: "100%", height: "100%", objectFit: "cover", borderRadius: "20px 20px 0 0" }}
                />
              ) : (
                <div className="pd-modal-image-placeholder">
                  <svg
                    width="52"
                    height="52"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="#c9a227"
                    strokeWidth="1.2"
                  >
                    <rect x="3" y="3" width="18" height="18" rx="3" />
                    <circle cx="8.5" cy="8.5" r="1.5" />
                    <polyline points="21 15 16 10 5 21" />
                  </svg>
                </div>
              )}

              {/* Only show visibility toggle for approved products */}
              {viewProduct.admin_status === "approved" && (
                <button
                  className={`pd-visibility-btn ${viewProduct.is_active ? "visible" : "hidden"}`}
                  onClick={() => handleToggleVisibility(viewProduct.id, viewProduct.is_active)}
                  disabled={actionLoading}
                >
                  {viewProduct.is_active ? (
                    <>
                      <svg
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" />
                        <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" />
                        <line x1="1" y1="1" x2="23" y2="23" />
                      </svg>
                      Hide Product
                    </>
                  ) : (
                    <>
                      <svg
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                      >
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                        <circle cx="12" cy="12" r="3" />
                      </svg>
                      Make Visible
                    </>
                  )}
                </button>
              )}
            </div>

            <div className="pd-modal-body">
              <div className="pd-modal-top">
                <div>
                  <div className="pd-modal-category">
                    {viewProduct.category}
                  </div>
                  <h2 className="pd-modal-title">{viewProduct.name}</h2>
                  <p className="pd-modal-desc">{viewProduct.description}</p>
                </div>
                <span
                  className={`pd-status-badge ${getStatusClass(viewProduct.admin_status)}`}
                >
                  {statusLabel(viewProduct.admin_status)}
                </span>
              </div>

              <div className="pd-modal-price">
                {viewProduct.price_mode === "on_request"
                  ? "Price on Request"
                  : `LKR ${(viewProduct.price || 0).toLocaleString("en-LK", { maximumFractionDigits: 2 })}`}
              </div>

              <div className="pd-modal-details">
                <div className="pd-detail-item">
                  <span className="pd-detail-label">Jeweller</span>
                  <span className="pd-detail-value">{jeweller(viewProduct)}</span>
                </div>
                <div className="pd-detail-item">
                  <span className="pd-detail-label">SKU</span>
                  <span className="pd-detail-value mono">
                    {viewProduct.sku || "—"}
                  </span>
                </div>
                <div className="pd-detail-item">
                  <span className="pd-detail-label">Metal Type</span>
                  <span className="pd-detail-value">
                    {viewProduct.metal_type || "—"}
                  </span>
                </div>
                <div className="pd-detail-item">
                  <span className="pd-detail-label">Karat</span>
                  <span className="pd-detail-value">
                    {viewProduct.karat || "—"}
                  </span>
                </div>
                <div className="pd-detail-item">
                  <span className="pd-detail-label">Weight</span>
                  <span className="pd-detail-value">
                    {viewProduct.weight ? `${viewProduct.weight}g` : "—"}
                  </span>
                </div>
                <div className="pd-detail-item">
                  <span className="pd-detail-label">Stock</span>
                  <span
                    className={`pd-detail-value ${viewProduct.stock_quantity === 0 ? "red" : ""}`}
                  >
                    {viewProduct.stock_quantity === 0
                      ? "Out of Stock"
                      : viewProduct.stock_quantity}
                  </span>
                </div>
              </div>

              {/* Show rejection reason if product was rejected */}
              {viewProduct.admin_status === "rejected" && viewProduct.rejection_reason && (
                <div style={{
                  background: "#fff5f5",
                  border: "1.5px solid #fca5a5",
                  borderRadius: "10px",
                  padding: "12px 14px",
                  display: "flex",
                  flexDirection: "column",
                  gap: "6px",
                }}>
                  <span className="pd-detail-label">Rejection Reason</span>
                  <p style={{ margin: 0, fontSize: "13px", color: "#991b1b", fontWeight: 500, lineHeight: 1.5 }}>
                    {viewProduct.rejection_reason}
                  </p>
                </div>
              )}

              <div className="pd-modal-stats">
                <div className="pd-modal-stat">
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                  >
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                  {(viewProduct.total_views || 0).toLocaleString()} views
                </div>
                <div className="pd-modal-stat">
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                  >
                    <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
                    <line x1="3" y1="6" x2="21" y2="6" />
                    <path d="M16 10a4 4 0 0 1-8 0" />
                  </svg>
                  {(viewProduct.total_sold || 0).toLocaleString()} sold
                </div>
                <div
                  className={`pd-modal-stat ${viewProduct.is_active ? "green" : "muted"}`}
                >
                  <svg
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                  >
                    <circle cx="12" cy="12" r="10" />
                    {viewProduct.is_active ? (
                      <polyline points="9 12 11 14 15 10" />
                    ) : (
                      <>
                        <line x1="15" y1="9" x2="9" y2="15" />
                        <line x1="9" y1="9" x2="15" y2="15" />
                      </>
                    )}
                  </svg>
                  {viewProduct.is_active
                    ? "Visible to buyers"
                    : "Hidden from buyers"}
                </div>
              </div>

              {/*  PENDING: Approve / Reject  */}
              {viewProduct.admin_status === "pending" && (
                <div className="pd-modal-review">
                  <p className="pd-review-label">
                    This product is awaiting review
                  </p>
                  <div className="pd-review-actions">
                    <button
                      className="pd-approve-btn"
                      onClick={() => handleApprove(viewProduct.id)}
                      disabled={actionLoading}
                    >
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                      >
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {actionLoading ? "Saving..." : "Approve"}
                    </button>
                    <button
                      className="pd-reject-btn"
                      onClick={() => openRejectModal(viewProduct)}
                      disabled={actionLoading}
                    >
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                      >
                        <line x1="18" y1="6" x2="6" y2="18" />
                        <line x1="6" y1="6" x2="18" y2="18" />
                      </svg>
                      Reject
                    </button>
                  </div>
                </div>
              )}

              {/* FLAGGED: out of stock — auto-restores on restock, admin can reject */}
              {viewProduct.admin_status === "flagged" && (
                <div className="pd-modal-review pd-modal-review--flagged">
                  <p className="pd-review-label">
                    Flagged — out of stock. Will restore automatically when the
                    jeweller restocks.
                  </p>
                  <div className="pd-review-actions">
                    <button
                      className="pd-reject-btn"
                      onClick={() => openRejectModal(viewProduct)}
                      disabled={actionLoading}
                    >
                      <svg
                        width="14"
                        height="14"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                      >
                        <line x1="18" y1="6" x2="6" y2="18" />
                        <line x1="6" y1="6" x2="18" y2="18" />
                      </svg>
                      Reject Product
                    </button>
                  </div>
                </div>
              )}

              <div className="pd-modal-actions">
                <button
                  className="pd-modal-delete-btn"
                  onClick={() => {
                    setViewProduct(null);
                    setDeleteTarget(viewProduct);
                  }}
                  disabled={actionLoading}
                >
                  <svg
                    width="13"
                    height="13"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                  >
                    <polyline points="3 6 5 6 21 6" />
                    <path d="M19 6l-1 14H6L5 6" />
                    <path d="M10 11v6M14 11v6" />
                    <path d="M9 6V4h6v2" />
                  </svg>
                  Delete Product
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* REJECTION REASON MODAL */}
      {rejectTarget && (
        <div className="pd-modal-overlay" onClick={() => setRejectTarget(null)}>
          <div
            className="pd-confirm-modal"
            onClick={(e) => e.stopPropagation()}
            style={{ maxWidth: 460, textAlign: "left" }}
          >
            <h3 className="pd-confirm-title" style={{ textAlign: "left" }}>
              Reject Product
            </h3>
            <p style={{ margin: "0 0 4px", fontSize: 14, fontWeight: 600, color: "#d4af37" }}>
              {rejectTarget.name}
            </p>
            <p style={{ margin: "0 0 16px", fontSize: 13, color: "#6b7280", lineHeight: 1.5 }}>
              Provide a reason — this will be saved to the product record and visible to the jeweller.
            </p>
            <div style={{ display: "flex", flexDirection: "column", gap: 6, marginBottom: 20 }}>
              <label style={{ fontSize: 11, fontWeight: 700, letterSpacing: "0.06em", textTransform: "uppercase", color: "#374151" }}>
                Rejection Reason
              </label>
              <textarea
                rows={4}
                placeholder="e.g. Images are too low quality, please resubmit with clear photos..."
                value={rejectReason}
                onChange={(e) => { setRejectReason(e.target.value); setRejectError(""); }}
                style={{
                  width: "100%", padding: "12px 14px", border: `1.5px solid ${rejectError ? "#dc2626" : "#e5e7eb"}`,
                  borderRadius: 10, fontSize: 13, color: "#111827", resize: "vertical",
                  fontFamily: "inherit", outline: "none", boxSizing: "border-box",
                }}
              />
              {rejectError && (
                <p style={{ margin: 0, fontSize: 12, color: "#dc2626", fontWeight: 500 }}>
                  {rejectError}
                </p>
              )}
            </div>
            <div className="pd-confirm-actions">
              <button
                className="pd-confirm-cancel"
                onClick={() => setRejectTarget(null)}
                disabled={actionLoading}
              >
                Cancel
              </button>
              <button
                className="pd-confirm-delete"
                onClick={handleConfirmReject}
                disabled={actionLoading}
              >
                {actionLoading ? "Rejecting..." : "Confirm Reject"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* DELETE CONFIRM */}
      {deleteTarget && (
        <div className="pd-modal-overlay" onClick={() => setDeleteTarget(null)}>
          <div
            className="pd-confirm-modal"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="pd-confirm-icon">
              <svg
                width="26"
                height="26"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.8"
              >
                <polyline points="3 6 5 6 21 6" />
                <path d="M19 6l-1 14H6L5 6" />
                <path d="M10 11v6M14 11v6" />
                <path d="M9 6V4h6v2" />
              </svg>
            </div>
            <h3 className="pd-confirm-title">Delete Product?</h3>
            <p className="pd-confirm-desc">
              <strong>{deleteTarget.name}</strong> will be permanently removed.
              This cannot be undone.
            </p>
            <div className="pd-confirm-actions">
              <button
                className="pd-confirm-cancel"
                onClick={() => setDeleteTarget(null)}
                disabled={actionLoading}
              >
                Cancel
              </button>
              <button
                className="pd-confirm-delete"
                onClick={() => handleDelete(deleteTarget.id)}
                disabled={actionLoading}
              >
                {actionLoading ? "Deleting..." : "Yes, Delete"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProductDashboard;