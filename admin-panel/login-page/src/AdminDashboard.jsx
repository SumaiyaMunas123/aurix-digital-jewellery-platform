import React, { useState, useEffect } from "react";
import "./AdminDashboard.css";
import Footer from "./Footer";
import Sidebar from "./Sidebar";
import TopBar from "./TopBar";
import JewelerVerification from "./JewelerVerification";
import ProductDashboard from "./ProductDashboard";
import OrdersDashboard from "./OrdersDashboard";
import EscrowFinance from "./EscrowFinance";
import SettingsPage from "./SettingsPage";
import AdminManagement from "./AdminManagement";
import UserProfile from "./UserProfile";
import { apiCall } from "./api/client";

const AdminDashboard = ({ onLogout }) => {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [activeMenu, setActiveMenu] = useState(
    () => localStorage.getItem('activeMenu') || 'dashboard'
  );
  const [navProps, setNavProps] = useState({});
  const [liveStats, setLiveStats] = useState(null);
  const [chartData, setChartData] = useState([]);
  const [chartPeriod, setChartPeriod] = useState("month");

  useEffect(() => {
    apiCall("/admin/stats")
      .then((data) => {
        if (data.success) setLiveStats(data.stats);
      })
      .catch((err) => console.error("Failed to load stats:", err));
  }, []);

  useEffect(() => {
    apiCall("/admin/orders/chart")
      .then((data) => {
        if (data.success) setChartData(data.chart || []);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    const current = menuItems.find(item => item.id === activeMenu);
    if (activeMenu === "profile") {
      document.title = "User Profile";
    } else {
      document.title = current ? `${current.label}` : "Aurix Admin Dashboard";
    }
  }, [activeMenu]);

  const navigateTo = (menu, props = {}) => {
    localStorage.setItem('activeMenu', menu);
    setActiveMenu(menu);
    setNavProps(props);
  };

  // SVG Icons
  const Icons = {
    Dashboard: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M3 3h8v8H3V3zm10 0h8v8h-8V3zM3 13h8v8H3v-8zm10 0h8v8h-8v-8z" />
      </svg>
    ),
    People: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" />
      </svg>
    ),
    Products: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" />
      </svg>
    ),
    Orders: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-5.04-6.71l-2.75 3.54-2.12-2.12-1.41 1.41L10.5 19l4.96-6.29-1.46-1.42z" />
      </svg>
    ),
    Finance: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M16 6l2.29 2.29-4.88 4.88-4-4L2 16.59 3.41 18 10 11.41l4 4 6.3-6.29L23 12v-6z" />
      </svg>
    ),
    Disputes: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z" />
      </svg>
    ),
    Bell: () => (
      <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
      </svg>
    ),
  
    Logout: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z" />
      </svg>
    ),
    Search: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
      </svg>
    ),
    Settings: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M19.14 12.94c.04-.3.06-.61.06-.94s-.02-.64-.07-.94l2.03-1.58a.49.49 0 00.12-.61l-1.92-3.32a.49.49 0 00-.59-.22l-2.39.96a7.01 7.01 0 00-1.62-.94l-.36-2.54A.484.484 0 0014 2h-4a.484.484 0 00-.48.41l-.36 2.54a7.38 7.38 0 00-1.62.94l-2.39-.96a.476.476 0 00-.59.22L2.74 8.47a.47.47 0 00.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58a.49.49 0 00-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.27.41.49.41h4c.22 0 .44-.17.48-.41l.36-2.54a7.38 7.38 0 001.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32a.47.47 0 00-.12-.61l-2.01-1.58zM12 15.6a3.6 3.6 0 110-7.2 3.6 3.6 0 010 7.2z"/>
      </svg>
    ),
    Help: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.41-1.41-2.5-2.5-2.5S8 8.59 8 10h-2c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z" />
      </svg>
    ),
    Support: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12h-8v-2h8v2zm0-3h-8V9h8v2zm0-3H4V9h14v2z" />
      </svg>
    ),
    Admins: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 4l5 2.18V11c0 3.5-2.33 6.79-5 7.93C9.33 17.79 7 14.5 7 11V7.18L12 5z" />
      </svg>
    ),
    Verify: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z" />
      </svg>
    ),
    Moderate: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" />
      </svg>
    ),
    Report: () => (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-5.04-6.71l-2.75 3.54-2.12-2.12-1.41 1.41L10.5 19l4.96-6.29-1.46-1.42z" />
      </svg>
    ),
  };

  const menuItems = [
    { id: "dashboard", label: "Dashboard",      icon: Icons.Dashboard },
    { id: "jewelers",  label: "Jewelers",       icon: Icons.People    },
    { id: "products",  label: "Products",       icon: Icons.Products  },
    { id: "orders",    label: "Orders",         icon: Icons.Orders    },
    { id: "escrow",    label: "Escrow/Finance", icon: Icons.Finance   },
    { id: "disputes",  label: "Disputes",       icon: Icons.Disputes  },
    { id: "admins",    label: "Admins",         icon: Icons.Admins    },
    { id: "settings",  label: "Settings",       icon: Icons.Settings  },
  ];

  const stats = [
    { label: "Jeweler Verifications", value: liveStats ? String(liveStats.pendingJewellers) : "…", icon: "People"   },
    { label: "Total Products",        value: liveStats ? String(liveStats.totalProducts)    : "…", icon: "Products" },
    { label: "Active Orders",         value: liveStats ? String(liveStats.activeOrders)     : "…", icon: "Orders"   },
    { label: "Escrow Balance",        value: "—",                                                  icon: "Finance"  },
    { label: "Total Jewellers",       value: liveStats ? String(liveStats.totalJewellers)   : "…", icon: "People"   },
  ];

  const recentActivity = [
    { title: "New Jeweler Registered", subtitle: "Golden Artisan Crafts • 2 mins ago", icon: "People"   },
    { title: "Order #8492 Processed",  subtitle: "Diamond Ring 2ct • 15 mins ago",     icon: "Orders"   },
    { title: "Verification Approved",  subtitle: "Elegance Jewelers • 1hr ago",         icon: "Dashboard" },
    { title: "Dispute Opened",         subtitle: "Order #8410 • 3 hrs ago",             icon: "Disputes" },
  ];

  const renderDashboardOverview = () => (
    <>
      <div className="page-header">
        <h1>Dashboard Overview</h1>
      </div>

      <div className="stats-grid">
        {stats.map((stat, index) => {
          const StatIcon = Icons[stat.icon];
          return (
            <div key={index} className="stat-card">
              <div className="stat-icon"><StatIcon /></div>
              <div className="stat-info">
                <p className="stat-label">{stat.label}</p>
                <p className="stat-value">{stat.value}</p>
              </div>
            </div>
          );
        })}
      </div>

      <div className="quick-actions-section">
        <h2>Quick Actions</h2>
        <div className="quick-actions">
          <button className="action-btn primary" onClick={() => navigateTo("jewelers", { defaultTab: "Pending" })}>
            <span>Verify Jeweler</span>
          </button>
          <button className="action-btn secondary" onClick={() => navigateTo("products", { defaultFilter: "Pending" })}>
            <span>Moderate Products</span>
          </button>
          <button className="action-btn" onClick={() => navigateTo("escrow")}>
            <span>Generate Report</span>
          </button>
        </div>
      </div>

      <div className="content-grid">
        <div className="chart-section">
          <div className="section-header">
            <h2>Orders Overview</h2>
            <div className="time-filter">
              <button
                className={chartPeriod === "month" ? "active" : ""}
                onClick={() => setChartPeriod("month")}
              >Month</button>
            </div>
          </div>

          {chartData.length === 0 ? (
            <div className="chart-placeholder">
              <p>No order data yet</p>
            </div>
          ) : (() => {
            const W = 500, H = 180, padL = 36, padR = 16, padT = 16, padB = 28;
            const maxVal = Math.max(...chartData.map((d) => d.count), 1);
            const n = chartData.length;
            const xStep = (W - padL - padR) / (n - 1);
            const yScale = (v) => padT + (H - padT - padB) * (1 - v / maxVal);
            const pts = chartData.map((d, i) => ({
              x: padL + i * xStep,
              y: yScale(d.count),
              count: d.count,
              label: d.label,
            }));
            const linePath = pts.map((p, i) => `${i === 0 ? "M" : "L"}${p.x},${p.y}`).join(" ");
            const areaPath = `${linePath} L${pts[pts.length - 1].x},${H - padB} L${pts[0].x},${H - padB} Z`;
            const dotColors = ["#D4AF37", "#D4AF37","#D4AF37", "#D4AF37", "#D4AF37"];

            return (
              <div className="line-chart-wrap">
                <svg viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="xMidYMid meet" style={{ width: "100%", height: "100%" }}>
                  <defs>
                    <linearGradient id="lineGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="#D4AF37" stopOpacity="0.25" />
                      <stop offset="100%" stopColor="#D4AF37" stopOpacity="0.02" />
                    </linearGradient>
                  </defs>

                  {[0, 0.25, 0.5, 0.75, 1].map((t, i) => {
                    const y = padT + (H - padT - padB) * t;
                    const val = Math.round(maxVal * (1 - t));
                    return (
                      <g key={i}>
                        <line x1={padL} y1={y} x2={W - padR} y2={y}
                          stroke="#f0f0f0" strokeWidth="1" />
                        <text x={padL - 4} y={y + 4} textAnchor="end"
                          fontSize="9" fill="#9ca3af">{val}</text>
                      </g>
                    );
                  })}

                  <path d={areaPath} fill="url(#lineGrad)" />

                  <path d={linePath} fill="none" stroke="#D4AF37"
                    strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round" />

                  {pts.map((p, i) => (
                    <g key={i}>
                      <circle cx={p.x} cy={p.y} r="5"
                        fill={dotColors[i % dotColors.length]}
                        stroke="#fff" strokeWidth="2" />
                      <text x={p.x} y={H - padB + 14} textAnchor="middle"
                        fontSize="10" fontWeight="600" fill="#6b7280">{p.label}</text>
                      <text x={p.x} y={p.y - 10} textAnchor="middle"
                        fontSize="10" fontWeight="700"
                        fill={dotColors[i % dotColors.length]}>{p.count}</text>
                    </g>
                  ))}
                </svg>
              </div>
            );
          })()}
        </div>

        <div className="activity-section">
          <h2>Recent Activity</h2>
          <div className="activity-list">
            {recentActivity.map((activity, index) => {
              const ActivityIcon = Icons[activity.icon];
              return (
                <div key={index} className="activity-item">
                  <div className="activity-icon"><ActivityIcon /></div>
                  <div className="activity-info">
                    <p className="activity-title">{activity.title}</p>
                    <p className="activity-subtitle">{activity.subtitle}</p>
                  </div>
                </div>
              );
            })}
          </div>
          <button className="view-all">View All Activity</button>
        </div>
      </div>
    </>
  );

  const renderPage = () => {
    switch (activeMenu) {
      case "jewelers": return <JewelerVerification defaultTab={navProps.defaultTab} />;
      case "products": return <ProductDashboard defaultFilter={navProps.defaultFilter} />;
      case "orders":   return <OrdersDashboard />;
      case "escrow":   return <EscrowFinance />;
      case "admins":   return <AdminManagement />;
      case "disputes": return <div style={{ padding: "2rem" }}><h2>Disputes</h2><p>Coming soon.</p></div>;
      case "settings": return <SettingsPage />;
      case "profile": return <UserProfile onNavigate={navigateTo} />;
      default:         return renderDashboardOverview();
    }
  };

  return (
    <div className="dashboard-wrapper">
      <Sidebar
        sidebarOpen={sidebarOpen}
        toggleSidebar={() => setSidebarOpen(!sidebarOpen)}
        activeMenu={activeMenu}
        setActiveMenu={(menu) => navigateTo(menu)}
        menuItems={menuItems}
        Icons={Icons}
      />

      <main className="main-content">
        <TopBar onProfileClick={() => navigateTo("profile")} onLogout={onLogout} onNavigate={navigateTo} />
        <div className="dashboard-content">
          {renderPage()}
          <Footer />
        </div>
      </main>
    </div>
  );
};

export default AdminDashboard;