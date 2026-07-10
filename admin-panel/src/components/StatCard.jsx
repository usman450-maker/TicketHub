export default function StatCard({ icon: Icon, label, value, change, changeType, iconBg }) {
  return (
    <div className="bg-white p-6 rounded-xl border border-gray-100 hover:shadow-lg transition-all">
      <div className="flex items-start justify-between mb-4">
        <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: iconBg }}>
          <Icon size={22} className="text-white" />
        </div>
        {change && (
          <span
            className={`text-xs font-semibold flex items-center gap-1 ${
              changeType === 'up' ? 'text-green-600' : changeType === 'down' ? 'text-red-500' : 'text-yellow-600'
            }`}
          >
            {change} {changeType === 'up' ? '↑' : changeType === 'down' ? '↓' : ''}
          </span>
        )}
      </div>
      <p className="text-xs text-gray-500 tracking-wider font-semibold mb-1">{label}</p>
      <p className="text-3xl font-bold" style={{ color: '#0C3B2E' }}>{value}</p>
    </div>
  )
}