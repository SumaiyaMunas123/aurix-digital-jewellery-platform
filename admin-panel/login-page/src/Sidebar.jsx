import React from "react";
import "./Sidebar.css";

const Sidebar = ({
  sidebarOpen,
  toggleSidebar,
  activeMenu,
  setActiveMenu,
  menuItems,
  Icons,
}) => {
  return (
    <aside className={`sidebar ${sidebarOpen ? "open" : "closed"}`}>
      <div className="sidebar-header">
        <div className="logo-section">
          <span className="logo-text">Welcome, </span>
        </div>
        <div>
          <span className="logo-text-name">Sanuthmi Jayalath</span>
        </div>
        <button className="sidebar-toggle" onClick={toggleSidebar}>
          {sidebarOpen ? <Icons.Close /> : <Icons.Menu />}
        </button>
      </div>

      <nav className="sidebar-nav">
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              className={`nav-item ${activeMenu === item.id ? "active" : ""}`}
              onClick={() => setActiveMenu(item.id)}
            >
              <Icon />
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        <button className="support-btn" title="Support">
          <Icons.Support />
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
