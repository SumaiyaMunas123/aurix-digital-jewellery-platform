import React from "react";
import "./TopBar.css";

const TopBar = ({ Icons, handleProfileClick, onLogout }) => {
  return (
    <div className="top-bar">
      <div className="search-bar">
        <input type="text" placeholder="Search orders, jewelers..." />
        <span className="search-icon">
          <Icons.Search />
        </span>
      </div>
      <div className="top-actions">
        <button className="icon-btn" title="Notifications">
          <Icons.Bell />
        </button>
        <button className="icon-btn" title="Settings">
          <Icons.Settings />
        </button>
        <div className="user-profile">
          <span className="avatar">SJ</span>
          <div className="user-info" onClick={handleProfileClick}>
            <p className="user-name">Sanuthmi Jayalath</p>
            <p className="user-role">Senior Admin</p>
          </div>
        </div>

        <button className="logout-btn" onClick={onLogout} title="Logout">
          <Icons.Logout />
        </button>
      </div>
    </div>
  );
};

export default TopBar;

