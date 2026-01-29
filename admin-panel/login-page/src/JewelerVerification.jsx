import React, { useState } from "react";
import "./JewelerVerification.css";

const tabs = ["All Requests", "Pending", "Approved", "Rejected"];

const initialRequests = [
  {
    id: 1,
    initials: "GA",
    name: "Golden Aura Jewelry",
    email: "info@goldenaura.com",
    brn: "09201-X",
    submittedAt: "Oct 12, 2023",
    status: "Pending",
  },
  {
    id: 2,
    initials: "DD",
    name: "Diamond District Co.",
    email: "admin@dd.lk",
    brn: "88432-Z",
    submittedAt: "Oct 11, 2023",
    status: "Approved",
  },
  {
    id: 3,
    initials: "LJ",
    name: "Legacy Jewels",
    email: "team@legacyjewels.com",
    brn: "21234-L",
    submittedAt: "Oct 10, 2023",
    status: "Rejected",
  },
  {
    id: 4,
    initials: "OG",
    name: "Orchid Gem House",
    email: "info@orchidgems.biz",
    brn: "45621-P",
    submittedAt: "Oct 09, 2023",
    status: "Pending",
  },
  {
    id: 5,
    initials: "OG",
    name: "Orchid Gem House",
    email: "info@orchidgems.biz",
    brn: "45621-P",
    submittedAt: "Oct 09, 2023",
    status: "Pending",
  },
  {
    id: 6,
    initials: "DD",
    name: "Diamond District Co.",
    email: "admin@dd.lk",
    brn: "88432-Z",
    submittedAt: "Oct 11, 2023",
    status: "Approved",
  },
  {
    id: 7,
    initials: "DD",
    name: "Diamond District Co.",
    email: "admin@dd.lk",
    brn: "88432-Z",
    submittedAt: "Oct 11, 2023",
    status: "Approved",
  },
  {
    id: 8,
    initials: "DD",
    name: "Diamond District Co.",
    email: "admin@dd.lk",
    brn: "88432-Z",
    submittedAt: "Oct 11, 2023",
    status: "Approved",
  },
];

const statusClassMap = {
  Pending: "status-pill status-pending",
  Approved: "status-pill status-approved",
  Rejected: "status-pill status-rejected",
};

const JewelerVerification = () => {
  const [activeTab, setActiveTab] = useState("All Requests");
  const [search, setSearch] = useState("");

  const filteredRequests = initialRequests.filter((req) => {
    const matchesTab =
      activeTab === "All Requests" ? true : req.status === activeTab;
    const query = search.toLowerCase();
    const matchesSearch =
      !query ||
      req.name.toLowerCase().includes(query) ||
      req.email.toLowerCase().includes(query) ||
      req.brn.toLowerCase().includes(query);
    return matchesTab && matchesSearch;
  });

  return (
    <div className="verification-page">
      <div className="verification-header">
        <p className="verification-breadcrumb">
          Dashboard <span>/</span> Jeweler Verification
        </p>
        <h1>Jeweler Verification</h1>
        <p className="verification-subtitle">
          Review and approve business registration for upcoming jewelry
          partners.
        </p>
      </div>

      <div className="verification-toolbar">
        <div className="verification-tabs">
          {tabs.map((tab) => (
            <button
              key={tab}
              className={`verification-tab ${
                activeTab === tab ? "active" : ""
              }`}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
            </button>
          ))}
        </div>
        <div className="verification-actions-right">
          <button className="btn-outline">Export CSV</button>
          <button className="btn-primary">Refresh Table</button>
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
        <button className="btn-filters">Filters</button>
      </div>

      <div className="verification-card">
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
              {filteredRequests.map((req) => (
                <tr key={req.id}>
                  <td>
                    <div className="jeweler-cell">
                      <div className="avatar-circle">{req.initials}</div>
                      <div className="jeweler-text">
                        <p className="jeweler-name">{req.name}</p>
                        <p className="jeweler-email">{req.email}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className="brn-label">BRN:</span>{" "}
                    <span className="brn-value">{req.brn}</span>
                  </td>
                  <td>{req.submittedAt}</td>
                  <td>
                    <span className={statusClassMap[req.status]}>
                      <span className="status-dot" />
                      {req.status}
                    </span>
                  </td>
                  <td>
                    {req.status === "Approved" ? (
                      <button className="btn-dark">View</button>
                    ) : (
                      <button className="btn-dark">Review</button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="verification-footer-row">
          <p className="results-text">
            Showing 1 to {filteredRequests.length} of {initialRequests.length}{" "}
            results
          </p>
          <div className="pagination">
            <button className="page-btn">&lt;</button>
            <button className="page-btn active">1</button>
            <button className="page-btn">2</button>
            <button className="page-btn">3</button>
            <span className="page-ellipsis">...</span>
            <button className="page-btn">6</button>
            <button className="page-btn">&gt;</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default JewelerVerification;

