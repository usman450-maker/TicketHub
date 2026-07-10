import { useState, useEffect } from 'react'
import {
  RotateCcw, Search, X, CheckCircle, XCircle, Clock,
  DollarSign, User, Mail, Phone, Calendar, Hash, FileText,
  AlertTriangle, ChevronLeft, ChevronRight, Film, Bus, Train,
  Plane, Trophy, TreePine, Eye
} from 'lucide-react'
import {
  getAllRefunds,
  getRefundsStats,
  getRefundDetails,
  approveRefund,
  rejectRefund,
} from '../../services/adminService'

export default function RefundsPage() {
  const [refunds, setRefunds] = useState([])
  const [stats, setStats] = useState({
    total: 0, pending: 0, approved: 0, completed: 0, rejected: 0, totalRefunded: '0',
  })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('pending')
  const [typeFilter, setTypeFilter] = useState('all')
  const [page, setPage] = useState(1)
  const [pagination, setPagination] = useState({})

  const [selectedRefund, setSelectedRefund] = useState(null)
  const [showDetails, setShowDetails] = useState(false)
  const [showApproveConfirm, setShowApproveConfirm] = useState(null)
  const [showRejectModal, setShowRejectModal] = useState(null)
  const [rejectReason, setRejectReason] = useState('')
  const [actionLoading, setActionLoading] = useState(false)

  useEffect(() => {
    loadStats()
  }, [])

  useEffect(() => {
    loadRefunds()
  }, [page, statusFilter, typeFilter])

  useEffect(() => {
    const timer = setTimeout(() => {
      setPage(1)
      loadRefunds()
    }, 500)
    return () => clearTimeout(timer)
  }, [search])

  const loadStats = async () => {
    const res = await getRefundsStats()
    if (res.success) setStats(res.stats)
  }

  const loadRefunds = async () => {
    setLoading(true)
    const res = await getAllRefunds(search, statusFilter, typeFilter, page, 20)
    if (res.success) {
      setRefunds(res.refunds)
      setPagination(res.pagination || {})
    }
    setLoading(false)
  }

  const handleViewDetails = async (id) => {
    const res = await getRefundDetails(id)
    if (res.success) {
      setSelectedRefund(res.refund)
      setShowDetails(true)
    }
  }

  const handleApprove = async () => {
    if (!showApproveConfirm) return
    setActionLoading(true)

    const res = await approveRefund(showApproveConfirm.id)

    setActionLoading(false)

    if (res.success) {
      setShowApproveConfirm(null)
      loadRefunds()
      loadStats()
      alert('✅ Refund approved and processed via Stripe!')
    } else {
      alert(`❌ ${res.message}`)
    }
  }

  const handleReject = async () => {
    if (!showRejectModal || !rejectReason.trim()) {
      alert('Please provide a rejection reason')
      return
    }

    setActionLoading(true)
    const res = await rejectRefund(showRejectModal.id, rejectReason)
    setActionLoading(false)

    if (res.success) {
      setShowRejectModal(null)
      setRejectReason('')
      loadRefunds()
      loadStats()
      alert('Refund rejected. User has been notified.')
    } else {
      alert(res.message)
    }
  }

  const formatDate = (dateStr) => {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric',
    })
  }

  const formatDateTime = (dateStr) => {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric',
      hour: '2-digit', minute: '2-digit'
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

  const statusConfig = {
    pending: { color: 'bg-yellow-100 text-yellow-700', icon: Clock, label: 'PENDING' },
    approved: { color: 'bg-blue-100 text-blue-700', icon: CheckCircle, label: 'APPROVED' },
    completed: { color: 'bg-green-100 text-green-700', icon: CheckCircle, label: 'COMPLETED' },
    rejected: { color: 'bg-red-100 text-red-600', icon: XCircle, label: 'REJECTED' },
  }

  const tabs = [
    { id: 'pending', label: 'Pending', count: stats.pending, color: '#F59E0B' },
    { id: 'approved', label: 'Approved', count: stats.approved, color: '#3B82F6' },
    { id: 'completed', label: 'Completed', count: stats.completed, color: '#10B981' },
    { id: 'rejected', label: 'Rejected', count: stats.rejected, color: '#EF4444' },
    { id: 'all', label: 'All Refunds', count: stats.total, color: '#6D9773' },
  ]

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
          Refunds Management
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          Review, approve, or reject refund requests. Process payments via Stripe.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ backgroundColor: '#6D9773' }}>
            <RotateCcw className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">TOTAL</p>
          <p className="text-xl font-bold" style={{ color: '#0C3B2E' }}>{stats.total}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-yellow-500">
            <Clock className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">PENDING</p>
          <p className="text-xl font-bold text-yellow-600">{stats.pending}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-green-500">
            <CheckCircle className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">COMPLETED</p>
          <p className="text-xl font-bold text-green-600">{stats.completed}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-red-500">
            <XCircle className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">REJECTED</p>
          <p className="text-xl font-bold text-red-500">{stats.rejected}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ backgroundColor: '#BB8A52' }}>
            <DollarSign className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">TOTAL REFUNDED</p>
          <p className="text-lg font-bold" style={{ color: '#BB8A52' }}>
            PKR {parseFloat(stats.totalRefunded).toLocaleString()}
          </p>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white p-2 rounded-xl border border-gray-100 mb-4">
        <div className="flex flex-wrap gap-2">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => { setStatusFilter(tab.id); setPage(1) }}
              className={`px-4 py-2 rounded-lg text-sm font-semibold transition-all flex items-center gap-2 ${
                statusFilter === tab.id ? 'text-white shadow-sm' : 'text-gray-600 hover:bg-gray-50'
              }`}
              style={{
                backgroundColor: statusFilter === tab.id ? tab.color : 'transparent',
              }}
            >
              {tab.label}
              <span
                className="text-xs px-2 py-0.5 rounded-full"
                style={{
                  backgroundColor: statusFilter === tab.id ? 'rgba(255,255,255,0.3)' : `${tab.color}20`,
                  color: statusFilter === tab.id ? 'white' : tab.color,
                }}
              >
                {tab.count}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Search & Type Filter */}
      <div className="bg-white p-4 rounded-xl border border-gray-100 mb-4 flex gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by user or order number..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300"
          />
        </div>
        <select
          value={typeFilter}
          onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
          className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300 cursor-pointer"
        >
          <option value="all">All Types</option>
          <option value="movie">Movies</option>
          <option value="bus">Bus</option>
          <option value="train">Train</option>
          <option value="flight">Flights</option>
          <option value="event">Events</option>
          <option value="park">Parks</option>
        </select>
      </div>

      {/* Refunds Table */}
      <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-gray-400">Loading refunds...</div>
        ) : refunds.length === 0 ? (
          <div className="p-12 text-center">
            <RotateCcw size={48} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500">No {statusFilter !== 'all' ? statusFilter : ''} refunds found</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead style={{ backgroundColor: '#F0F5F1' }}>
                  <tr>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">USER</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">ORDER #</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">TYPE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">ORIGINAL</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">REFUND</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">REASON</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">STATUS</th>
                    <th className="text-right p-4 text-xs font-semibold text-gray-600 tracking-wider">ACTIONS</th>
                  </tr>
                </thead>
                <tbody>
                  {refunds.map((r) => {
                    const Icon = typeIcons[r.booking_type] || RotateCcw
                    const status = statusConfig[r.status] || statusConfig.pending
                    const StatusIcon = status.icon

                    return (
                      <tr key={r.id} className="border-t border-gray-50 hover:bg-gray-50 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            <div
                              className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold"
                              style={{ backgroundColor: '#6D9773' }}
                            >
                              {(r.user_name || 'U')[0].toUpperCase()}
                            </div>
                            <div>
                              <p className="text-sm font-semibold truncate max-w-[140px]">
                                {r.user_name || 'Guest'}
                              </p>
                              <p className="text-xs text-gray-400 truncate max-w-[140px]">
                                {r.user_email}
                              </p>
                            </div>
                          </div>
                        </td>

                        <td className="p-4">
                          <p className="text-xs font-mono font-semibold" style={{ color: '#0C3B2E' }}>
                            #{r.order_number}
                          </p>
                        </td>

                        <td className="p-4">
                          <div className="inline-flex items-center gap-1.5">
                            <Icon size={14} style={{ color: '#6D9773' }} />
                            <span className="text-xs font-semibold capitalize">
                              {r.booking_type}
                            </span>
                          </div>
                        </td>

                        <td className="p-4 text-sm text-gray-500">
                          PKR {parseFloat(r.original_amount).toLocaleString()}
                        </td>

                        <td className="p-4">
                          <p className="text-sm font-bold" style={{ color: '#BB8A52' }}>
                            PKR {parseFloat(r.refund_amount).toLocaleString()}
                          </p>
                        </td>

                        <td className="p-4">
                          <p className="text-xs text-gray-600 truncate max-w-[150px]" title={r.reason}>
                            {r.reason}
                          </p>
                        </td>

                        <td className="p-4">
                          <span className={`inline-flex items-center gap-1 text-xs font-bold px-2 py-1 rounded ${status.color}`}>
                            <StatusIcon size={10} />
                            {status.label}
                          </span>
                        </td>

                        <td className="p-4">
                          <div className="flex items-center justify-end gap-1">
                            <button
                              onClick={() => handleViewDetails(r.id)}
                              className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
                              title="View Details"
                            >
                              <Eye size={16} style={{ color: '#6D9773' }} />
                            </button>
                            {r.status === 'pending' && (
                              <>
                                <button
                                  onClick={() => setShowApproveConfirm(r)}
                                  className="px-3 py-1.5 bg-green-500 text-white text-xs font-semibold rounded-lg hover:bg-green-600 transition-colors"
                                >
                                  Approve
                                </button>
                                <button
                                  onClick={() => setShowRejectModal(r)}
                                  className="px-3 py-1.5 bg-red-500 text-white text-xs font-semibold rounded-lg hover:bg-red-600 transition-colors"
                                >
                                  Reject
                                </button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {pagination.totalPages > 1 && (
              <div className="flex items-center justify-between p-4 border-t border-gray-100">
                <p className="text-sm text-gray-500">
                  Showing {refunds.length} of {pagination.total}
                </p>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setPage(Math.max(1, page - 1))}
                    disabled={page === 1}
                    className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50"
                  >
                    <ChevronLeft size={16} />
                  </button>
                  <span className="px-4 py-2 text-sm font-semibold" style={{ color: '#0C3B2E' }}>
                    Page {page} of {pagination.totalPages}
                  </span>
                  <button
                    onClick={() => setPage(Math.min(pagination.totalPages, page + 1))}
                    disabled={page >= pagination.totalPages}
                    className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50"
                  >
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* ============ APPROVE CONFIRMATION MODAL ============ */}
      {showApproveConfirm && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6">
            <div className="w-14 h-14 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="text-green-600" size={28} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2" style={{ color: '#0C3B2E' }}>
              Approve Refund?
            </h3>
            <p className="text-sm text-gray-500 text-center mb-4">
              Refund of <strong className="text-primary" style={{ color: '#BB8A52' }}>
                PKR {parseFloat(showApproveConfirm.refund_amount).toLocaleString()}
              </strong> will be processed via Stripe for order <strong>#{showApproveConfirm.order_number}</strong>.
            </p>
            <div className="p-3 bg-yellow-50 border border-yellow-200 rounded-lg mb-4">
              <p className="text-xs text-yellow-800">
                ⚠️ This action cannot be undone. The amount will be refunded to the user's original payment method.
              </p>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowApproveConfirm(null)}
                disabled={actionLoading}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleApprove}
                disabled={actionLoading}
                className="flex-1 py-2.5 bg-green-500 text-white rounded-lg font-semibold text-sm hover:bg-green-600 disabled:opacity-50"
              >
                {actionLoading ? 'Processing...' : 'Approve & Refund'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ============ REJECT MODAL ============ */}
      {showRejectModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6">
            <div className="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
              <XCircle className="text-red-500" size={28} />
            </div>
            <h3 className="text-xl font-bold text-center mb-2" style={{ color: '#0C3B2E' }}>
              Reject Refund?
            </h3>
            <p className="text-sm text-gray-500 text-center mb-4">
              Please provide a reason for rejecting this refund request.
            </p>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Reason for rejection..."
              rows="4"
              className="w-full p-3 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300 mb-4"
            />
            <div className="flex gap-3">
              <button
                onClick={() => { setShowRejectModal(null); setRejectReason('') }}
                disabled={actionLoading}
                className="flex-1 py-2.5 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleReject}
                disabled={actionLoading || !rejectReason.trim()}
                className="flex-1 py-2.5 bg-red-500 text-white rounded-lg font-semibold text-sm hover:bg-red-600 disabled:opacity-50"
              >
                {actionLoading ? 'Rejecting...' : 'Reject Refund'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ============ DETAILS MODAL ============ */}
      {showDetails && selectedRefund && (
        <div
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setShowDetails(false)}
        >
          <div
            className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <div>
                <h2 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>Refund Details</h2>
                <p className="text-xs text-gray-500 mt-1">Order #{selectedRefund.order_number}</p>
              </div>
              <button onClick={() => setShowDetails(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <X size={20} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {/* Status */}
              <div className="text-center py-4">
                {(() => {
                  const status = statusConfig[selectedRefund.status]
                  const Icon = status.icon
                  return (
                    <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-full ${status.color}`}>
                      <Icon size={16} />
                      <span className="font-bold">{status.label}</span>
                    </div>
                  )
                })()}
              </div>

              {/* User */}
              <div className="p-4 rounded-lg" style={{ backgroundColor: '#F0F5F1' }}>
                <p className="text-xs text-gray-500 font-semibold mb-3">USER INFORMATION</p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <User size={14} style={{ color: '#6D9773' }} />
                    <span className="font-medium">{selectedRefund.user_name}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <Mail size={14} style={{ color: '#6D9773' }} />
                    {selectedRefund.user_email}
                  </div>
                  {selectedRefund.user_phone && (
                    <div className="flex items-center gap-2 text-gray-600">
                      <Phone size={14} style={{ color: '#6D9773' }} />
                      {selectedRefund.user_phone}
                    </div>
                  )}
                </div>
              </div>

              {/* Refund Info */}
              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 border border-gray-100 rounded-lg">
                  <p className="text-xs text-gray-500 font-semibold mb-1">BOOKING TYPE</p>
                  <p className="text-sm font-bold capitalize" style={{ color: '#0C3B2E' }}>
                    {selectedRefund.booking_type}
                  </p>
                </div>
                <div className="p-4 border border-gray-100 rounded-lg">
                  <p className="text-xs text-gray-500 font-semibold mb-1">ORDER NUMBER</p>
                  <p className="text-sm font-bold" style={{ color: '#0C3B2E' }}>
                    #{selectedRefund.order_number}
                  </p>
                </div>
                <div className="p-4 border border-gray-100 rounded-lg">
                  <p className="text-xs text-gray-500 font-semibold mb-1">ORIGINAL AMOUNT</p>
                  <p className="text-sm font-bold text-gray-700">
                    PKR {parseFloat(selectedRefund.original_amount).toLocaleString()}
                  </p>
                </div>
                <div className="p-4 border border-gray-100 rounded-lg">
                  <p className="text-xs text-gray-500 font-semibold mb-1">REFUND AMOUNT</p>
                  <p className="text-lg font-bold" style={{ color: '#BB8A52' }}>
                    PKR {parseFloat(selectedRefund.refund_amount).toLocaleString()}
                  </p>
                </div>
              </div>

              {/* Reason */}
              <div className="p-4 rounded-lg" style={{ backgroundColor: '#FEF3C7' }}>
                <p className="text-xs text-yellow-800 font-semibold mb-2">USER'S REASON</p>
                <p className="text-sm text-gray-700 italic">"{selectedRefund.reason}"</p>
              </div>

              {/* Admin Notes */}
              {selectedRefund.admin_notes && (
                <div className="p-4 rounded-lg border border-gray-100">
                  <p className="text-xs text-gray-500 font-semibold mb-2">ADMIN NOTES</p>
                  <p className="text-sm text-gray-700">{selectedRefund.admin_notes}</p>
                </div>
              )}

              {/* Timestamps */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs">
                <div className="p-3 bg-gray-50 rounded-lg">
                  <p className="text-gray-500 font-semibold mb-1">REQUESTED</p>
                  <p className="font-medium">{formatDateTime(selectedRefund.created_at)}</p>
                </div>
                {selectedRefund.processed_at && (
                  <div className="p-3 bg-gray-50 rounded-lg">
                    <p className="text-gray-500 font-semibold mb-1">PROCESSED</p>
                    <p className="font-medium">{formatDateTime(selectedRefund.processed_at)}</p>
                  </div>
                )}
                {selectedRefund.completed_at && (
                  <div className="p-3 bg-gray-50 rounded-lg">
                    <p className="text-gray-500 font-semibold mb-1">COMPLETED</p>
                    <p className="font-medium">{formatDateTime(selectedRefund.completed_at)}</p>
                  </div>
                )}
              </div>

              {/* Stripe ID */}
              {selectedRefund.stripe_refund_id && (
                <div className="p-3 bg-blue-50 rounded-lg">
                  <p className="text-xs text-blue-700 font-semibold mb-1">STRIPE REFUND ID</p>
                  <p className="text-xs font-mono break-all text-blue-900">{selectedRefund.stripe_refund_id}</p>
                </div>
              )}
            </div>

            {/* Actions in Modal (only for pending) */}
            {selectedRefund.status === 'pending' && (
              <div className="p-4 border-t border-gray-100 flex gap-3">
                <button
                  onClick={() => {
                    setShowDetails(false)
                    setShowRejectModal(selectedRefund)
                  }}
                  className="flex-1 py-2.5 bg-red-500 text-white rounded-lg font-semibold text-sm hover:bg-red-600"
                >
                  Reject
                </button>
                <button
                  onClick={() => {
                    setShowDetails(false)
                    setShowApproveConfirm(selectedRefund)
                  }}
                  className="flex-1 py-2.5 bg-green-500 text-white rounded-lg font-semibold text-sm hover:bg-green-600"
                >
                  Approve & Refund
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}