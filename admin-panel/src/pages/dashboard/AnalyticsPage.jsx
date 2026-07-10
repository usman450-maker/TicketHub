import { useState, useEffect } from 'react'
import {
  BarChart, Bar, LineChart, Line, AreaChart, Area,
  PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer, Legend,
} from 'recharts'
import {
  TrendingUp, DollarSign, Users, Ticket, Award,
  Film, Bus, Calendar, MapPin, User,
} from 'lucide-react'
import {
  getRevenueAnalytics,
  getCategoryRevenue,
  getUserGrowth,
  getTopPerformers,
  getBookingStatusStats,
  getMonthlyComparison,
} from '../../services/adminService'

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('30')
  const [loading, setLoading] = useState(true)
  const [data, setData] = useState({
    revenue: [],
    categories: [],
    users: [],
    topPerformers: { topUsers: [], topMovies: [], topRoutes: [] },
    statusStats: [],
    monthlyData: [],
  })

  useEffect(() => {
    loadAllData()
  }, [period])

  const loadAllData = async () => {
    setLoading(true)
    const [rev, cat, users, top, status, monthly] = await Promise.all([
      getRevenueAnalytics(period),
      getCategoryRevenue(),
      getUserGrowth(),
      getTopPerformers(),
      getBookingStatusStats(),
      getMonthlyComparison(),
    ])

    setData({
      revenue: rev.data || [],
      categories: cat.categories || [],
      users: users.data || [],
      topPerformers: {
        topUsers: top.topUsers || [],
        topMovies: top.topMovies || [],
        topRoutes: top.topRoutes || [],
      },
      statusStats: status.data || [],
      monthlyData: monthly.data || [],
    })
    setLoading(false)
  }

  const totalRevenue = data.revenue.reduce((sum, d) => sum + d.revenue, 0)
  const totalBookings = data.revenue.reduce((sum, d) => sum + d.bookings, 0)
  const totalUsers = data.users.reduce((sum, d) => sum + d.users, 0)
  const avgDaily = data.revenue.length > 0 ? totalRevenue / data.revenue.length : 0

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: '#0C3B2E' }}>Analytics & Reports</h1>
          <p className="text-sm text-gray-500 mt-1">Comprehensive insights into your business performance.</p>
        </div>
        <select
          value={period}
          onChange={(e) => setPeriod(e.target.value)}
          className="px-4 py-2 border border-gray-200 rounded-lg text-sm cursor-pointer"
        >
          <option value="7">Last 7 Days</option>
          <option value="30">Last 30 Days</option>
          <option value="90">Last 90 Days</option>
          <option value="365">Last Year</option>
        </select>
      </div>

      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <StatCard
          icon={DollarSign}
          label="Total Revenue"
          value={`PKR ${totalRevenue.toLocaleString()}`}
          color="#6D9773"
        />
        <StatCard
          icon={Ticket}
          label="Total Bookings"
          value={totalBookings.toLocaleString()}
          color="#BB8A52"
        />
        <StatCard
          icon={Users}
          label="New Users"
          value={totalUsers.toLocaleString()}
          color="#0C3B2E"
        />
        <StatCard
          icon={TrendingUp}
          label="Avg Daily Revenue"
          value={`PKR ${avgDaily.toFixed(0)}`}
          color="#F59E0B"
        />
      </div>

      {loading ? (
        <div className="text-center py-20 text-gray-400">Loading analytics...</div>
      ) : (
        <>
          {/* Revenue Trend */}
          <div className="bg-white p-6 rounded-xl border border-gray-100 mb-6">
            <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>Revenue Trend</h3>
            {data.revenue.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={data.revenue}>
                  <defs>
                    <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#6D9773" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="#6D9773" stopOpacity={0.05} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#0C3B2E',
                      border: 'none',
                      borderRadius: '8px',
                      color: 'white',
                    }}
                    formatter={(value) => [`PKR ${value.toLocaleString()}`, 'Revenue']}
                  />
                  <Area type="monotone" dataKey="revenue" stroke="#6D9773" strokeWidth={2} fill="url(#colorRevenue)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[300px] flex items-center justify-center text-gray-400">No data</div>
            )}
          </div>

          {/* Category & Status Charts */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            {/* Category Revenue */}
            <div className="bg-white p-6 rounded-xl border border-gray-100">
              <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>Revenue by Category</h3>
              {data.categories.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart data={data.categories} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                    <XAxis type="number" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                    <YAxis dataKey="name" type="category" tick={{ fontSize: 11, fill: '#9CA3AF' }} width={80} />
                    <Tooltip
                      contentStyle={{ backgroundColor: '#0C3B2E', border: 'none', borderRadius: '8px', color: 'white' }}
                      formatter={(value) => [`PKR ${value.toLocaleString()}`, 'Revenue']}
                    />
                    <Bar dataKey="revenue" radius={[0, 8, 8, 0]}>
                      {data.categories.map((entry, i) => (
                        <Cell key={i} fill={entry.color} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-[280px] flex items-center justify-center text-gray-400">No data</div>
              )}
            </div>

            {/* Status Pie */}
            <div className="bg-white p-6 rounded-xl border border-gray-100">
              <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>Booking Status Distribution</h3>
              {data.statusStats.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <PieChart>
                    <Pie
                      data={data.statusStats}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      outerRadius={100}
                      dataKey="value"
                      label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    >
                      {data.statusStats.map((entry, i) => (
                        <Cell key={i} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                    <Legend />
                  </PieChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-[280px] flex items-center justify-center text-gray-400">No data</div>
              )}
            </div>
          </div>

          {/* Monthly Comparison */}
          <div className="bg-white p-6 rounded-xl border border-gray-100 mb-6">
            <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>Monthly Performance (Last 6 Months)</h3>
            {data.monthlyData.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={data.monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis yAxisId="left" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis yAxisId="right" orientation="right" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#0C3B2E', border: 'none', borderRadius: '8px', color: 'white' }}
                  />
                  <Legend />
                  <Bar yAxisId="left" dataKey="revenue" fill="#6D9773" radius={[8, 8, 0, 0]} name="Revenue (PKR)" />
                  <Bar yAxisId="right" dataKey="bookings" fill="#BB8A52" radius={[8, 8, 0, 0]} name="Bookings" />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[300px] flex items-center justify-center text-gray-400">No data</div>
            )}
          </div>

          {/* User Growth */}
          <div className="bg-white p-6 rounded-xl border border-gray-100 mb-6">
            <h3 className="font-bold mb-4" style={{ color: '#0C3B2E' }}>User Growth (Last 30 Days)</h3>
            {data.users.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={data.users}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                  <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#0C3B2E', border: 'none', borderRadius: '8px', color: 'white' }}
                  />
                  <Line type="monotone" dataKey="users" stroke="#BB8A52" strokeWidth={3} dot={{ fill: '#BB8A52', r: 5 }} />
                </LineChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-[250px] flex items-center justify-center text-gray-400">No data</div>
            )}
          </div>

          {/* Top Performers */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Top Users */}
            <TopPerformersCard
              title="Top Users"
              icon={User}
              items={data.topPerformers.topUsers.map(u => ({
                name: u.name,
                subtitle: u.email,
                value: `PKR ${parseFloat(u.total_spent).toLocaleString()}`,
                extra: `${u.total_bookings} bookings`,
              }))}
              color="#6D9773"
            />

            {/* Top Movies */}
            <TopPerformersCard
              title="Top Movies"
              icon={Film}
              items={data.topPerformers.topMovies.map(m => ({
                name: m.movie_title,
                subtitle: `${m.bookings} bookings`,
                value: `PKR ${parseFloat(m.revenue).toLocaleString()}`,
              }))}
              color="#BB8A52"
            />

            {/* Top Routes */}
            <TopPerformersCard
              title="Top Transport Routes"
              icon={MapPin}
              items={data.topPerformers.topRoutes.map(r => ({
                name: r.operator_name,
                subtitle: `${r.from_location} → ${r.to_location}`,
                value: `PKR ${parseFloat(r.revenue).toLocaleString()}`,
                extra: r.transport_type?.toUpperCase(),
              }))}
              color="#0C3B2E"
            />
          </div>
        </>
      )}
    </div>
  )
}

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

function TopPerformersCard({ title, icon: Icon, items, color }) {
  return (
    <div className="bg-white p-5 rounded-xl border border-gray-100">
      <h3 className="font-bold mb-4 flex items-center gap-2" style={{ color: '#0C3B2E' }}>
        <Icon size={18} style={{ color }} />
        {title}
      </h3>
      {items.length > 0 ? (
        <div className="space-y-3">
          {items.slice(0, 5).map((item, i) => (
            <div key={i} className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                style={{ backgroundColor: color }}
              >
                {i + 1}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold truncate" style={{ color: '#0C3B2E' }}>{item.name}</p>
                <p className="text-xs text-gray-500 truncate">{item.subtitle}</p>
              </div>
              <div className="text-right flex-shrink-0">
                <p className="text-xs font-bold" style={{ color: '#BB8A52' }}>{item.value}</p>
                {item.extra && <p className="text-xs text-gray-400 mt-0.5">{item.extra}</p>}
              </div>
            </div>
          ))}
        </div>
      ) : (
        <p className="text-center text-gray-400 py-8 text-sm">No data available</p>
      )}
    </div>
  )
}