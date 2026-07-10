import { useState, useEffect } from 'react'
import {
  User, Mail, Phone, Lock, Save, Eye, EyeOff,
  Shield, Award, Calendar, CheckCircle, Camera, Edit3, X
} from 'lucide-react'
import { 
  getMyProfile, 
  updateProfile, 
  changePassword,
  getAdminActivity 
} from '../../services/adminService'
import { getAdmin, saveAdmin } from '../../services/authService'

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('profile')
  const [profile, setProfile] = useState({
    name: '', email: '', phone: '', role: '', created_at: '',
  })
  const [activity, setActivity] = useState({ refundsProcessed: 0, totalBookings: 0 })
  const [loading, setLoading] = useState(true)
  const [editing, setEditing] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState({ type: '', text: '' })

  // Password change
  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  })
  const [showCurrent, setShowCurrent] = useState(false)
  const [showNew, setShowNew] = useState(false)
  const [showConfirm, setShowConfirm] = useState(false)

  useEffect(() => {
    loadProfile()
    loadActivity()
  }, [])

  const loadProfile = async () => {
    setLoading(true)
    const res = await getMyProfile()
    if (res.success) {
      setProfile(res.admin)
      saveAdmin(res.admin)
    }
    setLoading(false)
  }

  const loadActivity = async () => {
    const res = await getAdminActivity()
    if (res.success) setActivity(res.activity)
  }

  const handleProfileSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setMessage({ type: '', text: '' })

    const res = await updateProfile({
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
    })

    setSaving(false)

    if (res.success) {
      saveAdmin(res.admin)
      setEditing(false)
      setMessage({ type: 'success', text: '✅ Profile updated successfully!' })
      setTimeout(() => setMessage({ type: '', text: '' }), 3000)
    } else {
      setMessage({ type: 'error', text: res.message })
    }
  }

  const handlePasswordSubmit = async (e) => {
    e.preventDefault()

    if (passwordData.newPassword !== passwordData.confirmPassword) {
      setMessage({ type: 'error', text: 'New passwords do not match' })
      return
    }

    if (passwordData.newPassword.length < 6) {
      setMessage({ type: 'error', text: 'Password must be at least 6 characters' })
      return
    }

    setSaving(true)
    setMessage({ type: '', text: '' })

    const res = await changePassword({
      currentPassword: passwordData.currentPassword,
      newPassword: passwordData.newPassword,
    })

    setSaving(false)

    if (res.success) {
      setPasswordData({ currentPassword: '', newPassword: '', confirmPassword: '' })
      setMessage({ type: 'success', text: '✅ Password changed successfully!' })
      setTimeout(() => setMessage({ type: '', text: '' }), 3000)
    } else {
      setMessage({ type: 'error', text: res.message })
    }
  }

  const formatDate = (dateStr) => {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric', month: 'long', day: 'numeric',
    })
  }

  if (loading) {
    return <div className="text-center py-20 text-gray-400">Loading profile...</div>
  }

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
          Settings
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          Manage your admin account and preferences.
        </p>
      </div>

      {/* Message */}
      {message.text && (
        <div className={`mb-4 p-3 rounded-lg text-sm font-semibold ${
          message.type === 'success' 
            ? 'bg-green-50 border border-green-200 text-green-700'
            : 'bg-red-50 border border-red-200 text-red-600'
        }`}>
          {message.text}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left - Profile Card */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
            {/* Cover */}
            <div className="h-24" style={{ background: 'linear-gradient(135deg, #6D9773 0%, #0C3B2E 100%)' }}></div>

            <div className="p-6 -mt-12">
              {/* Avatar */}
              <div className="w-24 h-24 rounded-full border-4 border-white shadow-lg flex items-center justify-center text-white text-3xl font-bold mx-auto mb-4" style={{ backgroundColor: '#BB8A52' }}>
                {profile.name?.[0]?.toUpperCase() || 'A'}
              </div>

              {/* Info */}
              <div className="text-center">
                <h2 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>{profile.name}</h2>
                <p className="text-sm text-gray-500 mt-1">{profile.email}</p>
                <span className="inline-block mt-3 px-3 py-1 rounded-full text-xs font-semibold" style={{ backgroundColor: '#E8F0EA', color: '#6D9773' }}>
                  <Shield size={12} className="inline mr-1" />
                  {profile.role?.toUpperCase() || 'ADMIN'}
                </span>
              </div>

              {/* Stats */}
              <div className="mt-6 pt-6 border-t border-gray-100 grid grid-cols-2 gap-4">
                <div className="text-center">
                  <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>{activity.refundsProcessed}</p>
                  <p className="text-xs text-gray-500 mt-1">Refunds Processed</p>
                </div>
                <div className="text-center">
                  <p className="text-2xl font-bold" style={{ color: '#BB8A52' }}>{activity.totalBookings}</p>
                  <p className="text-xs text-gray-500 mt-1">Total Bookings</p>
                </div>
              </div>

              {/* Details */}
              <div className="mt-6 space-y-3 text-sm">
                <div className="flex items-center gap-2 text-gray-600">
                  <Calendar size={14} />
                  <span>Joined {formatDate(profile.created_at)}</span>
                </div>
                {profile.phone && (
                  <div className="flex items-center gap-2 text-gray-600">
                    <Phone size={14} />
                    <span>{profile.phone}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Right - Tabs */}
        <div className="lg:col-span-2">
          {/* Tabs */}
          <div className="bg-white rounded-xl border border-gray-100 mb-4 p-2 flex gap-2">
            <button
              onClick={() => setActiveTab('profile')}
              className={`flex-1 px-4 py-2.5 rounded-lg font-semibold text-sm transition-all ${
                activeTab === 'profile' ? 'text-white' : 'text-gray-600 hover:bg-gray-50'
              }`}
              style={{ backgroundColor: activeTab === 'profile' ? '#6D9773' : 'transparent' }}
            >
              <User size={16} className="inline mr-2" />
              Personal Info
            </button>
            <button
              onClick={() => setActiveTab('password')}
              className={`flex-1 px-4 py-2.5 rounded-lg font-semibold text-sm transition-all ${
                activeTab === 'password' ? 'text-white' : 'text-gray-600 hover:bg-gray-50'
              }`}
              style={{ backgroundColor: activeTab === 'password' ? '#6D9773' : 'transparent' }}
            >
              <Lock size={16} className="inline mr-2" />
              Change Password
            </button>
          </div>

          {/* Profile Tab */}
          {activeTab === 'profile' && (
            <div className="bg-white rounded-xl border border-gray-100 p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold" style={{ color: '#0C3B2E' }}>Personal Information</h3>
                {!editing ? (
                  <button
                    onClick={() => setEditing(true)}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold text-white hover:opacity-90 transition-opacity"
                    style={{ backgroundColor: '#6D9773' }}
                  >
                    <Edit3 size={14} />
                    Edit Profile
                  </button>
                ) : (
                  <button
                    onClick={() => {
                      setEditing(false)
                      loadProfile()
                    }}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold text-gray-600 hover:bg-gray-100"
                  >
                    <X size={14} />
                    Cancel
                  </button>
                )}
              </div>

              <form onSubmit={handleProfileSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                    Full Name
                  </label>
                  <div className="relative">
                    <User className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                      type="text"
                      value={profile.name || ''}
                      onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                      disabled={!editing}
                      className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg text-sm focus:outline-none disabled:bg-gray-50 disabled:text-gray-500"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                    Email Address
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                      type="email"
                      value={profile.email || ''}
                      onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                      disabled={!editing}
                      className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg text-sm focus:outline-none disabled:bg-gray-50 disabled:text-gray-500"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                    Phone Number
                  </label>
                  <div className="relative">
                    <Phone className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                      type="tel"
                      value={profile.phone || ''}
                      onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                      disabled={!editing}
                      placeholder="+92 300 1234567"
                      className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg text-sm focus:outline-none disabled:bg-gray-50 disabled:text-gray-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                    Role
                  </label>
                  <div className="relative">
                    <Shield className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
                    <input
                      type="text"
                      value={(profile.role || 'admin').toUpperCase()}
                      disabled
                      className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg text-sm bg-gray-50 text-gray-500"
                    />
                  </div>
                </div>

                {editing && (
                  <button
                    type="submit"
                    disabled={saving}
                    className="w-full py-3 rounded-lg font-semibold text-sm text-white transition-all hover:shadow-lg disabled:opacity-50"
                    style={{ backgroundColor: '#6D9773' }}
                  >
                    <Save size={16} className="inline mr-2" />
                    {saving ? 'Saving...' : 'Save Changes'}
                  </button>
                )}
              </form>
            </div>
          )}

          {/* Password Tab */}
          {activeTab === 'password' && (
            <div className="bg-white rounded-xl border border-gray-100 p-6">
              <h3 className="text-lg font-bold mb-6" style={{ color: '#0C3B2E' }}>Change Password</h3>

              <form onSubmit={handlePasswordSubmit} className="space-y-4">
                <PasswordInput
                  label="Current Password"
                  value={passwordData.currentPassword}
                  onChange={(v) => setPasswordData({ ...passwordData, currentPassword: v })}
                  show={showCurrent}
                  setShow={setShowCurrent}
                />
                <PasswordInput
                  label="New Password"
                  value={passwordData.newPassword}
                  onChange={(v) => setPasswordData({ ...passwordData, newPassword: v })}
                  show={showNew}
                  setShow={setShowNew}
                />
                <PasswordInput
                  label="Confirm New Password"
                  value={passwordData.confirmPassword}
                  onChange={(v) => setPasswordData({ ...passwordData, confirmPassword: v })}
                  show={showConfirm}
                  setShow={setShowConfirm}
                />

                {/* Password Match Indicator */}
                {passwordData.newPassword && passwordData.confirmPassword && (
                  <div className="text-xs">
                    {passwordData.newPassword === passwordData.confirmPassword ? (
                      <span className="text-green-600 flex items-center gap-1">
                        <CheckCircle size={12} /> Passwords match
                      </span>
                    ) : (
                      <span className="text-red-500 flex items-center gap-1">
                        <X size={12} /> Passwords don't match
                      </span>
                    )}
                  </div>
                )}

                <button
                  type="submit"
                  disabled={saving}
                  className="w-full py-3 rounded-lg font-semibold text-sm text-white transition-all hover:shadow-lg disabled:opacity-50"
                  style={{ backgroundColor: '#6D9773' }}
                >
                  <Lock size={16} className="inline mr-2" />
                  {saving ? 'Changing...' : 'Change Password'}
                </button>
              </form>

              <div className="mt-6 p-4 rounded-lg" style={{ backgroundColor: '#FEF3C7' }}>
                <p className="text-xs text-yellow-800">
                  🔒 <strong>Security Tip:</strong> Use a strong password with letters, numbers, and symbols. Never share your password with anyone.
                </p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

// Password Input Component
function PasswordInput({ label, value, onChange, show, setShow }) {
  return (
    <div>
      <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>{label}</label>
      <div className="relative">
        <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
        <input
          type={show ? 'text' : 'password'}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder="••••••••"
          className="w-full pl-10 pr-11 py-3 border border-gray-200 rounded-lg text-sm focus:outline-none"
          required
        />
        <button
          type="button"
          onClick={() => setShow(!show)}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
        >
          {show ? <EyeOff size={18} /> : <Eye size={18} />}
        </button>
      </div>
    </div>
  )
}