import React, { useState, useEffect } from "react";
import "./JewelerVerification.css";
import { getAllJewellers, approveJeweller, rejectJeweller } from "./api/client";

const tabs = ["All Requests", "Pending", "Approved", "Rejected"];

const statusClassMap = {
  pending:  "status-pill status-pending",
  approved: "status-pill status-approved",
  rejected: "status-pill status-rejected",
};

const formatDate = (dateStr) => {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("en-US", {
    month: "short", day: "numeric", year: "numeric",
  });
};

const JewelerVerification = ({ defaultTab = "All Requests" }) => {
  const [activeTab, setActiveTab]         = useState(defaultTab);
  const [search, setSearch]               = useState("");
  const [requests, setRequests]           = useState([]);
  const [loading, setLoading]             = useState(true);
  const [error, setError]                 = useState(null);
  const [actionLoading, setActionLoading] = useState(null);

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

  useEffect(() => { fetchJewellers(); }, []);

  const handleApprove = async (id) => {
    if (!window.confirm("Approve this jeweller?")) return;
    setActionLoading(id + "_approve");
    try {
      await approveJeweller(id);
      await fetchJewellers();
    } catch (err) {
      alert("Failed to approve jeweller: " + err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (id) => {
    const reason = window.prompt("Enter rejection reason:");
    if (!reason || !reason.trim()) return;
    setActionLoading(id + "_reject");
    try {
      await rejectJeweller(id, reason.trim());
      await fetchJewellers();
    } catch (err) {
      alert("Failed to reject jeweller: " + err.message);
    } finally {
      setActionLoading(null);
    }
  };

  const tabToStatus = { "Pending": "pending", "Approved": "approved", "Rejected": "rejected" };

  const filteredRequests = requests.filter((req) => {
    const reqStatus = (req.verification_status || "").toLowerCase();
    const matchesTab = activeTab === "All Requests" ? true : reqStatus === tabToStatus[activeTab];
    const query = search.toLowerCase();
    const matchesSearch =
      !query ||
      (req.name || "").toLowerCase().includes(query) ||
      (req.email || "").toLowerCase().includes(query) ||
      (req.business_registration_number || "").toLowerCase().includes(query) ||
      (req.business_name || "").toLowerCase().includes(query);
    return matchesTab && matchesSearch;
  });

  return (
    <div className="verification-page">
      <div className="verification-header">
        <h1>Jeweler Verification</h1>
        <button className="btn-register" onClick={fetchJewellers}>↻ Refresh</button>
      </div>

      <div className="verification-toolbar">
        <div className="verification-tabs">
          {tabs.map((tab) => (
            <button
              key={tab}
              className={`verification-tab ${activeTab === tab ? "active" : ""}`}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      <div className="verification-filters-row">
        <div className="verification-search">
          <input
            type="text"
            placeholder="Search by jeweler name, BRN number or email..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <button className="btn-filters" onClick={() => setSearch("")}>Clear</button>
      </div>

      <div className="verification-card">
        {loading ? (
          <div style={{ padding: "2rem", textAlign: "center", color: "#888" }}>
            Loading jewellers...
          </div>
        ) : error ? (
          <div style={{ padding: "2rem", textAlign: "center", color: "#c0392b" }}>
            {error}
            <br />
            <button className="btn-dark" style={{ marginTop: "1rem" }} onClick={fetchJewellers}>
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
                    <td colSpan={5} style={{ textAlign: "center", padding: "2rem", color: "#888" }}>
                      No jewellers found.
                    </td>
                  </tr>
                ) : (
                  filteredRequests.map((req) => {
                    const status = (req.verification_status || "pending").toLowerCase();
                    return (
                      <tr key={req.id}>
                        <td>
                          <div className="jeweler-cell">
                            <div className="jeweler-text">
                              <p className="jeweler-name">{req.business_name || req.name}</p>
                              <p className="jeweler-email">{req.email}</p>
                            </div>
                          </div>
                        </td>
                        <td>
                          <span className="brn-label">BRN:</span>{" "}
                          <span className="brn-value">{req.business_registration_number || "—"}</span>
                        </td>
                        <td>{formatDate(req.created_at)}</td>
                        <td>
                          <span className={statusClassMap[status] || "status-pill status-pending"}>
                            <span />
                            {status.charAt(0).toUpperCase() + status.slice(1)}
                          </span>
                        </td>
                        <td>
                          {status === "approved" ? (
                            <button className="btn-dark">View</button>
                          ) : status === "pending" ? (
                            <div style={{ display: "flex", gap: "6px" }}>
                              <button
                                className="btn-dark"
                                disabled={!!actionLoading}
                                onClick={() => handleApprove(req.id)}
                                style={{ background: "#27ae60", color: "#fff", border: "none" }}
                              >
                                {actionLoading === req.id + "_approve" ? "..." : "Approve"}
                              </button>
                              <button
                                className="btn-dark"
                                disabled={!!actionLoading}
                                onClick={() => handleReject(req.id)}
                                style={{ background: "#e74c3c", color: "#fff", border: "none" }}
                              >
                                {actionLoading === req.id + "_reject" ? "..." : "Reject"}
                              </button>
                            </div>
                          ) : (
                            <button className="btn-dark">View</button>
                          )}
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
    </div>
  );
};

export default JewelerVerification;
