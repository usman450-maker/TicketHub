import { NavLink, useNavigate } from 'react-router-dom'
import {
  LayoutDashboard, Users, Ticket, RotateCcw,
  Film, Calendar, Trophy, TreePine, Bus,
  Bell, BarChart3, Settings, LogOut,
} from 'lucide-react'
import { getAdmin, logout } from '../services/authService'

export default function Sidebar() {
  const admin = getAdmin()
  const navigate = useNavigate()

  const menuGroups = [
    {
      items: [
        { icon: LayoutDashboard, label: 'Dashboard', path: '/dashboard' },
        { icon: Users, label: 'Users', path: '/dashboard/users' },
        { icon: Ticket, label: 'Bookings', path: '/dashboard/bookings' },
        { icon: RotateCcw, label: 'Refunds', path: '/dashboard/refunds' },
      ],
    },
    {
      title: 'CATEGORIES',
      items: [
        { icon: Film, label: 'Movies', path: '/dashboard/movies' },
        { icon: Calendar, label: 'Events', path: '/dashboard/events' },
        { icon: Trophy, label: 'Sports', path: '/dashboard/sports' },
        { icon: TreePine, label: 'Parks', path: '/dashboard/parks' },
        { icon: Bus, label: 'Transport', path: '/dashboard/transport' },
      ],
    },
    {
      title: 'SYSTEM',
      items: [
        { icon: Bell, label: 'Notifications', path: '/dashboard/notifications' },
        { icon: BarChart3, label: 'Analytics', path: '/dashboard/analytics' },
        { icon: Settings, label: 'Settings', path: '/dashboard/settings' },
      ],
    },
  ]

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <aside className="w-64 h-screen text-white flex flex-col fixed left-0 top-0" style={{ backgroundColor: '#6D9773' }}>
      {/* Header */}
      <div className="p-6 border-b border-white/10">
        <h1 className="text-xl font-bold">TicketHub Admin</h1>
        <p className="text-xs text-white/70 mt-1">Super Administrator</p>
      </div>

      {/* Menu */}
      <nav className="flex-1 overflow-y-auto py-4">
        {menuGroups.map((group, i) => (
          <div key={i} className="mb-6">
            {group.title && (
              <p className="px-6 text-xs text-white/50 tracking-widest mb-2 font-semibold">
                {group.title}
              </p>
            )}
            <ul>
              {group.items.map((item, j) => (
                <li key={j}>
                  <NavLink
                    to={item.path}
                    end={item.path === '/dashboard'}
                    className={({ isActive }) =>
                      `flex items-center gap-3 px-6 py-2.5 text-sm transition-all ${
                        isActive
                          ? 'bg-white/15 border-l-4 border-white font-semibold'
                          : 'hover:bg-white/10 border-l-4 border-transparent'
                      }`
                    }
                  >
                    <item.icon size={18} />
                    <span>{item.label}</span>
                  </NavLink>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>

      {/* User Info */}
      <div className="p-4 border-t border-white/10">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center overflow-hidden">
            {admin?.profile_image ? (
              <img src={admin.profile_image} alt="admin" className="w-full h-full object-cover" />
            ) : (
              <span className="text-sm font-bold">
                {admin?.name?.[0]?.toUpperCase() || 'A'}
              </span>
            )}
          </div>
          <div className="flex-1">
            <p className="text-sm font-semibold">{admin?.name || 'Admin'}</p>
            <button
              onClick={handleLogout}
              className="text-xs text-white/70 hover:text-white flex items-center gap-1 transition-colors"
            >
              <LogOut size={12} />
              Log out
            </button>
          </div>
        </div>
      </div>
    </aside>
  )
}