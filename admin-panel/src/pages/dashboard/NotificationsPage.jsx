import { useState, useEffect } from 'react'
import {
  Bell, Search, Trash2, Send, X, Plus, User, Users,
  Ticket, RotateCcw, Shield, Info, CheckCircle,
  ChevronLeft, ChevronRight, Mail, AlertCircle
} from 'lucide-react'
import {
  getAllNotifications,
  getNotificationsStats,
  sendBroadcastNotification,
  sendNotificationToUser,
  deleteNotification,
  deleteAllNotifications,
} from '../../services/adminService'
import { getAllUsers } from '../../services/adminService'

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState([])
  const [stats, setStats] = useState({
    total: 0, unread: 0, booking: 0, refund: 0, security: 0, account: 0, info: 0
  })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [typeFilter, setTypeFilter] = useState('all')
  const [page, setPage] = useState(1)
  const [pagination, setPagination] = useState({})

  // Send notification modal
  const [showSendModal, setShowSendModal] = useState(false)
  const [sendType, setSendType] = useState('broadcast') // broadcast or specific
  const [users, setUsers] = useState([])
  const [selectedUser, setSelectedUser] = useState(null)
  const [userSearch, setUserSearch] = useState('')
  const [notificationForm, setNotificationForm] = useState({
    title: '',
    message: '',
    type: 'info',
    sendEmail: false,
  })
  const [sending, setSending] = useState(false)

  // Delete confirmation
  const [deleteConfirm, setDeleteConfirm] = useState(null)
  const [showClearAll, setShowClearAll] = useState(false)

  // Success message
  const [message, setMessage] = useState({ type: '', text: '' })

  useEffect(() => {
    loadStats()
  }, [])

  useEffect(() => {
    loadNotifications()
  }, [page, typeFilter])

  useEffect(() => {
    const timer = setTimeout(() => {
      setPage(1)
      loadNotifications()
    }, 500)
    return () => clearTimeout(timer)
  }, [search])

  const loadStats = async () => {
    const res = await getNotificationsStats()
    if (res.success) setStats(res.stats)
  }

  const loadNotifications = async () => {
    setLoading(true)
    const res = await getAllNotifications(search, typeFilter, page, 20)
    if (res.success) {
      setNotifications(res.notifications)
      setPagination(res.pagination || {})
    }
    setLoading(false)
  }

  const loadUsers = async () => {
    const res = await getAllUsers('', 1, 100)
    if (res.success) setUsers(res.users)
  }

  const handleOpenSendModal = () => {
    setShowSendModal(true)
    loadUsers()
  }

  const handleSend = async () => {
    if (!notificationForm.title || !notificationForm.message) {
      setMessage({ type: 'error', text: 'Please fill title and message' })
      return
    }

    if (sendType === 'specific' && !selectedUser) {
      setMessage({ type: 'error', text: 'Please select a user' })
      return
    }

    setSending(true)
    setMessage({ type: '', text: '' })

    let res
    if (sendType === 'broadcast') {
      res = await sendBroadcastNotification(notificationForm)
    } else {
      res = await sendNotificationToUser({ ...notificationForm, userId: selectedUser.id })
    }

    setSending(false)

    if (res.success) {
      setMessage({ type: 'success', text: `✅ ${res.message}` })
      setNotificationForm({ title: '', message: '', type: 'info', sendEmail: false })
      setSelectedUser(null)
      setTimeout(() => {
        setShowSendModal(false)
        setMessage({ type: '', text: '' })
        loadNotifications()
        loadStats()
      }, 1500)
    } else {
      setMessage({ type: 'error', text: res.message })
    }
  }

  const handleDelete = async (id) => {
    const res = await deleteNotification(id)
    if (res.success) {
      setDeleteConfirm(null)
      loadNotifications()
      loadStats()
    }
  }

  const handleClearAll = async () => {
    const res = await deleteAllNotifications(typeFilter)
    if (res.success) {
      setShowClearAll(false)
      loadNotifications()
      loadStats()
    }
  }

  const formatTime = (dateStr) => {
    const date = new Date(dateStr)
    const now = new Date()
    const diff = now - date
    const mins = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    if (mins < 1) return 'Just now'
    if (mins < 60) return `${mins}m ago`
    if (hours < 24) return `${hours}h ago`
    if (days < 7) return `${days}d ago`
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
  }

  const typeConfig = {
    booking: { icon: Ticket, color: '#6D9773', bg: '#E8F0EA', label: 'BOOKING' },
    refund: { icon: RotateCcw, color: '#BB8A52', bg: '#FEF3C7', label: 'REFUND' },
    security: { icon: Shield, color: '#EF4444', bg: '#FEE2E2', label: 'SECURITY' },
    account: { icon: User, color: '#3B82F6', bg: '#DBEAFE', label: 'ACCOUNT' },
    info: { icon: Info, color: '#6B7280', bg: '#F3F4F6', label: 'INFO' },
  }

  const filteredUsers = users.filter(u =>
    u.name?.toLowerCase().includes(userSearch.toLowerCase()) ||
    u.email?.toLowerCase().includes(userSearch.toLowerCase())
  )

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
            Notifications
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            View system notifications and send messages to users.
          </p>
        </div>
        <div className="flex gap-2">
          {stats.total > 0 && (
            <button
              onClick={() => setShowClearAll(true)}
              className="flex items-center gap-2 px-4 py-2 border border-red-200 text-red-600 rounded-lg text-sm font-semibold hover:bg-red-50 transition-colors"
            >
              <Trash2 size={16} />
              Clear All
            </button>
          )}
          <button
            onClick={handleOpenSendModal}
            className="flex items-center gap-2 px-5 py-2 text-white rounded-lg text-sm font-semibold hover:opacity-90 transition-opacity"
            style={{ backgroundColor: '#6D9773' }}
          >
            <Send size={16} />
            Send Notification
          </button>
        </div>
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

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-6 gap-4 mb-6">
        <StatCard label="TOTAL" value={stats.total} color="#6D9773" icon={Bell} />
        <StatCard label="UNREAD" value={stats.unread} color="#EF4444" icon={AlertCircle} />
        <StatCard label="BOOKING" value={stats.booking} color="#6D9773" icon={Ticket} />
        <StatCard label="REFUND" value={stats.refund} color="#BB8A52" icon={RotateCcw} />
        <StatCard label="SECURITY" value={stats.security} color="#EF4444" icon={Shield} />
        <StatCard label="ACCOUNT" value={stats.account} color="#3B82F6" icon={User} />
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-xl border border-gray-100 mb-4 flex gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search notifications..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none"
          />
        </div>
        <select
          value={typeFilter}
          onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
          className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none cursor-pointer"
        >
          <option value="all">All Types</option>
          <option value="booking">Booking</option>
          <option value="refund">Refund</option>
          <option value="security">Security</option>
          <option value="account">Account</option>
          <option value="info">Info</option>
        </select>
      </div>

      {/* Notifications List */}
      <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-gray-400">Loading...</div>
        ) : notifications.length === 0 ? (
          <div className="p-12 text-center">
            <Bell size={48} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500">No notifications found</p>
          </div>
        ) : (
          <>
            <div className="divide-y divide-gray-100">
              {notifications.map((notif) => {
                const config = typeConfig[notif.type] || typeConfig.info
                const Icon = config.icon

                return (
                  <div
                    key={notif.id}
                    className={`p-4 hover:bg-gray-50 transition-colors ${
                      !notif.is_read ? 'bg-blue-50/30' : ''
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <div
                        className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
                        style={{ backgroundColor: config.bg }}
                      >
                        <Icon size={20} style={{ color: config.color }} />
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2 mb-1">
                              <h4 className="text-sm font-bold" style={{ color: '#0C3B2E' }}>
                                {notif.title}
                              </h4>
                              <span
                                className="text-[10px] font-bold px-1.5 py-0.5 rounded"
                                style={{ backgroundColor: config.bg, color: config.color }}
                              >
                                {config.label}
                              </span>
                              {!notif.is_read && (
                                <span className="w-2 h-2 rounded-full bg-blue-500"></span>
                              )}
                            </div>
                            <p className="text-sm text-gray-600 mb-2">{notif.message}</p>
                            <div className="flex items-center gap-3 text-xs text-gray-400">
                              {notif.user_name && (
                                <span className="flex items-center gap-1">
                                  <User size={11} />
                                  {notif.user_name}
                                </span>
                              )}
                              {notif.user_email && (
                                <span className="flex items-center gap-1">
                                  <Mail size={11} />
                                  {notif.user_email}
                                </span>
                              )}
                              <span>{formatTime(notif.created_at)}</span>
                            </div>
                          </div>

                          <button
                            onClick={() => setDeleteConfirm(notif)}
                            className="p-2 rounded-lg hover:bg-red-50 transition-colors flex-shrink-0"
                          >
                            <Trash2 size={16} className="text-red-500" />
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>

            {/* Pagination */}
            {pagination.totalPages > 1 && (
              <div className="flex items-center justify-between p-4 border-t border-gray-100">
                <p className="text-sm text-gray-500">
                  Showing {notifications.length} of {pagination.total}
                </p>
                <div className="flex items-center gap-2">
                  <button onClick={() => setPage(Math.max(1, page - 1))} disabled={page === 1} className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50">
                    <ChevronLeft size={16} />
                  </button>
                  <span className="px-4 py-2 text-sm font-semibold" style={{ color: '#0C3B2E' }}>
                    {page} / {pagination.totalPages}
                  </span>
                  <button onClick={() => setPage(Math.min(pagination.totalPages, page + 1))} disabled={page >= pagination.totalPages} className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50">
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* Send Notification Modal */}
      {showSendModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden flex flex-col">
            {/* Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#6D9773' }}>
                  <Send className="text-white" size={20} />
                </div>
                <div>
                  <h2 className="text-lg font-bold" style={{ color: '#0C3B2E' }}>Send Notification</h2>
                  <p className="text-xs text-gray-500">Notify users about important updates</p>
                </div>
              </div>
              <button onClick={() => setShowSendModal(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <X size={20} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {/* Send Type Tabs */}
              <div className="flex gap-2 p-1 bg-gray-100 rounded-lg">
                <button
                  onClick={() => setSendType('broadcast')}
                  className={`flex-1 px-4 py-2 rounded-md font-semibold text-sm transition-all ${
                    sendType === 'broadcast' ? 'bg-white shadow-sm text-gray-900' : 'text-gray-600'
                  }`}
                >
                  <Users size={14} className="inline mr-2" />
                  Broadcast to All
                </button>
                <button
                  onClick={() => setSendType('specific')}
                  className={`flex-1 px-4 py-2 rounded-md font-semibold text-sm transition-all ${
                    sendType === 'specific' ? 'bg-white shadow-sm text-gray-900' : 'text-gray-600'
                  }`}
                >
                  <User size={14} className="inline mr-2" />
                  Specific User
                </button>
              </div>

              {/* User Selection (only for specific) */}
              {sendType === 'specific' && (
                <div>
                  <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                    Select User
                  </label>
                  {selectedUser ? (
                    <div className="p-3 border border-gray-200 rounded-lg flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold" style={{ backgroundColor: '#6D9773' }}>
                          {selectedUser.name?.[0]?.toUpperCase()}
                        </div>
                        <div>
                          <p className="text-sm font-semibold">{selectedUser.name}</p>
                          <p className="text-xs text-gray-500">{selectedUser.email}</p>
                        </div>
                      </div>
                      <button onClick={() => setSelectedUser(null)} className="text-red-500 hover:bg-red-50 p-2 rounded">
                        <X size={16} />
                      </button>
                    </div>
                  ) : (
                    <>
                      <div className="relative mb-2">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                        <input
                          type="text"
                          value={userSearch}
                          onChange={(e) => setUserSearch(e.target.value)}
                          placeholder="Search users..."
                          className="w-full pl-9 pr-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none"
                        />
                      </div>
                      <div className="max-h-48 overflow-y-auto border border-gray-200 rounded-lg divide-y">
                        {filteredUsers.slice(0, 10).map(u => (
                          <button
                            key={u.id}
                            onClick={() => { setSelectedUser(u); setUserSearch('') }}
                            className="w-full flex items-center gap-3 p-3 hover:bg-gray-50 text-left"
                          >
                            <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold" style={{ backgroundColor: '#6D9773' }}>
                              {u.name?.[0]?.toUpperCase()}
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="text-sm font-semibold truncate">{u.name}</p>
                              <p className="text-xs text-gray-500 truncate">{u.email}</p>
                            </div>
                          </button>
                        ))}
                      </div>
                    </>
                  )}
                </div>
              )}

              {/* Type */}
              <div>
                <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                  Notification Type
                </label>
                <div className="grid grid-cols-5 gap-2">
                  {Object.entries(typeConfig).map(([key, cfg]) => {
                    const Icon = cfg.icon
                    return (
                      <button
                        key={key}
                        onClick={() => setNotificationForm({ ...notificationForm, type: key })}
                        className={`p-3 rounded-lg border-2 transition-all ${
                          notificationForm.type === key ? 'border-current' : 'border-gray-200 hover:border-gray-300'
                        }`}
                        style={{
                          borderColor: notificationForm.type === key ? cfg.color : undefined,
                          backgroundColor: notificationForm.type === key ? cfg.bg : 'white',
                        }}
                      >
                        <Icon size={20} style={{ color: cfg.color }} className="mx-auto mb-1" />
                        <p className="text-xs font-semibold" style={{ color: cfg.color }}>
                          {cfg.label}
                        </p>
                      </button>
                    )
                  })}
                </div>
              </div>

              {/* Title */}
              <div>
                <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                  Title
                </label>
                <input
                  type="text"
                  value={notificationForm.title}
                  onChange={(e) => setNotificationForm({ ...notificationForm, title: e.target.value })}
                  placeholder="e.g., New Feature Available"
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none"
                />
              </div>

              {/* Message */}
              <div>
                <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                  Message
                </label>
                <textarea
                  value={notificationForm.message}
                  onChange={(e) => setNotificationForm({ ...notificationForm, message: e.target.value })}
                  placeholder="Write your message here..."
                  rows="4"
                  className="w-full px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none resize-none"
                />
              </div>

              {/* Send Email Checkbox */}
              <label className="flex items-center gap-3 p-3 rounded-lg border border-gray-200 cursor-pointer hover:bg-gray-50">
                <input
                  type="checkbox"
                  checked={notificationForm.sendEmail}
                  onChange={(e) => setNotificationForm({ ...notificationForm, sendEmail: e.target.checked })}
                  className="w-4 h-4"
                  style={{ accentColor: '#6D9773' }}
                />
                <div className="flex-1">
                  <p className="text-sm font-semibold" style={{ color: '#0C3B2E' }}>Also send email notification</p>
                  <p className="text-xs text-gray-500">Users will receive both in-app and email</p>
                </div>
                <Mail size={18} style={{ color: '#BB8A52' }} />
              </label>

              {message.text && (
                <div className={`p-3 rounded-lg text-sm font-semibold ${
                  message.type === 'success' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-600'
                }`}>
                  {message.text}
                </div>
              )}
            </div>

            {/* Footer */}
            <div className="p-4 border-t border-gray-100 flex gap-3">
              <button
                onClick={() => setShowSendModal(false)}
                disabled={sending}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50 disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                onClick={handleSend}
                disabled={sending}
                className="flex-1 py-2.5 text-white rounded-lg font-semibold text-sm hover:opacity-90 disabled:opacity-50 flex items-center justify-center gap-2"
                style={{ backgroundColor: '#6D9773' }}
              >
                <Send size={16} />
                {sending ? 'Sending...' : 'Send Notification'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteConfirm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6">
            <div className="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
              <Trash2 className="text-red-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2" style={{ color: '#0C3B2E' }}>
              Delete Notification?
            </h3>
            <p className="text-sm text-gray-500 text-center mb-6">
              This will permanently delete "{deleteConfirm.title}". This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setDeleteConfirm(null)}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(deleteConfirm.id)}
                className="flex-1 py-2.5 bg-red-500 text-white rounded-lg font-semibold text-sm hover:bg-red-600"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Clear All Confirmation */}
      {showClearAll && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6">
            <div className="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="text-red-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2" style={{ color: '#0C3B2E' }}>
              Clear All Notifications?
            </h3>
            <p className="text-sm text-gray-500 text-center mb-6">
              This will delete <strong>ALL {typeFilter !== 'all' ? typeFilter : ''} notifications</strong>. This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowClearAll(false)}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleClearAll}
                className="flex-1 py-2.5 bg-red-500 text-white rounded-lg font-semibold text-sm hover:bg-red-600"
              >
                Clear All
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function StatCard({ label, value, color, icon: Icon }) {
  return (
    <div className="bg-white p-4 rounded-xl border border-gray-100">
      <div className="w-8 h-8 rounded-lg flex items-center justify-center mb-2" style={{ backgroundColor: color }}>
        <Icon className="text-white" size={16} />
      </div>
      <p className="text-xs text-gray-500 font-semibold mb-1">{label}</p>
      <p className="text-xl font-bold" style={{ color: '#0C3B2E' }}>{value}</p>
    </div>
  )
}