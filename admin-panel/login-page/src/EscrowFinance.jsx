import React, { useState } from "react";
import "./EscrowFinance.css";

const transactions = [
  { id: "ESC-1042", orderId: "ORD-8492", jeweler: "Golden Aura Jewelry", buyer: "Amara Silva", amount: 48000.00, held: "Oct 14, 2023", release: "Oct 28, 2023", status: "Held" },
  { id: "ESC-1041", orderId: "ORD-8491", jeweler: "Diamond District Co.", buyer: "Ravi Perera", amount: 12000.00, held: "Oct 13, 2023", release: "Oct 27, 2023", status: "Released" },
  { id: "ESC-1040", orderId: "ORD-8490", jeweler: "Legacy Jewels", buyer: "Nisha Fernando", amount: 85000.00, held: "Oct 13, 2023", release: "Oct 27, 2023", status: "Released" },
  { id: "ESC-1039", orderId: "ORD-8489", jeweler: "Orchid Gem House", buyer: "Kiran Jayasena", amount: 180000.00, held: "Oct 12, 2023", release: "Oct 26, 2023", status: "Disputed" },
  { id: "ESC-1038", orderId: "ORD-8488", jeweler: "Sunrise Jewels", buyer: "Dulani Wickrama", amount: 320000.00, held: "Oct 12, 2023", release: "Oct 26, 2023", status: "Held" },
  { id: "ESC-1037", orderId: "ORD-8487", jeweler: "Crystal Ridge", buyer: "Tharidu Saman", amount: 62000.00, held: "Oct 11, 2023", release: "—", status: "Refunded" },
  { id: "ESC-1036", orderId: "ORD-8486", jeweler: "Golden Aura Jewelry", buyer: "Mala Gunawardena", amount: 210000.00, held: "Oct 10, 2023", release: "Oct 24, 2023", status: "Released" },
];

const statusMap = {
  Held:     "ef-pill ef-held",
  Released: "ef-pill ef-released",
  Disputed: "ef-pill ef-disputed",
  Refunded: "ef-pill ef-refunded",
};

const EscrowFinance = () => {
  const [activeTab, setActiveTab] = useState("All");
  const tabs = ["All", "Held", "Released", "Disputed", "Refunded"];

  const filtered = transactions.filter((t) => activeTab === "All" || t.status === activeTab);

  const summaryCards = [
    { label: "Total Escrow Balance", value: "LKR 1,134,200" },
    { label: "Currently Held", value: "LKR 248,600" },
    { label: "Released This Month", value: "LKR 782,400" },
    { label: "Disputed Funds", value: "LKR 12,800" },
    { label: "Platform Commission", value: "LKR 34,120" },
  ];

  return (
    <div className="ef-page">
      <div className="ef-page-header">
        <h1>Escrow &amp; Finance</h1>
        <button className="ef-report-btn">
          Generate Report
        </button>
      </div>

      <div className="ef-summary-grid">
        {summaryCards.map((c, i) => (
          <div key={i} className="ef-summary-card">
            <div>
              <p className="ef-summary-label">{c.label}</p>
              <p className="ef-summary-value">{c.value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="ef-toolbar">
        <div className="ef-tabs">
          {tabs.map((tab) => (
            <button key={tab} className={`ef-tab ${activeTab === tab ? "active" : ""}`} onClick={() => setActiveTab(tab)}>{tab}</button>
          ))}
        </div>
      </div>

      <div className="ef-card">
        <div className="ef-table-wrapper">
          <table className="ef-table">
            <thead>
              <tr>
                <th>ESCROW ID</th>
                <th>ORDER</th>
                <th>JEWELER</th>
                <th>BUYER</th>
                <th>AMOUNT</th>
                <th>DATE HELD</th>
                <th>RELEASE DATE</th>
                <th>STATUS</th>
                <th>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((t) => (
                <tr key={t.id}>
                  <td className="ef-id">{t.id}</td>
                  <td className="ef-order-id">{t.orderId}</td>
                  <td className="ef-jeweler">{t.jeweler}</td>
                  <td className="ef-buyer">{t.buyer}</td>
                  <td className="ef-amount">LKR {t.amount.toLocaleString("en-LK", { maximumFractionDigits: 2 })}</td>
                  <td className="ef-date">{t.held}</td>
                  <td className="ef-date">{t.release}</td>
                  <td>
                    <span className={statusMap[t.status]}>
                      <span />
                      {t.status}
                    </span>
                  </td>
                  <td>
                    <div className="ef-action-row">
                      {t.status === "Held" && <button className="ef-release-btn">Release</button>}
                      <button className="ef-view-btn">View</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="ef-footer-row">
          <p className="ef-results-text">Showing {filtered.length} of {transactions.length} transactions</p>
        </div>
      </div>
    </div>
  );
};

export default EscrowFinance;
