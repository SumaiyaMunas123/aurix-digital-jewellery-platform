import React, { useState } from "react";
import "./ProductDashboard.css";

const ProductDashboard = ({ defaultFilter = "All Categories" }) => {
  const [activeTab, setActiveTab] = useState("All Products");
  const [searchQuery, setSearchQuery] = useState("");

  const tabs = ["All Products", "Approved", "Pending", "Flagged", "Rejected"];

  const stats = [
    { label: "TOTAL PRODUCTS", value: "1,284" },
    { label: "PENDING REVIEW", value: "42" },
    { label: "APPROVED", value: "1,150" },
    { label: "REJECTED", value: "12" },
    { label: "FLAGGED", value: "80" },
  ];

  const products = [
    {
      id: 1,
      image: "",
      name: "Diamond Solitaire Ring 1ct",
      description: "18k White Gold • Round Cut",
      sku: "SKU-DR-001",
      category: "RINGS",
      price: 250000.0,
      stock: 15,
      status: "APPROVED",
    },
    {
      id: 2,
      image: "",
      name: "18k Gold Cuban Link",
      description: "22-Inch • Solid Gold",
      sku: "SKU-GC-042",
      category: "NECKLACES",
      price: 120000.0,
      stock: 8,
      status: "PENDING",
    },
    {
      id: 3,
      image: "",
      name: "South Sea Pearl Drop",
      description: "Tahitian Grade AA • Pair",
      sku: "SKU-PE-015",
      category: "EARRINGS",
      price: 85000.0,
      stock: 20,
      status: "APPROVED",
    },
    {
      id: 4,
      image: "",
      name: "Square Cut Emerald Band",
      description: "Natural Colombian • Platinum",
      sku: "SKU-ES-822",
      category: "RINGS",
      price: 180000.0,
      stock: 0,
      status: "FLAGGED",
    },
    {
      id: 5,
      image: "",
      name: "Rose Gold Bangle Set",
      description: "14k Rose Gold • Set of 3",
      sku: "SKU-BG-103",
      category: "BRACELETS",
      price: 620000.0,
      stock: 5,
      status: "PENDING",
    },
    {
      id: 6,
      image: "",
      name: "Sapphire Tennis Bracelet",
      description: "Natural Ceylon • Silver",
      sku: "SKU-TB-211",
      category: "BRACELETS",
      price: 32000.0,
      stock: 3,
      status: "APPROVED",
    },
    {
      id: 7,
      image: "",
      name: "Ruby Stud Earrings",
      description: "Burmese Ruby • 18k Gold",
      sku: "SKU-RU-309",
      category: "EARRINGS",
      price: 95000.0,
      stock: 0,
      status: "REJECTED",
    },
    {
      id: 8,
      image: "",
      name: "Platinum Wedding Band",
      description: "950 Platinum • 4mm",
      sku: "SKU-WB-441",
      category: "RINGS",
      price: 75000.0,
      stock: 12,
      status: "REJECTED",
    },
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case "APPROVED": return "status-approved";
      case "PENDING":  return "status-pending";
      case "FLAGGED":  return "status-flagged";
      case "REJECTED": return "status-rejected";
      default: return "";
    }
  };

  // Filter by tab
  const tabFiltered = activeTab === "All Products"
    ? products
    : products.filter((p) => p.status === activeTab.toUpperCase());

  // Filter by search
  const filtered = searchQuery.trim() === ""
    ? tabFiltered
    : tabFiltered.filter((p) =>
        p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.sku.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.category.toLowerCase().includes(searchQuery.toLowerCase())
      );

  return (
    <div className="pd-container">
      <div className="pd-header">
        <h1>Product Management</h1>
      </div>

      <div className="pd-stats-grid">
        {stats.map((stat, index) => (
          <div key={index} className="pd-stat-card">
            <div className="pd-stat-label">{stat.label}</div>
            <div className="pd-stat-value-row">
              <div className="pd-stat-value">{stat.value}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="pd-controls-bar">
        <div className="od-tabs">
          {tabs.map((tab) => (
            <button
              key={tab}
              className={`od-tab ${activeTab === tab ? "active" : ""}`}
              onClick={() => setActiveTab(tab)}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      <div className="pd-search-filter-bar">
        <div className="pd-search-wrap">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
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

      <div className="pd-table-wrapper">
        <table className="pd-table">
          <thead>
            <tr>
              <th>IMAGE</th>
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
            {filtered.length === 0 ? (
              <tr>
                <td colSpan="8" className="pd-empty">
                  No products found.
                </td>
              </tr>
            ) : (
              filtered.map((product) => (
                <tr key={product.id}>
                  <td>
                    <div className="pd-product-image">{product.image}</div>
                  </td>
                  <td>
                    <div className="pd-name-cell">
                      <div className="pd-product-name">{product.name}</div>
                      <div className="pd-product-desc">{product.description}</div>
                    </div>
                  </td>
                  <td className="pd-sku">{product.sku}</td>
                  <td>
                    <span className="pd-category-badge">{product.category}</span>
                  </td>
                  <td className="pd-price">
                    LKR{" "}
                    {product.price.toLocaleString("en-LK", { maximumFractionDigits: 2 })}
                  </td>
                  <td className={`pd-stock ${product.stock === 0 ? "out-of-stock" : ""}`}>
                    {product.stock === 0 ? "Out of Stock" : product.stock}
                  </td>
                  <td>
                    <span className={`pd-status-badge ${getStatusColor(product.status)}`}>
                      {product.status}
                    </span>
                  </td>
                  <td>
                    <div className="pd-action-group">
                      <button className="pd-action-icon" title="View">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                          <circle cx="12" cy="12" r="3" />
                        </svg>
                      </button>
                      <button className="pd-action-icon" title="Edit">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                        </svg>
                      </button>
                      <button className="pd-action-icon danger" title="Delete">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <polyline points="3 6 5 6 21 6" />
                          <path d="M19 6l-1 14H6L5 6" />
                          <path d="M10 11v6M14 11v6" />
                          <path d="M9 6V4h6v2" />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
        <div className="pd-pagination">
          <p className="pd-pagination-info">
            Showing <strong>{filtered.length}</strong> of <strong>{products.length}</strong> products
          </p>
          <div className="pd-pagination-controls">
            {["‹", "1", "2", "3", "›"].map((p, i) => (
              <button key={i} className={`pd-page-btn ${p === "1" ? "active" : ""}`}>
                {p}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDashboard;