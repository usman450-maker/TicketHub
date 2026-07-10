import { useState, useEffect } from 'react'
import {
  Search, Eye, ChevronLeft, ChevronRight, X, TrendingUp,
  Ticket, DollarSign, Award, Calendar, User, Mail, MapPin,
  CheckCircle, XCircle, AlertCircle
} from 'lucide-react'
import { getCategoryData } from '../services/adminService'

export default function CategoryPageTemplate({
  category,
  title,
  description,
  icon: MainIcon,
  themeColor,
  statLabels = {
    label1: 'Total Items',
    label2: 'Total Revenue',
    label3: 'Avg Booking',
  },
  showTypeFilter = false,
  typeOptions = [],
  columns = [],
}) {
  const [data, setData] = useState({
    bookings: [],
    stats: {},
    topItems: [],
    pagination: {},
  })
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('all')
  const [type, setType] = useState('all')
  const [page, setPage] = useState(1)
  const [selectedBooking, setSelectedBooking] = useState(null)
  const [showDetails, setShowDetails] = useState(false)

  useEffect(() => {
    loadData()
  }, [page, status, type])

  useEffect(() => {
    const timer = setTimeout(() => {
      setPage(1)
      loadData()
    }, 500)
    return () => clearTimeout(timer)
  }, [search])

  const loadData = async () => {
    setLoading(true)
    const filters = { search, status, page, limit: 20 }
    if (showTypeFilter) filters.type = type

    const res = await getCategoryData(category, filters)

    if (res.success) {
      setData({
        bookings: res.bookings || [],
        stats: res.stats || {},
        topItems: res.topItems || [],
        pagination: res.pagination || {},
      })
    }
    setLoading(false)
  }

  const formatDate = (dateStr) => {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric',
    })
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

  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold flex items-center gap-3" style={{ color: '#0C3B2E' }}>
          <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: themeColor }}>
            <MainIcon className="text-white" size={20} />
          </div>
          {title}
        </h1>
        <p className="text-sm text-gray-500 mt-1 ml-13">{description}</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <StatCard icon={Ticket} label="TOTAL BOOKINGS" value={data.stats.totalBookings || 0} color="#6D9773" />
        <StatCard icon={Award} label={statLabels.label1?.toUpperCase()} value={data.stats.totalMovies || data.stats.totalEvents || data.stats.totalMatches || data.stats.totalParks || Object.keys(data.stats.byType || {}).length} color={themeColor} />
        <StatCard icon={DollarSign} label="TOTAL REVENUE" value={`PKR ${parseFloat(data.stats.totalRevenue || 0).toLocaleString()}`} color="#BB8A52" />
        <StatCard icon={TrendingUp} label="AVG BOOKING" value={`PKR ${parseFloat(data.stats.avgBooking || 0).toFixed(0)}`} color="#0C3B2E" />
      </div>

      {/* Top Items */}
      {data.topItems.length > 0 && (
        <div className="bg-white p-5 rounded-xl border border-gray-100 mb-6">
          <h3 className="font-bold mb-4 flex items-center gap-2" style={{ color: '#0C3B2E' }}>
            <Award size={18} style={{ color: themeColor }} />
            Top Performing {title}
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
            {data.topItems.slice(0, 5).map((item, i) => (
              <div key={i} className="p-3 rounded-lg border border-gray-100 hover:shadow-md transition-all">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold px-2 py-0.5 rounded" style={{ backgroundColor: `${themeColor}20`, color: themeColor }}>
                    #{i + 1}
                  </span>
                  <span className="text-xs text-gray-500">{item.bookings} bookings</span>
                </div>
                <p className="text-sm font-semibold truncate mb-1" style={{ color: '#0C3B2E' }}>
                  {item.movie_title || item.event_name || item.operator_name || item.park_name || 'Unknown'}
                </p>
                <p className="text-xs text-gray-500 truncate">
                  {item.venue || item.from_location || item.park_city || item.city || '-'}
                </p>
                <p className="text-sm font-bold mt-2" style={{ color: '#BB8A52' }}>
                  PKR {parseFloat(item.revenue || 0).toLocaleString()}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white p-4 rounded-xl border border-gray-100 mb-4 flex flex-col md:flex-row gap-3">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search..."
            className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:border-gray-300"
          />
        </div>

        {showTypeFilter && (
          <select
            value={type}
            onChange={(e) => { setType(e.target.value); setPage(1) }}
            className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none cursor-pointer"
          >
            <option value="all">All Types</option>
            {typeOptions.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>
        )}

        <select
          value={status}
          onChange={(e) => { setStatus(e.target.value); setPage(1) }}
          className="px-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none cursor-pointer"
        >
          <option value="all">All Status</option>
          <option value="paid">Paid</option>
          <option value="pending">Pending</option>
          <option value="cancelled">Cancelled</option>
          <option value="refunded">Refunded</option>
        </select>
      </div>

      {/* Bookings Table */}
      <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-gray-400">Loading...</div>
        ) : data.bookings.length === 0 ? (
          <div className="p-12 text-center">
            <MainIcon size={48} className="mx-auto text-gray-300 mb-3" />
            <p className="text-gray-500">No bookings found</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead style={{ backgroundColor: '#F0F5F1' }}>
                  <tr>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">USER</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">DETAILS</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">DATE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">AMOUNT</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-600 tracking-wider">STATUS</th>
                    <th className="text-right p-4 text-xs font-semibold text-gray-600 tracking-wider">ACTION</th>
                  </tr>
                </thead>
                <tbody>
                  {data.bookings.map((b, i) => {
                    const StatusIcon = statusIcons[b.payment_status] || AlertCircle
                    return (
                      <tr key={i} className="border-t border-gray-50 hover:bg-gray-50 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            <div className="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold" style={{ backgroundColor: '#6D9773' }}>
                              {(b.user_name || 'U')[0].toUpperCase()}
                            </div>
                            <div className="min-w-0">
                              <p className="text-sm font-semibold truncate max-w-[150px]">{b.user_name}</p>
                              <p className="text-xs text-gray-400 truncate max-w-[150px]">{b.user_email}</p>
                            </div>
                          </div>
                        </td>
                        <td className="p-4">
                          <p className="text-sm font-medium truncate max-w-[200px]" style={{ color: '#0C3B2E' }}>
                            {b.movie_title || b.event_name || b.operator_name || b.park_name || 'Booking'}
                          </p>
                          <p className="text-xs text-gray-400">#{b.order_number}</p>
                        </td>
                        <td className="p-4 text-sm text-gray-600">
                          {formatDate(b.created_at)}
                        </td>
                        <td className="p-4">
                          <p className="text-sm font-bold" style={{ color: '#BB8A52' }}>
                            PKR {parseFloat(b.total_amount).toLocaleString()}
                          </p>
                        </td>
                        <td className="p-4">
                          <span className={`inline-flex items-center gap-1 text-xs font-bold px-2 py-1 rounded ${statusColors[b.payment_status] || 'bg-gray-100'}`}>
                            <StatusIcon size={10} />
                            {b.payment_status?.toUpperCase()}
                          </span>
                        </td>
                        <td className="p-4 text-right">
                          <button
                            onClick={() => { setSelectedBooking(b); setShowDetails(true) }}
                            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
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
            {data.pagination.totalPages > 1 && (
              <div className="flex items-center justify-between p-4 border-t border-gray-100">
                <p className="text-sm text-gray-500">
                  Page {page} of {data.pagination.totalPages}
                </p>
                <div className="flex items-center gap-2">
                  <button onClick={() => setPage(Math.max(1, page - 1))} disabled={page === 1} className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50">
                    <ChevronLeft size={16} />
                  </button>
                  <span className="px-4 py-2 text-sm font-semibold" style={{ color: '#0C3B2E' }}>{page}</span>
                  <button onClick={() => setPage(Math.min(data.pagination.totalPages, page + 1))} disabled={page >= data.pagination.totalPages} className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 disabled:opacity-50">
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {/* Details Modal */}
      {showDetails && selectedBooking && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setShowDetails(false)}>
          <div className="bg-white rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden flex flex-col" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <div>
                <h2 className="text-xl font-bold" style={{ color: '#0C3B2E' }}>Booking Details</h2>
                <p className="text-xs text-gray-500 mt-1">#{selectedBooking.order_number}</p>
              </div>
              <button onClick={() => setShowDetails(false)} className="p-2 hover:bg-gray-100 rounded-lg">
                <X size={20} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {/* User */}
              <div className="p-4 rounded-lg" style={{ backgroundColor: '#F0F5F1' }}>
                <p className="text-xs text-gray-500 font-semibold mb-3">USER</p>
                <div className="space-y-2 text-sm">
                  <div className="flex items-center gap-2">
                    <User size={14} style={{ color: '#6D9773' }} />
                    <span className="font-medium">{selectedBooking.user_name}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <Mail size={14} style={{ color: '#6D9773' }} />
                    {selectedBooking.user_email}
                  </div>
                </div>
              </div>

              {/* All Details */}
              <div className="grid grid-cols-2 gap-3">
                {Object.entries(selectedBooking).filter(([key]) => 
                  !['id', 'user_id', 'user_name', 'user_email', 'created_at', 'passenger_details', 'seat_gender_map', 'person_details', 'seat_numbers', 'seats', 'addons'].includes(key) && selectedBooking[key]
                ).map(([key, value]) => (
                  <div key={key} className="p-3 border border-gray-100 rounded-lg">
                    <p className="text-xs text-gray-500 font-semibold mb-1 uppercase">
                      {key.replace(/_/g, ' ')}
                    </p>
                    <p className="text-sm font-medium truncate" style={{ color: '#0C3B2E' }}>
                      {typeof value === 'object' ? JSON.stringify(value) : String(value).slice(0, 50)}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// Stat Card Component
function StatCard({ icon: Icon, label, value, color }) {
  return (
    <div className="bg-white p-5 rounded-xl border border-gray-100">
      <div className="w-10 h-10 rounded-lg flex items-center justify-center mb-3" style={{ backgroundColor: color }}>
        <Icon className="text-white" size={20} />
      </div>
      <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">{label}</p>
      <p className="text-lg font-bold" style={{ color: '#0C3B2E' }}>{value}</p>
    </div>
  )
}