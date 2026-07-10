import axios from 'axios'
import { API_ENDPOINTS } from '../config/api'

// ==========================
// TOKEN MANAGEMENT
// ==========================
export const saveToken = (token) => localStorage.setItem('admin_token', token)
export const getToken = () => localStorage.getItem('admin_token')
export const removeToken = () => {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_data')
}

export const saveAdmin = (admin) => localStorage.setItem('admin_data', JSON.stringify(admin))
export const getAdmin = () => {
  const data = localStorage.getItem('admin_data')
  return data ? JSON.parse(data) : null
}

export const isAuthenticated = () => !!getToken()

// ==========================
// AXIOS INSTANCE
// ==========================
const api = axios.create()

api.interceptors.request.use((config) => {
  const token = getToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// ==========================
// SIGNUP FLOW
// ==========================
export const sendSignupOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.SEND_SIGNUP_OTP, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to send OTP',
    }
  }
}

export const verifySignupOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.VERIFY_SIGNUP_OTP, data)
    if (response.data.success) {
      saveToken(response.data.token)
      saveAdmin(response.data.admin)
    }
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Verification failed',
    }
  }
}

export const resendSignupOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.RESEND_SIGNUP_OTP, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to resend OTP',
    }
  }
}

// ==========================
// LOGIN
// ==========================
export const login = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.LOGIN, data)
    if (response.data.success) {
      saveToken(response.data.token)
      saveAdmin(response.data.admin)
    }
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Login failed',
    }
  }
}

// ==========================
// GOOGLE SIGN-IN
// ==========================
export const googleLoginCheck = async (email) => {
  try {
    const response = await axios.post(API_ENDPOINTS.GOOGLE_LOGIN_CHECK, { email })
    if (response.data.success) {
      saveToken(response.data.token)
      saveAdmin(response.data.admin)
    }
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Google login failed',
    }
  }
}

export const sendDeviceAuthorization = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.SEND_DEVICE_AUTH, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to send authorization',
    }
  }
}

export const checkDeviceStatus = async (email) => {
  try {
    const response = await axios.post(API_ENDPOINTS.CHECK_DEVICE_STATUS, { email })
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to check status',
    }
  }
}

// ✅ VERIFY GOOGLE SIGNUP OTP
export const verifyGoogleSignupOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.VERIFY_GOOGLE_SIGNUP_OTP, data)
    if (response.data.success) {
      saveToken(response.data.token)
      saveAdmin(response.data.admin)
    }
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Verification failed',
    }
  }
}

// ✅ RESEND GOOGLE SIGNUP OTP
export const resendGoogleSignupOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.RESEND_GOOGLE_SIGNUP_OTP, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to resend OTP',
    }
  }
}

// ==========================
// FORGOT PASSWORD FLOW
// ==========================
export const forgotPassword = async (email) => {
  try {
    const response = await axios.post(API_ENDPOINTS.FORGOT_PASSWORD, { email })
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to send OTP',
    }
  }
}

export const verifyOtp = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.VERIFY_OTP, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Invalid OTP',
    }
  }
}

export const resendOtp = async (email) => {
  try {
    const response = await axios.post(API_ENDPOINTS.RESEND_OTP, { email })
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Failed to resend',
    }
  }
}

export const resetPassword = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.RESET_PASSWORD, data)
    return response.data
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Reset failed',
    }
  }
}

// ==========================
// LOGOUT
// ==========================
export const logout = () => {
  removeToken()
  window.location.href = '/login'
}