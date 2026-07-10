import { useState, useEffect } from 'react'
import {
  Ticket, Search, Filter, Eye, X, Calendar, MapPin,
  User, Mail, Phone, DollarSign, Clock, Hash,
  Film, Bus, Train, Plane, Trophy, TreePine,
  ChevronLeft, ChevronRight, CheckCircle, XCircle, AlertCircle
} from 'lucide-react'
import {
  getAllBookings,
  getBookingsStats,
  getBookingDetails,
} from '../../services/adminService'

export default function BookingsPage() {
  const [bookings, setBookings] = useState([])
  const [stats, setStats] = useState({
    total: 0, paid: 0, pending: 0, cancelled: 0, revenue: '0',
  })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [typeFilter, setTypeFilter] = useState('all')
  const [statusFilter, setStatusFilter] = useState('all')
  const [page, setPage] = useState(1)
  const [pagination, setPagination] = useState({})
  const [selectedBooking, setSelectedBooking] = useState(null)
  const [showDetails, setShowDetails] = useState(false)
  const [detailsLoading, setDetailsLoading] = useState(false)

  useEffect(() => {
    loadStats()
  }, [])

  useEffect(() => {
    loadBookings()
  }, [page, typeFilter, statusFilter])

  useEffect(() => {
    const timer = setTimeout(() => {
      setPage(1)
      loadBookings()
    }, 500)
    return () => clearTimeout(timer)
  }, [search])

  const loadStats = async () => {
    const res = await getBookingsStats()
    if (res.success) setStats(res.stats)
  }

  const loadBookings = async () => {
    setLoading(true)
    const res = await getAllBookings(search, typeFilter, statusFilter, page, 20)
    if (res.success) {
      setBookings(res.bookings)
      setPagination(res.pagination || {})
    }
    setLoading(false)
  }

  const handleViewDetails = async (booking) => {
    setDetailsLoading(true)
    setShowDetails(true)
    const res = await getBookingDetails(booking.type, booking.id)
    if (res.success) {
      setSelectedBooking(res.booking)
    }
    setDetailsLoading(false)
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

  const typeColors = {
    movie: '#6D9773',
    bus: '#BB8A52',
    train: '#4A6D51',
    flight: '#EF4444',
    sports: '#0C3B2E',
    event: '#B5CBB9',
    park: '#F59E0B',
  }

  const statusColors = {
    paid: 'bg-green-100 text-green-700',
    pending: 'bg-yellow-100 text-yellow-700',
    cancelled: 'bg-red-100 text-red-600',
    refunded: 'bg-blue-100 text-blue-700',
  }

  const statusIcons = {
    paid: CheckCircle,
    pending: AlertCircle,
    cancelled: XCircle,
    refunded: CheckCircle,
  }

  const typeOptions = [
    { value: 'all', label: 'All Types' },
    { value: 'movie', label: 'Movies' },
    { value: 'bus', label: 'Bus' },
    { value: 'train', label: 'Train' },
    { value: 'flight', label: 'Flights' },
    { value: 'event', label: 'Events' },
    { value: 'park', label: 'Parks' },
  ]

  const statusOptions = [
    { value: 'all', label: 'All Status' },
    { value: 'paid', label: 'Paid' },
    { value: 'pending', label: 'Pending' },
    { value: 'cancelled', label: 'Cancelled' },
    { value: 'refunded', label: 'Refunded' },
  ]

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
          All Bookings
        </h1>
        <p className="text-sm text-gray-500 mt-1">
          View and manage all bookings across TicketHub platform.
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ backgroundColor: '#6D9773' }}>
            <Ticket className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">TOTAL</p>
          <p className="text-xl font-bold" style={{ color: '#0C3B2E' }}>{stats.total}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-green-500">
            <CheckCircle className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">PAID</p>
          <p className="text-xl font-bold text-green-600">{stats.paid}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-yellow-500">
            <AlertCircle className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">PENDING</p>
          <p className="text-xl font-bold text-yellow-600">{stats.pending}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3 bg-red-500">
            <XCircle className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">CANCELLED</p>
          <p className="text-xl font-bold text-red-500">{stats.cancelled}</p>
        </div>

        <div className="bg-white p-4 rounded-xl border border-gray-100">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ backgroundColor: '#BB8A52' }}>
            <DollarSign className="text-white" size={18} />
          </div>
          <p className="text-xs text-gray-500 font-semibold mb-1">REVENUE</p>
          <p className="text-lg font-bold" style={{ color: '#BB8A52' }}>
            PKR {parseFloat(stats.revenue).toLocaleString()}
          </p>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="bg-white p-4 rounded-xl border border-gray-100 mb-4">
        <div className="flex flex-col md:flex-row gap-3">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by user, title, or order number..."
              className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300"
            />
          </div>

          <select
            value={typeFilter}
            onChange={(e) => { setTypeFilter(e.target.value); setPage(1); }}
            className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300 cursor-pointer"
          >
            {typeOptions.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>

          <select
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
            className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300 cursor-pointer"
          >
            {statusOptions.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Bookings Table */}
      <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-gray-400">Loading bookings...</div>
        ) : bookings.length === 0 ? (
          <div className="p-12 text-center">
            <Ticket size={48} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500">No bookings found</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead style={{ backgroundColor: '#F0F5F1' }}>
                  <tr>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">USER</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">TYPE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">DETAILS</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">AMOUNT</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">DATE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">STATUS</th>
                    <th className="text-right p-4 text-xs font-semibold text-gray-600 tracking-wider">ACTION</th>
                  </tr>
                </thead>
                <tbody>
                  {bookings.map((b, i) => {
                    const Icon = typeIcons[b.type] || Ticket
                    const color = typeColors[b.type] || '#6D9773'
                    const StatusIcon = statusIcons[b.status] || AlertCircle

                    return (
                      <tr key={`${b.type}-${b.id}-${i}`} className="border-t border-gray-50 hover:bg-gray-50 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            <div
                              className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                              style={{ backgroundColor: '#6D9773' }}
                            >
                              {(b.user_name || 'U')[0].toUpperCase()}
                            </div>
                            <div className="min-w-0">
                              <p className="text-sm font-semibold truncate max-w-[140px]">
                                {b.user_name || 'Guest'}
                              </p>
                              <p className="text-xs text-gray-400 truncate max-w-[140px]">
                                {b.user_email}
                              </p>
                            </div>
                          </div>
                        </td>

                        <td className="p-4">
                          <div
                            className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg"
                            style={{ backgroundColor: `${color}20` }}
                          >
                            <Icon size={14} style={{ color }} />
                            <span className="text-xs font-semibold capitalize" style={{ color }}>
                              {b.type}
                            </span>
                          </div>
                        </td>

                        <td className="p-4">
                          <p className="text-sm font-medium truncate max-w-[200px]" style={{ color: '#0C3B2E' }}>
                            {b.title}
                          </p>
                          <p className="text-xs text-gray-400 truncate max-w-[200px]">
                            #{b.order_number}
                          </p>
                        </td>

                        <td className="p-4">
                          <p className="text-sm font-bold" style={{ color: '#BB8A52' }}>
                            PKR {parseFloat(b.total_amount).toLocaleString()}
                          </p>
                        </td>

                        <td className="p-4 text-sm text-gray-600">
                          {formatDate(b.created_at)}
                        </td>

                        <td className="p-4">
                          <span className={`inline-flex items-center gap-1 text-xs font-bold px-2 py-1 rounded ${statusColors[b.status] || 'bg-gray-100 text-gray-600'}`}>
                            <StatusIcon size={10} />
                            {b.status?.toUpperCase()}
                          </span>
                        </td>

                        <td className="p-4 text-right">
                          <button
                            onClick={() => handleViewDetails(b)}
                            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
                            title="View Details"
                          >
                            <Eye size={16} style={{ color: '#6D9773' }} />
                          </button>
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
                  Showing {bookings.length} of {pagination.total} bookings
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
                    Page {page} of {pagination.totalPages}
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

      {/* ============ BOOKING DETAILS MODAL ============ */}
      {showDetails && (
        <div
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={() => setShowDetails(false)}
        >
          <div
            className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <div>
                <h2 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>
                  Booking Details
                </h2>
                {selectedBooking && (
                  <p className="text-xs text-gray-500 mt-1">
                    Order #{selectedBooking.order_number}
                  </p>
                )}
              </div>
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
                <div className="text-center py-12 text-gray-400">Loading...</div>
              ) : selectedBooking ? (
                <div className="space-y-6">
                  {/* Type Badge */}
                  <div className="flex items-center gap-3">
                    {(() => {
                      const Icon = typeIcons[selectedBooking.type] || Ticket
                      const color = typeColors[selectedBooking.type] || '#6D9773'
                      return (
                        <>
                          <div
                            className="w-14 h-14 rounded-xl flex items-center justify-center"
                            style={{ backgroundColor: color }}
                          >
                            <Icon className="text-white" size={26} />
                          </div>
                          <div>
                            <p className="text-xs text-gray-500 font-semibold uppercase">
                              {selectedBooking.type} Booking
                            </p>
                            <p className="text-lg font-bold" style={{ color: '#0C3B2E' }}>
                              {selectedBooking.movie_title ||
                                selectedBooking.operator_name ||
                                selectedBooking.event_name ||
                                selectedBooking.park_name ||
                                'Booking'}
                            </p>
                          </div>
                        </>
                      )
                    })()}
                  </div>

                  {/* User Info */}
                  <div className="p-4 rounded-lg" style={{ backgroundColor: '#F0F5F1' }}>
                    <p className="text-xs text-gray-500 font-semibold mb-3">USER INFORMATION</p>
                    <div className="space-y-2">
                      <div className="flex items-center gap-2 text-sm">
                        <User size={14} style={{ color: '#6D9773' }} />
                        <span className="font-medium">{selectedBooking.user_name || 'Guest'}</span>
                      </div>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <Mail size={14} style={{ color: '#6D9773' }} />
                        {selectedBooking.user_email}
                      </div>
                      {selectedBooking.user_phone && (
                        <div className="flex items-center gap-2 text-sm text-gray-600">
                          <Phone size={14} style={{ color: '#6D9773' }} />
                          {selectedBooking.user_phone}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Booking Info */}
                  <div className="grid grid-cols-2 gap-4">
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-1">ORDER NUMBER</p>
                      <p className="text-sm font-bold" style={{ color: '#0C3B2E' }}>
                        {selectedBooking.order_number}
                      </p>
                    </div>
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-1">STATUS</p>
                      <span className={`inline-flex text-xs font-bold px-2 py-1 rounded ${statusColors[selectedBooking.payment_status] || 'bg-gray-100'}`}>
                        {selectedBooking.payment_status?.toUpperCase()}
                      </span>
                    </div>
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-1">TOTAL AMOUNT</p>
                      <p className="text-lg font-bold" style={{ color: '#BB8A52' }}>
                        PKR {parseFloat(selectedBooking.total_amount).toLocaleString()}
                      </p>
                    </div>
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-1">BOOKED ON</p>
                      <p className="text-sm font-medium" style={{ color: '#0C3B2E' }}>
                        {formatDateTime(selectedBooking.created_at)}
                      </p>
                    </div>
                  </div>

                  {/* Type-specific Info */}
                  {selectedBooking.type === 'movie' && (
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-3">MOVIE DETAILS</p>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-600">Venue:</span>
                          <span className="font-semibold">{selectedBooking.venue_name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Show Date:</span>
                          <span className="font-semibold">{formatDate(selectedBooking.show_date)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Show Time:</span>
                          <span className="font-semibold">{selectedBooking.show_time}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Seats:</span>
                          <span className="font-semibold">
                            {Array.isArray(selectedBooking.seats)
                              ? selectedBooking.seats.join(', ')
                              : selectedBooking.seats}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Screen:</span>
                          <span className="font-semibold">Screen {selectedBooking.screen_number}</span>
                        </div>
                      </div>
                    </div>
                  )}

                  {['bus', 'train', 'flight'].includes(selectedBooking.type) && (
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-3">TRANSPORT DETAILS</p>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-600">Operator:</span>
                          <span className="font-semibold">{selectedBooking.operator_name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Route:</span>
                          <span className="font-semibold">
                            {selectedBooking.from_location} → {selectedBooking.to_location}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Departure:</span>
                          <span className="font-semibold">
                            {formatDate(selectedBooking.departure_date)} {selectedBooking.departure_time}
                          </span>
                        </div>
                        {selectedBooking.class_type && (
                          <div className="flex justify-between">
                            <span className="text-gray-600">Class:</span>
                            <span className="font-semibold">{selectedBooking.class_type}</span>
                          </div>
                        )}
                        <div className="flex justify-between">
                          <span className="text-gray-600">Seats:</span>
                          <span className="font-semibold">
                            {Array.isArray(selectedBooking.seat_numbers)
                              ? selectedBooking.seat_numbers.join(', ')
                              : selectedBooking.seat_numbers}
                          </span>
                        </div>
                      </div>
                    </div>
                  )}

                  {selectedBooking.type === 'event' && (
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-3">EVENT DETAILS</p>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-600">Event:</span>
                          <span className="font-semibold">{selectedBooking.event_name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Venue:</span>
                          <span className="font-semibold">{selectedBooking.venue}, {selectedBooking.city}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Date:</span>
                          <span className="font-semibold">{formatDate(selectedBooking.event_date)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Time:</span>
                          <span className="font-semibold">{selectedBooking.event_time}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Tier:</span>
                          <span className="font-semibold">{selectedBooking.ticket_tier}</span>
                        </div>
                      </div>
                    </div>
                  )}

                  {selectedBooking.type === 'park' && (
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-3">PARK DETAILS</p>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-600">Park:</span>
                          <span className="font-semibold">{selectedBooking.park_name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">City:</span>
                          <span className="font-semibold">{selectedBooking.park_city}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Visit Date:</span>
                          <span className="font-semibold">{formatDate(selectedBooking.visit_date)}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Guests:</span>
                          <span className="font-semibold">
                            {selectedBooking.adult_qty || 0} Adult, {selectedBooking.child_qty || 0} Child, {selectedBooking.senior_qty || 0} Senior
                          </span>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Payment Info */}
                  {selectedBooking.payment_id && (
                    <div className="p-4 rounded-lg border border-gray-100">
                      <p className="text-xs text-gray-500 font-semibold mb-2">PAYMENT ID</p>
                      <p className="text-xs font-mono text-gray-600 break-all">
                        {selectedBooking.payment_id}
                      </p>
                    </div>
                  )}
                </div>
              ) : (
                <div className="text-center py-12 text-red-500">
                  Failed to load booking details
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}