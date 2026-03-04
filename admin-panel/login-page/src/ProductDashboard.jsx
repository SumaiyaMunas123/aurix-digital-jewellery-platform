import React, { useState } from 'react';
import './ProductDashboard.css';

const ProductDashboard = ({ defaultFilter = "All Categories" }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedFilter, setSelectedFilter] = useState(defaultFilter);
  const [viewMode, setViewMode] = useState('list');

  const stats = [
    { label: 'TOTAL PRODUCTS', value: '1,284' },
    { label: 'PENDING REVIEW',  value: '42'  },
    { label: 'APPROVED',        value: '1,150'},
    { label: 'REJECTED',        value: '12'},
    { label: 'FLAGGED',         value: '80'},
  ];

  const products = [
    { id: 1, image: '', name: 'Diamond Solitaire Ring 1ct', description: '18k White Gold • Round Cut', sku: 'SKU-DR-001', category: 'RINGS', price: 2500.00, stock: 15, status: 'APPROVED' },
    { id: 2, image: '', name: '18k Gold Cuban Link', description: '22-Inch • Solid Gold', sku: 'SKU-GC-042', category: 'NECKLACES', price: 1200.00, stock: 8, status: 'PENDING' },
    { id: 3, image: '', name: 'South Sea Pearl Drop', description: 'Tahitian Grade AA • Pair', sku: 'SKU-PE-015', category: 'EARRINGS', price: 850.00, stock: 20, status: 'APPROVED' },
    { id: 4, image: '', name: 'Square Cut Emerald Band', description: 'Natural Colombian • Platinum', sku: 'SKU-ES-822', category: 'RINGS', price: 1800.00, stock: 0, status: 'FLAGGED' },
    { id: 5, image: '', name: 'Rose Gold Bangle Set', description: '14k Rose Gold • Set of 3', sku: 'SKU-BG-103', category: 'BRACELETS', price: 620.00, stock: 5, status: 'PENDING' },
    { id: 6, image: '', name: 'Sapphire Tennis Bracelet', description: 'Natural Ceylon • Silver', sku: 'SKU-TB-211', category: 'BRACELETS', price: 3200.00, stock: 3, status: 'APPROVED' },
  ];

  const getTrendIcon = (trend) => {
    if (trend === 'up') return '';
    if (trend === 'down') return '';
    return '';
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'APPROVED': return 'status-approved';
      case 'PENDING':  return 'status-pending';
      case 'FLAGGED':  return 'status-flagged';
      default: return '';
    }
  };

  return (
    <div className="pd-container">
      <div className="pd-header">
        <h1>Product Management</h1>
        <button className="pd-add-btn"><span>+</span> Add Product</button>
      </div>

      <div className="pd-stats-grid">
        {stats.map((stat, index) => (
          <div key={index} className="pd-stat-card">
            <div className="pd-stat-label">{stat.label}</div>
            <div className="pd-stat-value-row">
              <div className="pd-stat-value">{stat.value}</div>
              <div className={`pd-stat-change ${stat.trend}`}>
                <span className="trend-icon">{getTrendIcon(stat.trend)}</span>
                {stat.change}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="pd-controls-bar">
        <div className="pd-controls-left">
          <button className={`pd-view-btn ${viewMode === 'list' ? 'active' : ''}`} onClick={() => setViewMode('list')} title="List view">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
          </button>
          <button className={`pd-view-btn ${viewMode === 'grid' ? 'active' : ''}`} onClick={() => setViewMode('grid')} title="Grid view">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 3h7v7H3zM14 3h7v7h-7zM14 14h7v7h-7zM3 14h7v7H3z"/></svg>
          </button>
          <div className="pd-filter-group">
            {['All Categories', 'In Stock', 'Pending'].map((f) => (
              <button key={f} className={`pd-filter-btn ${selectedFilter === f ? 'active' : ''}`} onClick={() => setSelectedFilter(f)}>{f}</button>
            ))}
          </div>
        </div>
        <div className="pd-search-wrap">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" placeholder="Search products..." className="pd-search" />
        </div>
      </div>

      <div className="pd-table-wrapper">
        <table className="pd-table">
          <thead>
            <tr><th>IMAGE</th><th>PRODUCT NAME</th><th>SKU</th><th>CATEGORY</th><th>PRICE</th><th>STOCK</th><th>STATUS</th><th>ACTIONS</th></tr>
          </thead>
          <tbody>
            {products.map((product) => (
              <tr key={product.id}>
                <td><div className="pd-product-image">{product.image}</div></td>
                <td>
                  <div className="pd-name-cell">
                    <div className="pd-product-name">{product.name}</div>
                    <div className="pd-product-desc">{product.description}</div>
                  </div>
                </td>
                <td className="pd-sku">{product.sku}</td>
                <td><span className="pd-category-badge">{product.category}</span></td>
                <td className="pd-price">${product.price.toLocaleString('en-US', { minimumFractionDigits: 2 })}</td>
                <td className={`pd-stock ${product.stock === 0 ? 'out-of-stock' : ''}`}>{product.stock === 0 ? 'Out of Stock' : product.stock}</td>
                <td><span className={`pd-status-badge ${getStatusColor(product.status)}`}>{product.status}</span></td>
                <td>
                  <div className="pd-action-group">
                    <button className="pd-action-icon" title="View">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                    <button className="pd-action-icon" title="Edit">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    </button>
                    <button className="pd-action-icon danger" title="Delete">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="pd-pagination">
        <div className="pd-pagination-info">Showing <strong>1</strong> to <strong>6</strong> of <strong>1,284</strong> entries</div>
        <div className="pd-pagination-controls">
          {['‹', '1', '2', '3', '›'].map((p, i) => (
            <button key={i} className={`pd-page-btn ${p === '1' ? 'active' : ''}`}>{p}</button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ProductDashboard;
