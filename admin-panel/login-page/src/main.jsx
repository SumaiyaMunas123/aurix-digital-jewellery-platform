import { StrictMode, useState } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import AdminLogin from "./AdminLogin";
import AdminDashboard from "./AdminDashboard";

function App() {
  const [user, setUser] = useState(null);

  const handleLogout = () => {
    localStorage.removeItem("adminToken");
    setUser(null);
  };

  const handleLogin = (userData, token) => {
    if (token) {
      localStorage.setItem("adminToken", token);
    }
    setUser(userData);
  };

  return (
    <StrictMode>
      <>
        {user ? (
          <AdminDashboard onLogout={handleLogout} user={user} />
        ) : (
          <AdminLogin onLogin={handleLogin} />
        )}
      </>
    </StrictMode>
  );
}

createRoot(document.getElementById("root")).render(<App />);
