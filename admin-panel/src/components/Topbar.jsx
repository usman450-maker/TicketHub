import { Search, Bell, Calendar } from 'lucide-react'
import { useNavigate } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { getNotificationsStats } from '../services/adminService'

export default function Topbar() {
  const navigate = useNavigate()
  const [unreadCount, setUnreadCount] = useState(0)

  const today = new Date().toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })

  useEffect(() => {
    loadUnreadCount()
    // Refresh every 30 seconds
    const interval = setInterval(loadUnreadCount, 30000)
    return () => clearInterval(interval)
  }, [])

  const loadUnreadCount = async () => {
    const res = await getNotificationsStats()
    if (res.success) {
      setUnreadCount(res.stats.unread || 0)
    }
  }

  return (
    <div className="flex items-center gap-4 mb-6">
      {/* Search Bar */}
      <div className="flex-1 relative">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
        <input
          type="text"
          placeholder="Search bookings, users, or tickets..."
          className="w-full pl-12 pr-4 py-2.5 rounded-lg text-sm focus:outline-none transition-all"
          style={{ backgroundColor: '#E8F0EA', color: '#0C3B2E' }}
        />
      </div>

      {/* Notifications */}
      <button
        onClick={() => navigate('/dashboard/notifications')}
        className="relative w-10 h-10 flex items-center justify-center hover:bg-gray-100 rounded-lg transition-colors group"
        title="Notifications"
      >
        <Bell size={20} style={{ color: '#0C3B2E' }} className="group-hover:scale-110 transition-transform" />
        {unreadCount > 0 && (
          <span
            className="absolute top-1 right-1 min-w-[18px] h-[18px] px-1 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center"
          >
            {unreadCount > 99 ? '99+' : unreadCount}
          </span>
        )}
      </button>

      {/* Date */}
      <div className="flex items-center gap-2 px-4 py-2.5 border border-gray-200 rounded-lg bg-white">
        <Calendar size={16} style={{ color: '#0C3B2E' }} />
        <span className="text-sm font-medium" style={{ color: '#0C3B2E' }}>
          {today}
        </span>
      </div>
    </div>
  )
}