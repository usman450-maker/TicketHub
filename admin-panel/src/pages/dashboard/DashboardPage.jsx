import { useState, useEffect } from 'react'
import { 
  Users, Ticket, DollarSign, RotateCcw, Plus, 
  Film, Bus, Train, Plane, Trophy, Calendar, TreePine,
  BarChart3
} from 'lucide-react'
import { BarChart, Bar, XAxis, ResponsiveContainer, PieChart, Pie, Cell, Tooltip } from 'recharts'
import StatCard from '../../components/StatCard'
import { getAdmin } from '../../services/authService'
import {
  getDashboardStats,
  getRevenueOverview,
  getBookingsByCategory,
  getRecentBookings,
  getPendingRefunds,
} from '../../services/adminService'

export default function DashboardPage() {
  const admin = getAdmin()
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalBookings: 0,
    totalRevenue: '0',
    pendingRefunds: 0,
  })
  const [revenueData, setRevenueData] = useState([])
  const [categoryData, setCategoryData] = useState([])
  const [recentBookings, setRecentBookings] = useState([])
  const [pendingRefunds, setPendingRefunds] = useState([])

  useEffect(() => {
    loadAllData()
  }, [])

  const loadAllData = async () => {
    setLoading(true)

    const [statsRes, revenueRes, categoryRes, bookingsRes, refundsRes] = await Promise.all([
      getDashboardStats(),
      getRevenueOverview(),
      getBookingsByCategory(),
      getRecentBookings(5),
      getPendingRefunds(),
    ])

    if (statsRes.success) setStats(statsRes.stats)
    if (revenueRes.success) setRevenueData(revenueRes.data)
    if (categoryRes.success) setCategoryData(categoryRes.categories.filter(c => c.value > 0))
    if (bookingsRes.success) setRecentBookings(bookingsRes.bookings)
    if (refundsRes.success) setPendingRefunds(refundsRes.refunds)

    setLoading(false)
  }

  const statusColors = {
    paid: 'bg-green-100 text-green-700',
    completed: 'bg-green-100 text-green-700',
    pending: 'bg-yellow-100 text-yellow-700',
    cancelled: 'bg-red-100 text-red-600',
    refunded: 'bg-blue-100 text-blue-700',
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

  const formatDate = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  }

  const totalCategoryValue = categoryData.reduce((sum, c) => sum + c.value, 0)

  return (
    <div>
      {/* Welcome */}
      <div className="flex items-start justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2" style={{ color: '#0C3B2E' }}>
            Welcome back, {admin?.name?.split(' ')[0] || 'Admin'} 👋
          </h1>
          <p className="text-sm text-gray-500 mt-1">
            Here is a quick overview of TicketHub operations today.
          </p>
        </div>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard
          icon={Users}
          label="TOTAL USERS"
          value={loading ? '...' : stats.totalUsers.toLocaleString()}
          iconBg="#6D9773"
        />
        <StatCard
          icon={Ticket}
          label="TOTAL BOOKINGS"
          value={loading ? '...' : stats.totalBookings.toLocaleString()}
          iconBg="#BB8A52"
        />
        <StatCard
          icon={DollarSign}
          label="TOTAL REVENUE"
          value={loading ? '...' : `PKR ${parseFloat(stats.totalRevenue).toLocaleString()}`}
          iconBg="#0C3B2E"
        />
        <StatCard
          icon={RotateCcw}
          label="PENDING REFUNDS"
          value={loading ? '...' : stats.pendingRefunds}
          change={stats.pendingRefunds > 0 ? 'ALERT' : null}
          changeType="alert"
          iconBg="#FFBA00"
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        {/* Revenue Chart */}
        <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-gray-100">
          <div className="flex justify-between items-center mb-4">
            <h3 className="font-bold" style={{ color: '#0C3B2E' }}>
              Revenue Overview
            </h3>
            <span className="text-xs text-gray-500 px-3 py-1 bg-gray-50 rounded-lg">
              Last 30 Days
            </span>
          </div>
       {revenueData.length > 0 ? (
  <ResponsiveContainer width="100%" height={280}>
    <BarChart data={revenueData} margin={{ top: 20, right: 20, left: 20, bottom: 20 }}>
      <XAxis
        dataKey="date"
        tick={{ fontSize: 11, fill: '#9CA3AF' }}
        axisLine={false}
        tickLine={false}
      />
      <Tooltip
        contentStyle={{
          backgroundColor: '#0C3B2E',
          border: 'none',
          borderRadius: '8px',
          color: 'white',
          padding: '10px'
        }}
        labelStyle={{ color: '#BB8A52', fontWeight: 'bold' }}
        formatter={(value) => [`PKR ${value.toLocaleString()}`, 'Revenue']}
        cursor={{ fill: 'rgba(109, 151, 115, 0.1)' }}
      />
      <Bar 
        dataKey="revenue" 
        fill="#6D9773" 
        radius={[8, 8, 0, 0]}
        maxBarSize={60}
      />
    </BarChart>
  </ResponsiveContainer>
) : (
  <div className="h-[280px] flex flex-col items-center justify-center text-gray-400">
    <BarChart3 size={48} className="mb-2 opacity-30" />
    <p className="text-sm">No revenue data available</p>
  </div>
)}
          
        </div>

        {/* Pie Chart */}
        <div className="bg-white p-6 rounded-xl border border-gray-100">
          <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>
            Bookings by Category
          </h3>
          {categoryData.length > 0 ? (
            <>
              <div className="relative flex items-center justify-center h-48">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie data={categoryData} cx="50%" cy="50%" innerRadius={60} outerRadius={80} dataKey="value">
                      {categoryData.map((entry, i) => (
                        <Cell key={i} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
                <div className="absolute text-center">
                  <p className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>
                    {totalCategoryValue >= 1000 ? `${(totalCategoryValue / 1000).toFixed(1)}k` : totalCategoryValue}
                  </p>
                  <p className="text-xs text-gray-500">TOTAL</p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2 mt-4 text-xs">
                {categoryData.map((cat, i) => (
                  <div key={i} className="flex items-center gap-1.5">
                    <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: cat.color }}></div>
                    <span className="text-gray-600 truncate">{cat.name} ({cat.value})</span>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <div className="h-48 flex items-center justify-center text-gray-400 text-sm">
              No bookings yet
            </div>
          )}
        </div>
      </div>

      {/* Recent Bookings + Refunds */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Bookings */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-gray-100 overflow-hidden">
          <div className="flex justify-between items-center p-6 border-b border-gray-100">
            <h3 className="font-bold" style={{ color: '#0C3B2E' }}>Recent Bookings</h3>
            <a href="/dashboard/bookings" className="text-sm font-semibold" style={{ color: '#6D9773' }}>
              View All
            </a>
          </div>
          <div className="overflow-x-auto">
            {recentBookings.length > 0 ? (
              <table className="w-full">
                <thead className="bg-green-50">
                  <tr>
                    <th className="text-left p-4 text-xs font-semibold text-gray-500 tracking-wider">USER</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-500 tracking-wider">TYPE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-500 tracking-wider">AMOUNT</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-500 tracking-wider">DATE</th>
                    <th className="text-left p-4 text-xs font-semibold text-gray-500 tracking-wider">STATUS</th>
                  </tr>
                </thead>
                <tbody>
                  {recentBookings.map((b, i) => {
                    const Icon = typeIcons[b.type] || Ticket
                    return (
                      <tr key={i} className="border-t border-gray-50 hover:bg-gray-50">
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            <div className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0" style={{ backgroundColor: '#6D9773' }}>
                              {(b.user_name || 'U')[0].toUpperCase()}
                            </div>
                            <div>
                              <p className="text-sm font-medium">{b.user_name || 'Guest'}</p>
                              <p className="text-xs text-gray-400 truncate max-w-[150px]">{b.title}</p>
                            </div>
                          </div>
                        </td>
                        <td className="p-4">
                          <div className="flex items-center gap-1.5">
                            <Icon size={14} style={{ color: '#6D9773' }} />
                            <span className="text-sm text-gray-600 capitalize">{b.type}</span>
                          </div>
                        </td>
                        <td className="p-4 text-sm font-semibold">
                          PKR {parseFloat(b.total_amount).toLocaleString()}
                        </td>
                        <td className="p-4 text-sm text-gray-600">{formatDate(b.created_at)}</td>
                        <td className="p-4">
                          <span className={`text-xs font-bold px-2 py-1 rounded ${statusColors[b.status] || 'bg-gray-100 text-gray-600'}`}>
                            {b.status?.toUpperCase()}
                          </span>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            ) : (
              <div className="p-12 text-center text-gray-400 text-sm">
                No bookings yet
              </div>
            )}
          </div>
        </div>

        {/* Pending Refunds */}
        <div className="bg-white rounded-xl border border-gray-100 overflow-hidden">
          <div className="p-6 border-b border-gray-100">
            <h3 className="font-bold" style={{ color: '#0C3B2E' }}>Pending Refunds</h3>
          </div>
          <div className="divide-y divide-gray-50">
            {pendingRefunds.length > 0 ? (
              <>
                {pendingRefunds.slice(0, 5).map((r, i) => (
                  <div key={i} className="flex items-center gap-3 p-4">
                    <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0" style={{ backgroundColor: '#FED7AA' }}>
                      <span className="text-xs font-bold" style={{ color: '#BB8A52' }}>
                        {(r.user_name || 'U')[0].toUpperCase()}
                      </span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-semibold truncate">{r.user_name || 'Unknown'}</p>
                      <p className="text-xs text-gray-500">#{r.order_number}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold" style={{ color: '#0C3B2E' }}>
                        PKR {parseFloat(r.refund_amount).toLocaleString()}
                      </p>
                      <button
                        className="text-xs mt-1 px-2 py-0.5 rounded hover:opacity-80 transition-opacity"
                        style={{ backgroundColor: '#E8F0EA', color: '#6D9773' }}
                      >
                        Review
                      </button>
                    </div>
                  </div>
                ))}
                <div className="p-4 text-center">
                  <a href="/dashboard/refunds" className="text-sm font-semibold" style={{ color: '#0C3B2E' }}>
                    View All Refunds
                  </a>
                </div>
              </>
            ) : (
              <div className="p-12 text-center text-gray-400 text-sm">
                No pending refunds
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}