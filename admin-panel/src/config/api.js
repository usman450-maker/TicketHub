export const API_BASE_URL = 'http://localhost:5000/api'

export const API_ENDPOINTS = {
  // Signup Flow
  SEND_SIGNUP_OTP: `${API_BASE_URL}/admin/send-signup-otp`,
  VERIFY_SIGNUP_OTP: `${API_BASE_URL}/admin/verify-signup-otp`,
  RESEND_SIGNUP_OTP: `${API_BASE_URL}/admin/resend-signup-otp`,

  // Login
  LOGIN: `${API_BASE_URL}/admin/login`,

  // Google Sign-In
  GOOGLE_LOGIN_CHECK: `${API_BASE_URL}/admin/google-login-check`,
  SEND_DEVICE_AUTH: `${API_BASE_URL}/admin/send-device-authorization`,
  CHECK_DEVICE_STATUS: `${API_BASE_URL}/admin/check-device-status`,
  VERIFY_GOOGLE_SIGNUP_OTP: `${API_BASE_URL}/admin/verify-google-signup-otp`,
  RESEND_GOOGLE_SIGNUP_OTP: `${API_BASE_URL}/admin/resend-google-signup-otp`,

  // Forgot Password Flow
  FORGOT_PASSWORD: `${API_BASE_URL}/admin/forgot-password`,
  VERIFY_OTP: `${API_BASE_URL}/admin/verify-otp`,
  RESEND_OTP: `${API_BASE_URL}/admin/resend-otp`,
  RESET_PASSWORD: `${API_BASE_URL}/admin/reset-password`,


  

  // Profile
  PROFILE: `${API_BASE_URL}/admin/profile`,
}

// Dashboard
export const DASHBOARD_ENDPOINTS = {
  STATS: `${API_BASE_URL}/admin/dashboard/stats`,
  REVENUE: `${API_BASE_URL}/admin/dashboard/revenue`,
  CATEGORIES: `${API_BASE_URL}/admin/dashboard/categories`,
  RECENT_BOOKINGS: `${API_BASE_URL}/admin/dashboard/recent-bookings`,
  PENDING_REFUNDS: `${API_BASE_URL}/admin/dashboard/pending-refunds`,
}

// Users
export const USERS_ENDPOINTS = {
  ALL: `${API_BASE_URL}/admin/users`,
  STATS: `${API_BASE_URL}/admin/users/stats`,
  DETAILS: (id) => `${API_BASE_URL}/admin/users/${id}`,
  DELETE: (id) => `${API_BASE_URL}/admin/users/${id}`,
}


// Bookings
export const BOOKINGS_ENDPOINTS = {
  ALL: `${API_BASE_URL}/admin/bookings`,
  STATS: `${API_BASE_URL}/admin/bookings/stats`,
  DETAILS: (type, id) => `${API_BASE_URL}/admin/bookings/${type}/${id}`,
}

// Refunds
export const REFUNDS_ENDPOINTS = {
  ALL: `${API_BASE_URL}/admin/refunds`,
  STATS: `${API_BASE_URL}/admin/refunds/stats`,
  DETAILS: (id) => `${API_BASE_URL}/admin/refunds/${id}`,
  APPROVE: (id) => `${API_BASE_URL}/admin/refunds/${id}/approve`,
  REJECT: (id) => `${API_BASE_URL}/admin/refunds/${id}/reject`,
}

// Categories
export const CATEGORIES_ENDPOINTS = {
  MOVIES: `${API_BASE_URL}/admin/movies`,
  EVENTS: `${API_BASE_URL}/admin/events`,
  SPORTS: `${API_BASE_URL}/admin/sports`,
  PARKS: `${API_BASE_URL}/admin/parks`,
  TRANSPORT: `${API_BASE_URL}/admin/transport`,
}

// Settings
export const SETTINGS_ENDPOINTS = {
  PROFILE: `${API_BASE_URL}/admin/settings/profile`,
  UPDATE_PROFILE: `${API_BASE_URL}/admin/settings/profile`,
  CHANGE_PASSWORD: `${API_BASE_URL}/admin/settings/password`,
  ACTIVITY: `${API_BASE_URL}/admin/settings/activity`,
}

// Analytics
export const ANALYTICS_ENDPOINTS = {
  REVENUE: `${API_BASE_URL}/admin/analytics/revenue`,
  CATEGORIES: `${API_BASE_URL}/admin/analytics/categories`,
  USERS: `${API_BASE_URL}/admin/analytics/users`,
  TOP_PERFORMERS: `${API_BASE_URL}/admin/analytics/top-performers`,
  STATUS: `${API_BASE_URL}/admin/analytics/status`,
  MONTHLY: `${API_BASE_URL}/admin/analytics/monthly`,
}

// Notifications
export const NOTIFICATIONS_ENDPOINTS = {
  ALL: `${API_BASE_URL}/admin/notifications`,
  STATS: `${API_BASE_URL}/admin/notifications/stats`,
  BROADCAST: `${API_BASE_URL}/admin/notifications/broadcast`,
  SEND_USER: `${API_BASE_URL}/admin/notifications/send`,
  DELETE: (id) => `${API_BASE_URL}/admin/notifications/${id}`,
  DELETE_ALL: `${API_BASE_URL}/admin/notifications/all`,
}
// ✅ Google Client ID
export const GOOGLE_CL