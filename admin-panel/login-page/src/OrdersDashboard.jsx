import React, { useState } from "react";
// import "./OrdersDashboard.css";

const tabs = ["All Orders", "Pending", "Processing", "Shipped", "Delivered", "Cancelled"];

const orders = [
  { id: "ORD-8492", customer: "Amara Silva", email: "amara@email.com", initials: "AS", jeweler: "Golden Aura Jewelry", item: "Diamond Ring 2ct", amount: 4800.00, date: "Oct 14, 2023", status: "Processing" },
  { id: "ORD-8491", customer: "Ravi Perera", email: "ravi@email.com", initials: "RP", jeweler: "Diamond District Co.", item: "Gold Cuban Link", amount: 1200.00, date: "Oct 13, 2023", status: "Delivered" },
  { id: "ORD-8490", customer: "Nisha Fernando", email: "nisha@email.com", initials: "NF", jeweler: "Legacy Jewels", item: "Pearl Drop Earrings", amount: 850.00, date: "Oct 13, 2023", status: "Shipped" },
  { id: "ORD-8489", customer: "Kiran Jayasena", email: "kiran@email.com", initials: "KJ", jeweler: "Orchid Gem House", item: "Emerald Band Platinum", amount: 1800.00, date: "Oct 12, 2023", status: "Pending" },
  { id: "ORD-8488", customer: "Dulani Wickrama", email: "dulani@email.com", initials: "DW", jeweler: "Sunrise Jewels", item: "Sapphire Tennis Bracelet", amount: 3200.00, date: "Oct 12, 2023", status: "Processing" },
  { id: "ORD-8487", customer: "Tharidu Saman", email: "tharidu@email.com", initials: "TS", jeweler: "Crystal Ridge", item: "Rose Gold Bangle Set", amount: 620.00, date: "Oct 11, 2023", status: "Cancelled" },
  { id: "ORD-8486", customer: "Mala Gunawardena", email: "mala@email.com", initials: "MG", jeweler: "Golden Aura Jewelry", item: "White Gold Necklace", amount: 2100.00, date: "Oct 10, 2023", status: "Delivered" },
  { id: "ORD-8485", customer: "Shan Bandara", email: "shan@email.com", initials: "SB", jeweler: "Diamond District Co.", item: "Diamond Stud Set", amount: 1650.00, date: "Oct 10, 2023", status: "Pending" },
];

const statusClassMap = {
  Pending:    "",
  Processing: "",
  Shipped:    "",
  Delivered:  "",
  Cancelled:  "",
};

const OrdersDashboard = () => {
  const [activeTab, setActiveTab] = useState("All Orders");
  const [search, setSearch] = useState("");

  const filtered = orders.filter((o) => {
    const matchesTab = activeTab === "All Orders" ? true : o.status === activeTab;
    const q = search.toLowerCase();
    return matchesTab && (!q || o.id.toLowerCase().includes(q) || o.customer.toLowerCase().includes(q) || o.item.toLowerCase().includes(q));
  });

  const summary = [
    { label: "Total Orders", value: "10" },
    { label: "Pending", value: "20" },
    { label: "Processing", value: "21" },
    { label: "Delivered", value: "64" },
    { label: "Cancelled", value: "41" },
  ];

  return (
    <div >
      <div >
        <h1>Orders Management</h1>
        <button >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
          </svg>
          Export
        </button>
      </div>

      <div >
        {summary.map((s, i) => (
          <div key={i} >
            <p >{s.label}</p>
            <p >{s.value}</p>
          </div>
        ))}
      </div>

      <div >
        <div>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" placeholder="Search by order ID, customer or item..." value={search} onChange={(e) => setSearch(e.target.value)} className="os-search-input" />
        </div>
        <button>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
          Filter
        </button>
        <button>Refresh Table</button>
      </div>
        <div>
          <p>Showing {filtered.length} of {orders.length} results</p>
        </div>
      </div>
  );
};

export default OrdersDashboard;
