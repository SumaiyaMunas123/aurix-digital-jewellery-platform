import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import AdminFrontend from './adminFrontend'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <AdminFrontend/>
  </StrictMode>
)
