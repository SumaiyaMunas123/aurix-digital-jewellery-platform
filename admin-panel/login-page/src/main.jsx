import { StrictMode, useState } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import AdminLogin from './adminFrontend'
import AdminDashboard from './AdminDashboard'

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false)

  const handleLogout = () => {
    setIsLoggedIn(false)
  }

  const handleLogin = () => {
    setIsLoggedIn(true)
  }

  return (
    <StrictMode>
      {isLoggedIn ? (
        <AdminDashboard onLogout={handleLogout} />
      ) : (
        <AdminLogin onLogin={handleLogin} />
      )}
    </StrictMode>
  )
}

createRoot(document.getElementById('root')).render(<App />)
