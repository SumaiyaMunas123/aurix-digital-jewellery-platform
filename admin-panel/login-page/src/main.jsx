import { useState } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import AdminLogin from './AdminLogin'
import AdminDashboard from './AdminDashboard'

// Read saved session synchronously — no async, no race conditions
function getSavedSession() {
  try {
    const token = localStorage.getItem('adminToken')
    const userStr = localStorage.getItem('adminUser')
    if (token && userStr) {
      return JSON.parse(userStr)
    }
  } catch {
    // corrupted data — clear it
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminUser')
  }
  return null
}

function App() {
  const [user, setUser] = useState(getSavedSession)  // runs once, synchronously

  const handleLogin = (userData, token) => {
    if (token) {
      localStorage.setItem('adminToken', token)
    }
    if (userData) {
      localStorage.setItem('adminUser', JSON.stringify(userData))
    }
    setUser(userData)
  }

  const handleLogout = () => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminUser')
    localStorage.removeItem('activeMenu')
    setUser(null)
  }

  return (
    <>
      {user ? (
        <AdminDashboard onLogout={handleLogout} user={user} />
      ) : (
        <AdminLogin onLogin={handleLogin} />
      )}
    </>
  )
}

createRoot(document.getElementById('root')).render(<App />)