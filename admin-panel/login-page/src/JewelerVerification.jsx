import React, { useState, useEffect } from "react";
import "./JewelerVerification.css";
// ── CHANGED: added apiCall ──
import { getAllJewellers, approveJeweller, rejectJeweller, apiCall } from "./api/client";

const tabs = ["All Requests", "Pending", "Approved", "Rejected"];

const statusClassMap = {
  pending: "status-pill status-pending",
  approved: "status-pill status-approved",
  rejected: "status-pill status-rejected",
};

const formatDate = (dateStr) => {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
};

/* ─── Required documents ─── */
const REQUIRED_DOCUMENTS = [
  {
    key: "business_registration_cert",
    label: "Business Registration Certificate",
    description:
      "Issued by the Registrar of Companies confirming legal incorporation.",
  },
  {
    key: "tax_identification",
    label: "Tax Identification Number (TIN)",
    description: "Government-issued tax ID or VAT registration document.",
  },
  {
    key: "trade_license",
    label: "Trade / Operating License",
    description:
      "Municipal or provincial license permitting jewellery retail or wholesale.",
  },
  {
    key: "identity_proof",
    label: "Owner / Director Identity Proof",
    description:
      "National ID, passport, or driver's license of the primary business owner.",
  },
  {
    key: "address_proof",
    label: "Business Address Proof",
    description:
      "Utility bill, lease agreement, or official letter confirming business premises.",
  },
  {
    key: "hallmarking_cert",
    label: "Hallmarking / Assay Certificate",
    description:
      "Certification from an approved assay office for gold/silver quality standards.",
  },
  {
    key: "anti_money_laundering",
    label: "AML Compliance Declaration",
    description:
      "Signed declaration of compliance with Anti-Money Laundering regulations.",
  },
  {
    key: "bank_statement",
    label: "Bank Statement / Letter",
    description:
      "Recent 3-month bank statement or a letter of good standing from the bank.",
  },
];

/* ─── File viewer modal ─── */
const FileViewerModal = ({ file, label, onClose }) => {
  if (!file) return null;

  const isImage =
    typeof file === "string" && /\.(png|jpg|jpeg|gif|webp|svg)(\?.*)?$/i.test(file);
  const isPdf = typeof file === "string" && /\.pdf(\?.*)?$/i.test(file);
  const fileUrl = typeof file === "string" ? file : URL.createObjectURL(file);

  return (
    <>
      <div className="file-modal-backdrop" onClick={onClose} />
      <div className="file-modal">
        <div className="file-modal-header">
          <span className="file-modal-title">{label}</span>
          <button className="panel-close" onClick={onClose}>
            ✕
          </button>
        </div>
        <div className="file-modal-body">
          {isImage && (
            <img src={fileUrl} alt={label} className="file-preview-img" />
          )}
          {isPdf && (
            <iframe
              src={fileUrl}
              title={label}
              className="file-preview-iframe"
            />
          )}
          {!isImage && !isPdf && (
            <div className="file-preview-fallback">
              <div className="file-icon-big">📄</div>
              <p>{label}</p>
              <a
                href={fileUrl}
                target="_blank"
                rel="noreferrer"
                className="btn-panel-approve"
                style={{
                  textDecoration: "none",
                  display: "inline-block",
                  marginTop: 12,
                }}
              >
                Open File
              </a>
            </div>
          )}
        </div>
      </div>
    </>
  );
};

/* ─── Detail side-panel ─── */
const JewelerDetailPanel = ({
  jeweler,
  onClose,
  onApprove,
  onReject,
  actionLoading,
}) => {
  const [rejectReason, setRejectReason] = useState("");
  const [showRejectInput, setShowRejectInput] = useState(false);
  const [viewingFile, setViewingFile] = useState(null);

  // ── NEW: documents from DB, per-doc feedback, audit logs ──
  const [documents, setDocuments] = useState({});
  const [docFeedback, setDocFeedback] = useState({});
  const [feedbackInputs, setFeedbackInputs] = useState({});
  const [savingFeedback, setSavingFeedback] = useState(null);
  const [auditLogs, setAuditLogs] = useState([]);

  useEffect(() => {
    // Reset state when jeweler changes
    setShowRejectInput(false);
    setRejectReason("");
    // ── NEW: reset new state too ──
    setDocuments({});
    setDocFeedback({});
    setFeedbackInputs({});
    setAuditLogs([]);

    if (!jeweler) return;

    // ── NEW: fetch documents from jeweller_documents table ──
    apiCall(`/documents/${jeweler.id}`)
      .then((d) => {
        const docs = d.documents || {};
        setDocuments(docs);
        setDocFeedback(docs.feedback || {});
      })
      .catch(() => {});

    // ── NEW: fetch admin action logs ──
    apiCall(`/documents/${jeweler.id}/logs`)
      .then((d) => setAuditLogs(d.logs || []))
      .catch(() => {});
  }, [jeweler?.id]);

  if (!jeweler) return null;

  const status = (jeweler.verification_status || "pending").toLowerCase();
  const isApproved = status === "approved";
  const displayName = jeweler.business_name || jeweler.name || "Unknown";

  const handleRejectSubmit = () => {
    if (!rejectReason.trim()) return;
    onReject(jeweler.id, rejectReason.trim());
    setRejectReason("");
    setShowRejectInput(false);
  };

  // ── UPDATED: check fetched documents first, fall back to jeweler object ──
  const getDocStatus = (doc) => {
    if (isApproved) return true;
    return !!(documents[doc.key] || jeweler[doc.key] || jeweler.documents?.[doc.key]);
  };

  const getDocFile = (doc) =>
    documents[doc.key] || jeweler[doc.key] || jeweler.documents?.[doc.key] || null;

  // ── NEW: save per-document admin feedback ──
  const handleSaveFeedback = async (docKey) => {
    const text = (feedbackInputs[docKey] || "").trim();
    if (!text) return;
    setSavingFeedback(docKey);
    try {
      await apiCall(`/documents/${jeweler.id}/feedback`, {
        method: "POST",
        body: JSON.stringify({ document_key: docKey, feedback: text }),
      });
      setDocFeedback((prev) => ({
        ...prev,
        [docKey]: { message: text, created_at: new Date().toISOString() },
      }));
      setFeedbackInputs((prev) => ({ ...prev, [docKey]: "" }));
    } catch (err) {
      alert("Failed to save feedback: " + err.message);
    } finally {
      setSavingFeedback(null);
    }
  };

  return (
    <>
      {/* Backdrop */}
      <div className="panel-backdrop" onClick={onClose} />

      {/* Panel */}
      <div className="detail-panel">
        {/* ── Header ── */}
        <div className="panel-header">
          <div style={{ minWidth: 0 }}>
            <h2 className="panel-title">{displayName}</h2>
            <p className="panel-subtitle">{jeweler.email}</p>
          </div>
          <button className="panel-close" onClick={onClose} aria-label="Close">
            ✕
          </button>
        </div>

        {/* ── Status & date ── */}
        <div className="panel-status-row">
          <span
            className={statusClassMap[status] || "status-pill status-pending"}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </span>
          <span className="panel-date">
            Submitted {formatDate(jeweler.created_at)}
          </span>
        </div>

        {/* ── Business info ── */}
        <div className="panel-section">
          <h3 className="panel-section-title">Business Information</h3>
          <div className="panel-info-grid">
            <div className="panel-info-item">
              <span className="panel-info-label">Business Name</span>
              <span className="panel-info-value">
                {jeweler.business_name || "—"}
              </span>
            </div>

            <div className="panel-info-item">
              <span className="panel-info-label">Owner / Contact</span>
              <span className="panel-info-value">{jeweler.name || "—"}</span>
            </div>

            {/* Email — clickable mailto */}
            <div className="panel-info-item">
              <span className="panel-info-label">Email</span>
              {jeweler.email ? (
                <a
                  href={`mailto:${jeweler.email}`}
                  className="panel-contact-link panel-contact-email"
                  title={`Send email to ${jeweler.email}`}
                >
                  <span className="contact-icon">✉</span>
                  <span>{jeweler.email}</span>
                </a>
              ) : (
                <span className="panel-info-value">—</span>
              )}
            </div>

            {/* Phone — clickable tel */}
            <div className="panel-info-item">
              <span className="panel-info-label">Phone</span>
              {jeweler.phone ? (
                <a
                  href={`tel:${jeweler.phone}`}
                  className="panel-contact-link panel-contact-phone"
                  title={`Call ${jeweler.phone}`}
                >
                  <span className="contact-icon"></span>
                  <span>{jeweler.phone}</span>
                </a>
              ) : (
                <span className="panel-info-value">—</span>
              )}
            </div>

            <div className="panel-info-item">
              <span className="panel-info-label">BRN Number</span>
              <span className="panel-info-value">
                {jeweler.business_registration_number || "—"}
              </span>
            </div>

            <div className="panel-info-item">
              <span className="panel-info-label">Business Address</span>
              <span className="panel-info-value">{jeweler.address || "—"}</span>
            </div>
          </div>
        </div>

        {/* ── Documents ── */}
        <div className="panel-section">
          <h3 className="panel-section-title">Required Documents</h3>
          {isApproved && (
            <p className="panel-section-note panel-section-note-approved">
              ✓ All documents verified and accepted.
            </p>
          )}
          {!isApproved && (
            <p className="panel-section-note">
              Documents required for jewellery business registration and
              verification.
            </p>
          )}
          <div className="doc-list">
            {REQUIRED_DOCUMENTS.map((doc) => {
              const submitted = getDocStatus(doc);
              const file = getDocFile(doc);
              // ── NEW: per-doc saved feedback ──
              const feedback = docFeedback[doc.key];

              return (
                <div
                  key={doc.key}
                  className={`doc-item ${submitted ? "doc-submitted" : "doc-missing"}`}
                >
                  <div className="doc-icon">{submitted ? "✓" : "○"}</div>

                  <div className="doc-info">
                    <p className="doc-label">{doc.label}</p>
                    <p className="doc-desc">{doc.description}</p>
                    {/* ── NEW: show saved feedback below description ── */}
                    {feedback && (
                      <p className="doc-feedback-saved">💬 {feedback.message}</p>
                    )}
                    {/* ── NEW: feedback input row (pending/rejected, submitted docs only) ── */}
                    {submitted && !isApproved && (
                      <div className="doc-feedback-row">
                        <input
                          className="doc-feedback-input"
                          type="text"
                          placeholder="Add feedback for this document…"
                          value={feedbackInputs[doc.key] || ""}
                          onChange={(e) =>
                            setFeedbackInputs((prev) => ({
                              ...prev,
                              [doc.key]: e.target.value,
                            }))
                          }
                        />
                        <button
                          className="doc-feedback-btn"
                          onClick={() => handleSaveFeedback(doc.key)}
                          disabled={
                            savingFeedback === doc.key ||
                            !(feedbackInputs[doc.key] || "").trim()
                          }
                        >
                          {savingFeedback === doc.key ? "…" : "Send"}
                        </button>
                      </div>
                    )}
                  </div>

                  <div className="doc-right">
                    {submitted ? (
                      <>
                        <span className="badge-submitted">Submitted</span>
                        {/* View file button — shown when there's an actual file URL/object */}
                        {file && (
                          <button
                            className="btn-view-file"
                            onClick={() =>
                              setViewingFile({ file, label: doc.label })
                            }
                            title="View document"
                          >
                            View
                          </button>
                        )}
                      </>
                    ) : (
                      <span className="badge-missing">Missing</span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* ── Rejection reason (if any) ── */}
        {jeweler.rejection_reason && (
          <div className="panel-section">
            <h3 className="panel-section-title">Rejection Reason</h3>
            <div className="rejection-reason-box">
              {jeweler.rejection_reason}
            </div>
          </div>
        )}

        {/* ── NEW: Action history — only shown when logs exist ── */}
        {auditLogs.length > 0 && (
          <div className="panel-section">
            <h3 className="panel-section-title">Action History</h3>
            <ul className="audit-log-list">
              {auditLogs.map((log) => (
                <li key={log.id} className="audit-log-item">
                  <span className={`audit-log-action audit-log-${log.action}`}>
                    {log.action === "approved" && "✓ Approved"}
                    {log.action === "rejected" && "✕ Rejected"}
                    {log.action === "document_feedback" && "💬 Feedback sent"}
                    {!["approved", "rejected", "document_feedback"].includes(log.action) && log.action}
                  </span>
                  {log.details?.reason && (
                    <span className="audit-log-detail"> — {log.details.reason}</span>
                  )}
                  {log.details?.document_key && (
                    <span className="audit-log-detail">
                      {" "}— {log.details.document_key.replace(/_/g, " ")}
                    </span>
                  )}
                  <span className="audit-log-time">
                    {new Date(log.performed_at).toLocaleString("en-US", {
                      month: "short",
                      day: "numeric",
                      year: "numeric",
                      hour: "numeric",
                      minute: "2-digit",
                    })}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        )}

        {/* ── Actions ──
            • Approved  → show only Reject (to revoke approval)
            • Pending / Rejected → show Approve + Reject
        ── */}
        <div className="panel-actions">
          {isApproved ? (
            /* Approved: only Reject available */
            !showRejectInput ? (
              <button
                className="btn-panel-reject"
                onClick={() => setShowRejectInput(true)}
                disabled={!!actionLoading}
                style={{ flex: 1 }}
              >
                ✕ Revoke Approval
              </button>
            ) : (
              <div className="reject-input-block">
                <textarea
                  className="reject-textarea"
                  placeholder="Enter reason for revoking approval…"
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                  rows={3}
                />
                <div className="reject-input-actions">
                  <button
                    className="btn-panel-reject"
                    onClick={handleRejectSubmit}
                    disabled={!rejectReason.trim() || !!actionLoading}
                  >
                    {actionLoading === jeweler.id + "_reject"
                      ? "Processing…"
                      : "Confirm Revoke"}
                  </button>
                  <button
                    className="btn-panel-cancel"
                    onClick={() => {
                      setShowRejectInput(false);
                      setRejectReason("");
                    }}
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )
          ) : /* Pending / Rejected: Approve + Reject */
          !showRejectInput ? (
            <>
              <button
                className="btn-panel-approve"
                onClick={() => onApprove(jeweler.id)}
                disabled={!!actionLoading}
              >
                {actionLoading === jeweler.id + "_approve"
                  ? "Approving…"
                  : "✓ Approve"}
              </button>
              <button
                className="btn-panel-reject"
                onClick={() => setShowRejectInput(true)}
                disabled={!!actionLoading}
              >
                ✕ Reject
              </button>
            </>
          ) : (
            <div className="reject-input-block">
              <textarea
                className="reject-textarea"
                placeholder="Enter reason for rejection…"
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                rows={3}
              />
              <div className="reject-input-actions">
                <button
                  className="btn-panel-reject"
                  onClick={handleRejectSubmit}
                  disabled={!rejectReason.trim() || !!actionLoading}
                >
                  {actionLoading === jeweler.id + "_reject"
                    ? "Rejecting…"
                    : "Confirm Reject"}
                </button>
                <button
                  className="btn-panel-cancel"
                  onClick={() => {
                    setShowRejectInput(false);
                    setRejectReason("");
                  }}
                >
                  Cancel
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* ── File viewer modal ── */}
      {viewingFile && (
        <FileViewerModal
          file={viewingFile.file}
          label={viewingFile.label}
          onClose={() => setViewingFile(null)}
        />
      )}
    </>
  );
};

/* ─── Main component ─── */
const JewelerVerification = ({ defaultTab = "All Requests" }) => {
  const [activeTab, setActiveTab] = useState(defaultTab);
  const [search, setSearch] = useState("");
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [actionLoading, setActionLoading] = useState(null);
  const [selectedJeweler, setSelectedJeweler] = useState(null);

  const fetchJewellers = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getAllJewellers();
      setRequests(data.jewellers || []);
    } catch (err) {
      setError("Failed to load jewellers. Is the backend running?");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchJewellers();
  }, []);

  const handleApprove = async (id) => {
    setActionLoading(id + "_approve");
    try {
      await approveJeweller(id);
      await fetchJewellers();
      setSelectedJeweler(null);
    } catch (err) {
      alert("Failed to approve jeweller: " + err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (id, reason) => {
    setActionLoading(id + "_reject");
    try {
      await rejectJeweller(id, reason);
      await fetchJewellers();
      setSelectedJeweler(null);
    } catch (err) {
      alert("Failed to reject jeweller: " + err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const tabToStatus = {
    Pending: "pending",
    Approved: "approved",
    Rejected: "rejected",
  };

  const filteredRequests = requests.filter((req) => {
    const reqStatus = (req.verification_status || "").toLowerCase();
    const matchesTab =
      activeTab === "All Requests"
        ? true
        : reqStatus === tabToStatus[activeTab];
    const query = search.toLowerCase();
    const matchesSearch =
      !query ||
      (req.name || "").toLowerCase().includes(query) ||
      (req.email || "").toLowerCase().includes(query) ||
      (req.business_registration_number || "").toLowerCase().includes(query) ||
      (req.business_name || "").toLowerCase().includes(query);
    return matchesTab && matchesSearch;
  });

  // ── NEW: pending count for badge ──
  const pendingCount = requests.filter(
    (r) => r.verification_status === "pending"
  ).length;

  return (
    <div className="verification-page">
      {/* ── Header ── */}
      <div className="verification-header">
        <h1>Jeweler Verification</h1>
        {/* <button className="btn-register">Register Jeweler</button> */}
      </div>

      {/* ── Tabs ── */}
      <div className="verification-toolbar">
        <div className="verification-tabs">
          {tabs.map((tab) => (
            <button
              key={tab}
              className={`verification-tab ${activeTab === tab ? "active" : ""}`}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
              {/* ── NEW: badge only on Pending tab ── */}
              {tab === "Pending" && pendingCount > 0 && (
                <span className="tab-pending-badge">{pendingCount}</span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* ── Search / Filter ── */}
      <div className="verification-filters-row">
        <div className="verification-search">
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
            placeholder="Search by jeweler name, BRN number or email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        {/* <button className="btn-filters" onClick={() => setSearch("")}>
          Filter
        </button> */}
      </div>

      {/* ── Table card ── */}
      <div className="verification-card">
        {loading ? (
          <div style={{ padding: "2rem", textAlign: "center", color: "#888" }}>
            Loading jewellers…
          </div>
        ) : error ? (
          <div
            style={{ padding: "2rem", textAlign: "center", color: "#c0392b" }}
          >
            {error}
            <br />
            <button
              className="btn-dark"
              style={{ marginTop: "1rem" }}
              onClick={fetchJewellers}
            >
              Retry
            </button>
          </div>
        ) : (
          <div className="verification-table-wrapper">
            <table className="verification-table">
              <thead>
                <tr>
                  <th>JEWELER NAME</th>
                  <th>BRN NUMBER</th>
                  <th>SUBMISSION DATE</th>
                  <th>STATUS</th>
                  <th>ACTIONS</th>
                </tr>
              </thead>
              <tbody>
                {filteredRequests.length === 0 ? (
                  <tr>
                    <td
                      colSpan={5}
                      style={{
                        textAlign: "center",
                        padding: "2rem",
                        color: "#888",
                      }}
                    >
                      No jewellers found.
                    </td>
                  </tr>
                ) : (
                  filteredRequests.map((req) => {
                    const status = (
                      req.verification_status || "pending"
                    ).toLowerCase();
                    const displayName =
                      req.business_name || req.name || "Unknown";
                    return (
                      <tr key={req.id}>
                        <td>
                          <div className="jeweler-cell">
                            <div className="jeweler-text">
                              <p className="jeweler-name">{displayName}</p>
                              <p className="jeweler-email">{req.email}</p>
                            </div>
                          </div>
                        </td>
                        <td>
                          <span className="brn-label">BRN:</span>{" "}
                          <span className="brn-value">
                            {req.business_registration_number || "—"}
                          </span>
                        </td>
                        <td>{formatDate(req.created_at)}</td>
                        <td>
                          <span
                            className={
                              statusClassMap[status] ||
                              "status-pill status-pending"
                            }
                          >
                            {status.charAt(0).toUpperCase() + status.slice(1)}
                          </span>
                        </td>
                        <td>
                          <button
                            className="btn-dark"
                            onClick={() => setSelectedJeweler(req)}
                          >
                            {status === "approved" ? "View" : "Review"}
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        )}

        <div className="verification-footer-row">
          <p className="results-text">
            Showing {filteredRequests.length} of {requests.length} results
          </p>
        </div>
      </div>

      {/* ── Detail Side Panel ── */}
      <JewelerDetailPanel
        jeweler={selectedJeweler}
        onClose={() => setSelectedJeweler(null)}
        onApprove={handleApprove}
        onReject={handleReject}
        actionLoading={actionLoading}
      />
    </div>
  );
};

export default JewelerVerification;