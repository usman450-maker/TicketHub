import { Outlet, Navigate } from 'react-router-dom'
import Sidebar from '../components/Sidebar'
import Topbar from '../components/Topbar'
import { isAuthenticated } from '../services/authService'

export default function DashboardLayout() {
  // ✅ Protect route
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Sidebar />
      <main className="ml-64 p-6">
        <Topbar />
        <Outlet />
      </main>
    </div>
  )
}