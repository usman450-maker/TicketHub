import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import LandingPage from './pages/landing/LandingPage'
import LoginPage from './pages/auth/LoginPage'
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage'
import OtpVerificationPage from './pages/auth/OtpVerificationPage'
import ResetPasswordPage from './pages/auth/ResetPasswordPage'

// Dashboard
import DashboardLayout from './layouts/DashboardLayout'
import DashboardPage from './pages/dashboard/DashboardPage'
import UsersPage from './pages/dashboard/UsersPage'
import BookingsPage from './pages/dashboard/BookingsPage'
import RefundsPage from './pages/dashboard/RefundsPage'
import MoviesPage from './pages/dashboard/MoviesPage'
import EventsPage from './pages/dashboard/EventsPage'
import SportsPage from './pages/dashboard/SportsPage'
import ParksPage from './pages/dashboard/ParksPage'
import TransportPage from './pages/dashboard/TransportPage'
import NotificationsPage from './pages/dashboard/NotificationsPage'
import AnalyticsPage from './pages/dashboard/AnalyticsPage'
import SettingsPage from './pages/dashboard/SettingsPage'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/verify-otp" element={<OtpVerificationPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />
        
        {/* ❌ Signup routes REMOVED */}
        {/* Redirect any /signup attempts to /login */}
        <Route path="/signup" element={<Navigate to="/login" replace />} />
        <Route path="/google-device-waiting" element={<Navigate to="/login" replace />} />

        {/* Dashboard (Protected) */}
        <Route path="/dashboard" element={<DashboardLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="bookings" element={<BookingsPage />} />
          <Route path="refunds" element={<RefundsPage />} />
          <Route path="movies" element={<MoviesPage />} />
          <Route path="events" element={<EventsPage />} />
          <Route path="sports" element={<SportsPage />} />
          <Route path="parks" element={<ParksPage />} />
          <Route path="transport" element={<TransportPage />} />
          <Route path="notifications" element={<NotificationsPage />} />
          <Route path="analytics" element={<AnalyticsPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App