export default function EmptyState({ icon: Icon, title, description }) {
  return (
    <div className="bg-white rounded-2xl p-16 text-center border border-gray-100">
      <div className="w-20 h-20 rounded-2xl mx-auto mb-4 flex items-center justify-center" style={{ backgroundColor: '#E8F0EA' }}>
        <Icon size={40} style={{ color: '#6D9773' }} />
      </div>
      <h3 className="text-xl font-bold mb-2" style={{ color: '#0C3B2E' }}>{title}</h3>
      <p className="text-sm text-gray-500 max-w-md mx-auto">{description}</p>
    </div>
  )
}