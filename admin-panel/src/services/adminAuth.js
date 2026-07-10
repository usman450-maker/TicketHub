import axios from 'axios';
import { API_ENDPOINTS } from '../config/api';

// Save token to localStorage
export const saveToken = (token) => {
  localStorage.setItem('admin_token', token);
};

export const getToken = () => {
  return localStorage.getItem('admin_token');
};

export const removeToken = () => {
  localStorage.removeItem('admin_token');
  localStorage.removeItem('admin_data');
};

// Save admin data
export const saveAdmin = (admin) => {
  localStorage.setItem('admin_data', JSON.stringify(admin));
};

export const getAdmin = () => {
  const data = localStorage.getItem('admin_data');
  return data ? JSON.parse(data) : null;
};

// Axios instance with auth
const api = axios.create();

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// ==========================
// SIGNUP
// ==========================
export const adminSignup = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.ADMIN_SIGNUP, data);
    if (response.data.success) {
      saveToken(response.data.token);
      saveAdmin(response.data.admin);
    }
    return response.data;
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Signup failed',
    };
  }
};

// ==========================
// LOGIN
// ==========================
export const adminLogin = async (data) => {
  try {
    const response = await axios.post(API_ENDPOINTS.ADMIN_LOGIN, data);
    if (response.data.success) {
      saveToken(response.data.token);
      saveAdmin(response.data.admin);
    }
    return response.data;
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Login failed',
    };
  }
};

// ==========================
// GOOGLE AUTH
// ==========================
export const adminGoogleAuth = async (idToken) => {
  try {
    const response = await axios.post(API_ENDPOINTS.ADMIN_GOOGLE_AUTH, { idToken });
    if (response.data.success) {
      saveToken(response.data.token);
      saveAdmin(response.data.admin);
    }
    return response.data;
  } catch (error) {
    return {
      success: false,
      message: error.response?.data?.message || 'Google auth failed',
    };
  }
};

// ==========================
// VERIFY TOKEN
// ==========================
export const verifyToken = async () => {
  try {
    const response = await api.get(API_ENDPOINTS.ADMIN_VERIFY);
    return response.data;
  } catch (error) {
    removeToken();
    return { success: false };
  }
};

// ==========================
// LOGOUT
// ==========================
export const logout = () => {
  removeToken();
  window.location.href = '/login';
};

// ==========================
// IS AUTHENTICATED
// ==========================
export const isAuthenticated = () => {
  return !!getToken();
};