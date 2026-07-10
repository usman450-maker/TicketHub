import axios from 'axios'
import { DASHBOARD_ENDPOINTS } from '../config/api'
import { getToken } from './authService'
import { USERS_ENDPOINTS } from '../config/api'
import { BOOKINGS_ENDPOINTS } from '../config/api'
import { REFUNDS_ENDPOINTS } from '../config/api'
import { CATEGORIES_ENDPOINTS } from '../config/api'
import { 
  SETTINGS_ENDPOINTS,
  ANALYTICS_ENDPOINTS,
} from '../config/api'
import { 
 NOTIFICATIONS_ENDPOINTS,
} from '../config/api'

// Axios with token
const api = axios.create()
api.interceptors.request.use((config) => {
  const token = getToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// ==========================
// DASHBOARD
// ==========================
export const getDashboardStats = async () => {
  try {
    const res = await api.get(DASHBOARD_ENDPOINTS.STATS)
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to load stats',
    }
  }
}

export const getRevenueOverview = async () => {
  try {
    const res = await api.get(DASHBOARD_ENDPOINTS.REVENUE)
    return res.data
  } catch (error) {
    return { success: false, data: [] }
  }
}

export const getBookingsByCategory = async () => {
  try {
    const res = await api.get(DASHBOARD_ENDPOINTS.CATEGORIES)
    return res.data
  } catch (error) {
    return { success: false, categories: [] }
  }
}

export const getRecentBookings = async (limit = 10) => {
  try {
    const res = await api.get(`${DASHBOARD_ENDPOINTS.RECENT_BOOKINGS}?limit=${limit}`)
    return res.data
  } catch (error) {
    return { success: false, bookings: [] }
  }
}

export const getPendingRefunds = async () => {
  try {
    const res = await api.get(DASHBOARD_ENDPOINTS.PENDING_REFUNDS)
    return res.data
  } catch (error) {
    return { success: false, refunds: [] }
  }
}



// ==========================
// USERS
// ==========================
export const getAllUsers = async (search = '', page = 1, limit = 20) => {
  try {
    const params = new URLSearchParams({ search, page, limit })
    const res = await api.get(`${USERS_ENDPOINTS.ALL}?${params}`)
    return res.data
  } catch (error) {
    return {
      success: false,
      users: [],
      message: error.response?.data?.message || 'Failed to load users',
    }
  }
}

export const getUsersStats = async () => {
  try {
    const res = await api.get(USERS_ENDPOINTS.STATS)
    return res.data
  } catch (error) {
    return { success: false, stats: {} }
  }
}

export const getUserDetails = async (id) => {
  try {
    const res = await api.get(USERS_ENDPOINTS.DETAILS(id))
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to load user',
    }
  }
}

export const deleteUser = async (id) => {
  try {
    const res = await api.delete(USERS_ENDPOINTS.DELETE(id))
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to delete user',
    }
  }
}

// ==========================
// BOOKINGS
// ==========================
export const getAllBookings = async (search = '', type = 'all', status = 'all', page = 1, limit = 20) => {
  try {
    const params = new URLSearchParams({ search, type, status, page, limit })
    const res = await api.get(`${BOOKINGS_ENDPOINTS.ALL}?${params}`)
    return res.data
  } catch (error) {
    return {
      success: false,
      bookings: [],
      message: error.response?.data?.message || 'Failed to load bookings',
    }
  }
}

export const getBookingsStats = async () => {
  try {
    const res = await api.get(BOOKINGS_ENDPOINTS.STATS)
    return res.data
  } catch (error) {
    return { success: false, stats: {} }
  }
}

export const getBookingDetails = async (type, id) => {
  try {
    const res = await api.get(BOOKINGS_ENDPOINTS.DETAILS(type, id))
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to load booking',
    }
  }
}

// ==========================
// REFUNDS
// ==========================
export const getAllRefunds = async (search = '', status = 'all', type = 'all', page = 1, limit = 20) => {
  try {
    const params = new URLSearchParams({ search, status, type, page, limit })
    const res = await api.get(`${REFUNDS_ENDPOINTS.ALL}?${params}`)
    return res.data
  } catch (error) {
    return {
      success: false,
      refunds: [],
      message: error.response?.data?.message || 'Failed to load refunds',
    }
  }
}

export const getRefundsStats = async () => {
  try {
    const res = await api.get(REFUNDS_ENDPOINTS.STATS)
    return res.data
  } catch (error) {
    return { success: false, stats: {} }
  }
}

export const getRefundDetails = async (id) => {
  try {
    const res = await api.get(REFUNDS_ENDPOINTS.DETAILS(id))
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to load refund',
    }
  }
}

export const approveRefund = async (id, adminNotes = '') => {
  try {
    const res = await api.post(REFUNDS_ENDPOINTS.APPROVE(id), { adminNotes })
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to approve refund',
    }
  }
}

export const rejectRefund = async (id, adminNotes) => {
  try {
    const res = await api.post(REFUNDS_ENDPOINTS.REJECT(id), { adminNotes })
    return res.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to reject refund',
    }
  }
}

// ==========================
// CATEGORIES
// ==========================
export const getCategoryData = async (category, filters = {}) => {
  try {
    const params = new URLSearchParams(filters)
    const url = `${CATEGORIES_ENDPOINTS[category.toUpperCase()]}?${params}`
    const res = await api.get(url)
    return res.data
  } catch (error) {
    return {
      success: false,
      bookings: [],
      stats: {},
      topItems: [],
      message: error.response?.data?.message || 'Failed to load data',
    }
  }
}

// ==========================
// SETTINGS
// ==========================
export const getMyProfile = async () => {
  try {
    const res = await api.get(SETTINGS_ENDPOINTS.PROFILE)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const updateProfile = async (data) => {
  try {
    const res = await api.put(SETTINGS_ENDPOINTS.UPDATE_PROFILE, data)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const changePassword = async (data) => {
  try {
    const res = await api.put(SETTINGS_ENDPOINTS.CHANGE_PASSWORD, data)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const getAdminActivity = async () => {
  try {
    const res = await api.get(SETTINGS_ENDPOINTS.ACTIVITY)
    return res.data
  } catch (error) {
    return { success: false, activity: {} }
  }
}

// ==========================
// ANALYTICS
// ==========================
export const getRevenueAnalytics = async (period = 30) => {
  try {
    const res = await api.get(`${ANALYTICS_ENDPOINTS.REVENUE}?period=${period}`)
    return res.data
  } catch (error) {
    return { success: false, data: [] }
  }
}

export const getCategoryRevenue = async () => {
  try {
    const res = await api.get(ANALYTICS_ENDPOINTS.CATEGORIES)
    return res.data
  } catch (error) {
    return { success: false, categories: [] }
  }
}

export const getUserGrowth = async () => {
  try {
    const res = await api.get(ANALYTICS_ENDPOINTS.USERS)
    return res.data
  } catch (error) {
    return { success: false, data: [] }
  }
}

export const getTopPerformers = async () => {
  try {
    const res = await api.get(ANALYTICS_ENDPOINTS.TOP_PERFORMERS)
    return res.data
  } catch (error) {
    return { success: false, topUsers: [], topMovies: [], topRoutes: [] }
  }
}

export const getBookingStatusStats = async () => {
  try {
    const res = await api.get(ANALYTICS_ENDPOINTS.STATUS)
    return res.data
  } catch (error) {
    return { success: false, data: [] }
  }
}

export const getMonthlyComparison = async () => {
  try {
    const res = await api.get(ANALYTICS_ENDPOINTS.MONTHLY)
    return res.data
  } catch (error) {
    return { success: false, data: [] }
  }
}

// ==========================
// NOTIFICATIONS
// ==========================
export const getAllNotifications = async (search = '', type = 'all', page = 1, limit = 20) => {
  try {
    const params = new URLSearchParams({ search, type, page, limit })
    const res = await api.get(`${NOTIFICATIONS_ENDPOINTS.ALL}?${params}`)
    return res.data
  } catch (error) {
    return { success: false, notifications: [], message: error.response?.data?.message || 'Failed' }
  }
}

export const getNotificationsStats = async () => {
  try {
    const res = await api.get(NOTIFICATIONS_ENDPOINTS.STATS)
    return res.data
  } catch (error) {
    return { success: false, stats: {} }
  }
}

export const sendBroadcastNotification = async (data) => {
  try {
    const res = await api.post(NOTIFICATIONS_ENDPOINTS.BROADCAST, data)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const sendNotificationToUser = async (data) => {
  try {
    const res = await api.post(NOTIFICATIONS_ENDPOINTS.SEND_USER, data)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const deleteNotification = async (id) => {
  try {
    const res = await api.delete(NOTIFICATIONS_ENDPOINTS.DELETE(id))
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}

export const deleteAllNotifications = async (type = 'all') => {
  try {
    const res = await api.delete(`${NOTIFICATIONS_ENDPOINTS.DELETE_ALL}?type=${type}`)
    return res.data
  } catch (error) {
    return { success: false, message: error.response?.data?.message || 'Failed' }
  }
}