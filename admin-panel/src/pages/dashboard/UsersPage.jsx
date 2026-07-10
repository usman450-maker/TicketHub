import { useState, useEffect } from 'react'
import {
  Users, Search, Filter, Trash2, Eye, Mail, Phone,
  Calendar, DollarSign, Ticket, X, ChevronLeft, ChevronRight,
  UserCheck, UserPlus, TrendingUp, Film, Bus, Train, Plane,
  Trophy, TreePine
} from 'lucide-react'
import {
  getAllUsers,
  getUsersStats,
  getUserDetails,
  deleteUser,
} from '../../services/adminService'

export default function UsersPage() {
  const [users, setUsers] = useState([])
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    newToday: 0,
    newThisMonth: 0,
  })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [pagination, setPagination] = useState({})
  const [selectedUser, setSelectedUser] = useState(null)
  const [showDetails, setShowDetails] = useState(false)
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(null)
  const [detailsLoading, setDetailsLoading] = useState(false)

  useEffect(() => {
    loadStats()
  }, [])

  useEffect(() => {
    loadUsers()
  }, [page])

  useEffect(() => {
    const timer = setTimeout(() => {
      setPage(1)
      loadUsers()
    }, 500)
    return () => clearTimeout(timer)
  }, [search])

  const loadStats = async () => {
    const res = await getUsersStats()
    if (res.success) setStats(res.stats)
  }

  const loadUsers = async () => {
    setLoading(true)
    const res = await getAllUsers(search, page, 20)
    if (res.success) {
      setUsers(res.users)
      setPagination(res.pagination || {})
    }
    setLoading(false)
  }

  const handleViewDetails = async (userId) => {
    setDetailsLoading(true)
    setShowDetails(true)
    const res = await getUserDetails(userId)
    if (res.success) {
      setSelectedUser(res.user)
    }
    setDetailsLoading(false)
  }

  const handleDelete = async (userId) => {
    const res = await deleteUser(userId)
    if (res.success) {
      setShowDeleteConfirm(null)
      loadUsers()
      loadStats()
    } else {
      alert(res.message)
    }
  }

  const formatDate = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  }

  const typeIcons = {
    movie: Film,
    bus: Bus,
    train: Train,
    flight: Plane,
    sports: Trophy,
    event: Calendar,
    park: TreePine,
  }

  const statusColors = {
    paid: 'bg-green-100 text-green-700',
    pending: 'bg-yellow-100 text-yellow-700',
    cancelled: 'bg-red-100 text-red-600',
    refunded: 'bg-blue-100 text-blue-700',
  }

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
          Users Management
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          Manage all registered users on TicketHub platform.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-5 rounded-xl border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#6D9773' }}>
              <Users className="text-white" size={20} />
            </div>
          </div>
          <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">TOTAL USERS</p>
          <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>{stats.totalUsers}</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#BB8A52' }}>
              <UserCheck className="text-white" size={20} />
            </div>
          </div>
          <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">ACTIVE USERS</p>
          <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>{stats.activeUsers}</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#0C3B2E' }}>
              <UserPlus className="text-white" size={20} />
            </div>
          </div>
          <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">NEW TODAY</p>
          <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>{stats.newToday}</p>
        </div>

        <div className="bg-white p-5 rounded-xl border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#F59E0B' }}>
              <TrendingUp className="text-white" size={20} />
            </div>
          </div>
          <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">THIS MONTH</p>
          <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>{stats.newThisMonth}</p>
        </div>
      </div>

      {/* Search & Filter */}
      <div className="bg-white p-4 rounded-xl border border-gray-100 mb-4 flex items-center gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name, email, or phone..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300"
          />
        </div>
        <div className="text-sm text-gray-500">
          Total: <span className="font-bold" style={{ color: '#0C3B2E' }}>{pagination.total || 0}</span>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-gray-400">Loading users...</div>
        ) : users.length === 0 ? (
          <div className="p-12 text-center">
            <Users size={48} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500">
              {search ? 'No users match your search' : 'No users found'}
            </p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead style={{ backgroundColor: '#F0F5F1' }}>
                  <tr>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">USER</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">CONTACT</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">JOINED</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">BOOKINGS</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">TOTAL SPENT</th>
                    <th className="text-right p-4 text-xs font-semibold text-gray-600 tracking-wider">ACTIONS</th>
                  </tr>
                </thead>
                <tbody>
                  {users.map((user) => (
                    <tr key={user.id} className="border-t border-gray-50 hover:bg-gray-50 transition-colors">
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div
                            className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0"
                            style={{ backgroundColor: '#6D9773' }}
                          >
                            {user.name?.[0]?.toUpperCase() || 'U'}
                          </div>
                          <div>
                            <p className="font-semibold text-sm" style={{ color: '#0C3B2E' }}>
                              {user.name}
                            </p>
                            <p className="text-xs text-gray-500">ID: #{user.id}</p>
                          </div>
                        </div>
                      </td>
                      <td className="p-4">
                        <div className="text-sm">
                          <div className="flex items-center gap-1 text-gray-600 mb-1">
                            <Mail size={12} />
                            <span className="truncate max-w-[200px]">{user.email}</span>
                          </div>
                          {user.phone && (
                            <div className="flex items-center gap-1 text-gray-500 text-xs">
                              <Phone size={12} />
                              {user.phone}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="p-4 text-sm text-gray-600">
                        {formatDate(user.created_at)}
                      </td>
                      <td className="p-4">
                        <span
                          className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold"
                          style={{ backgroundColor: '#E8F0EA', color: '#0C3B2E' }}
                        >
                          <Ticket size={12} />
                          {user.total_bookings}
                        </span>
                      </td>
                      <td className="p-4">
                        <span className="text-sm font-bold" style={{ color: '#BB8A52' }}>
                          PKR {parseFloat(user.total_spent).toLocaleString()}
                        </span>
                      </td>
                      <td className="p-4">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleViewDetails(user.id)}
                            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
                            title="View Details"
                          >
                            <Eye size={16} style={{ color: '#6D9773' }} />
                          </button>
                          <button
                            onClick={() => setShowDeleteConfirm(user)}
                            className="p-2 rounded-lg hover:bg-red-50 transition-colors"
                            title="Delete User"
                          >
                            <Trash2 size={16} className="text-red-500" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {pagination.totalPages > 1 && (
              <div className="flex items-center justify-between p-4 border-t border-gray-100">
                <p className="text-sm text-gray-500">
                  Showing page {pagination.page} of {pagination.totalPages}
                </p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setPage(Math.max(1, page - 1))}
                    disabled={page === 1}
                    className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <ChevronLeft size={16} />
                  </button>
                  <span className="px-4 py-2 text-sm font-semibold" style={{ color: '#0C3B2E' }}>
                    {page}
                  </span>
                  <button
                    onClick={() => setPage(Math.min(pagination.totalPages, page + 1))}
                    disabled={page >= pagination.totalPages}
                    className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* ============ USER DETAILS MODAL ============ */}
      {showDetails && (
        <div
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setShowDetails(false)}
        >
          <div
            className="bg-white rounded-2xl max-w-3xl w-full max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <h2 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>
                User Details
              </h2>
              <button
                onClick={() => setShowDetails(false)}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="flex-1 overflow-y-auto p-6">
              {detailsLoading ? (
                <div className="text-center py-12 text-gray-400">Loading details...</div>
              ) : selectedUser ? (
                <>
                  {/* User Info */}
                  <div className="flex items-center gap-4 mb-6">
                    <div
                      className="w-20 h-20 rounded-full flex items-center justify-center text-white text-3xl font-bold"
                      style={{ backgroundColor: '#6D9773' }}
                    >
                      {selectedUser.name?.[0]?.toUpperCase() || 'U'}
                    </div>
                    <div>
                      <h3 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>
                        {selectedUser.name}
                      </h3>
                      <p className="text-sm text-gray-500 flex items-center gap-1 mt-1">
                        <Mail size={14} />
                        {selectedUser.email}
                      </p>
                      {selectedUser.phone && (
                        <p className="text-sm text-gray-500 flex items-center gap-1">
                          <Phone size={14} />
                          {selectedUser.phone}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Stats */}
                  <div className="grid grid-cols-3 gap-4 mb-6">
                    <div className="p-4 rounded-lg" style={{ backgroundColor: '#F0F5F1' }}>
                      <p className="text-xs text-gray-500 mb-1">JOINED</p>
                      <p className="text-sm font-bold" style={{ color: '#0C3B2E' }}>
                        {formatDate(selectedUser.created_at)}
                      </p>
                    </div>
                    <div className="p-4 rounded-lg" style={{ backgroundColor: '#F0F5F1' }}>
                      <p className="text-xs text-gray-500 mb-1">TOTAL BOOKINGS</p>
                      <p className="text-lg font-bold" style={{ color: '#0C3B2E' }}>
                        {selectedUser.total_bookings}
                      </p>
                    </div>
                    <div className="p-4 rounded-lg" style={{ backgroundColor: '#FEF3C7' }}>
                      <p className="text-xs text-gray-500 mb-1">TOTAL SPENT</p>
                      <p className="text-lg font-bold" style={{ color: '#BB8A52' }}>
                        PKR {parseFloat(selectedUser.total_spent).toLocaleString()}
                      </p>
                    </div>
                  </div>

                  {/* Bookings List */}
                  <div>
                    <h4 className="text-sm font-bold mb-3" style={{ color: '#0C3B2E' }}>
                      RECENT BOOKINGS
                    </h4>
                    {selectedUser.bookings.length === 0 ? (
                      <div className="text-center py-8 text-gray-400 text-sm">
                        No bookings yet
                      </div>
                    ) : (
                      <div className="space-y-2">
                        {selectedUser.bookings.slice(0, 10).map((b) => {
                          const Icon = typeIcons[b.type] || Ticket
                          return (
                            <div
                              key={`${b.type}-${b.id}`}
                              className="flex items-center gap-3 p-3 rounded-lg border border-gray-100 hover:bg-gray-50"
                            >
                              <div
                                className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
                                style={{ backgroundColor: '#E8F0EA' }}
                              >
                                <Icon size={16} style={{ color: '#6D9773' }} />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-sm font-semibold truncate" style={{ color: '#0C3B2E' }}>
                                  {b.title}
                                </p>
                                <p className="text-xs text-gray-500 capitalize">
                                  {b.type} • {formatDate(b.date)}
                                </p>
                              </div>
                              <div className="text-right">
                                <p className="text-sm font-bold" style={{ color: '#BB8A52' }}>
                                  PKR {parseFloat(b.amount).toLocaleString()}
                                </p>
                                <span className={`text-xs px-2 py-0.5 rounded ${statusColors[b.status] || 'bg-gray-100'}`}>
                                  {b.status?.toUpperCase()}
                                </span>
                              </div>
                            </div>
                          )
                        })}
                      </div>
                    )}
                  </div>
                </>
              ) : (
                <div className="text-center py-12 text-red-500">
                  Failed to load user details
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ============ DELETE CONFIRMATION MODAL ============ */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6">
            <div className="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
              <Trash2 className="text-red-500" size={24} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2" style={{ color: '#0C3B2E' }}>
              Delete User?
            </h3>
            <p className="text-sm text-gray-500 text-center mb-6">
              Are you sure you want to delete <strong>{showDeleteConfirm.name}</strong>?
              This will permanently delete their account and all bookings. This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => setShowDeleteConfirm(null)}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(showDeleteConfirm.id)}
                className="flex-1 py-2.5 bg-red-500 text-white rounded-lg font-semibold text-sm hover:bg-red-600 transition-colors"
              >
                Delete User
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}