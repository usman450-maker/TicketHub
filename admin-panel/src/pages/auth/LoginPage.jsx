import { Link, useNavigate, useLocation } from 'react-router-dom'
import { Ticket, Mail, Lock, Eye, EyeOff, TrendingUp, DollarSign, ArrowLeft } from 'lucide-react'
import { useState, useEffect } from 'react'
import { login } from '../../services/authService'

export default function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [remember, setRemember] = useState(false)
  const [mounted, setMounted] = useState(false)
  const [btnHover, setBtnHover] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  useEffect(() => {
    setMounted(true)
    if (location.state?.message) {
      setSuccess(location.state.message)
    }
  }, [location])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSuccess('')
    setLoading(true)

    const result = await login({ email, password })

    setLoading(false)

    if (result.success) {
      navigate('/dashboard')
    } else {
      setError(result.message)
    }
  }

  const handleFocus = (e) => {
    e.target.style.borderColor = '#6D9773'
    e.target.style.boxShadow = '0 0 0 3px rgba(109, 151, 115, 0.15)'
  }

  const handleBlur = (e) => {
    e.target.style.borderColor = '#E5E7EB'
    e.target.style.boxShadow = 'none'
  }

  return (
    <div className="h-screen flex overflow-hidden bg-gray-50">
      {/* LEFT SIDE */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden">
        <div
          className="absolute inset-0"
          style={{
            backgroundImage:
              "linear-gradient(135deg, rgba(12, 59, 46, 0.92), rgba(12, 59, 46, 0.85)), url('https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200')",
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        />

        <div className="relative z-10 flex flex-col justify-between p-10 text-white w-full">
          <Link
            to="/"
            className={`flex items-center gap-2 hover:opacity-80 transition-opacity duration-150 w-fit ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'
            }`}
          >
            <div className="w-10 h-10 rounded-lg flex items-center justify-center border border-white/20">
              <Ticket className="text-white" size={22} />
            </div>
            <span className="text-xl font-bold">TicketHub Admin</span>
          </Link>

          <div>
            <h1
              className={`text-4xl xl:text-5xl font-bold leading-tight mb-5 transition-all duration-700 delay-200 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
              }`}
            >
              Manage Every
              <br />
              Booking from One
              <br />
              Platform.
            </h1>

            <p className={`text-base text-white/70 max-w-md transition-all duration-700 delay-400 ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              The ultimate command center for global cinema, aviation, and transport logistics.
            </p>
          </div>

          <div className="space-y-3">
            <div className={`bg-black/30 backdrop-blur-md rounded-xl p-4 border border-white/10 max-w-xs transition-all duration-700 delay-500 hover:scale-105 ${
              mounted ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'
            }`}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-white/60 tracking-widest mb-1">TODAY'S BOOKINGS</p>
                  <p className="text-2xl font-bold">12,482</p>
                </div>
                <div className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center">
                  <TrendingUp size={18} style={{ color: '#6D9773' }} />
                </div>
              </div>
            </div>

            <div className={`bg-black/30 backdrop-blur-md rounded-xl p-4 border border-white/10 max-w-xs transition-all duration-700 delay-700 hover:scale-105 ${
              mounted ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'
            }`}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-white/60 tracking-widest mb-1">REVENUE (24H)</p>
                  <p className="text-2xl font-bold">$1.2M</p>
                </div>
                <div className="w-10 h-10 rounded-full flex items-center justify-center" style={{ backgroundColor: '#BB8A52' }}>
                  <DollarSign size={18} className="text-white" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* RIGHT SIDE */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-5 relative">
        <div className={`max-w-md w-full transition-all duration-700 delay-300 ${
          mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}>
          <Link
            to="/"
            className="hidden lg:inline-flex items-center gap-1 text-xs mb-3 hover:opacity-70 transition-opacity duration-150"
            style={{ color: '#6B7280' }}
          >
            <ArrowLeft size={14} />
            Back to Home
          </Link>

          <Link
            to="/"
            className="lg:hidden flex items-center justify-center gap-2 mb-5 hover:opacity-80 transition-opacity duration-150"
          >
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ backgroundColor: '#0C3B2E' }}>
              <Ticket className="text-white" size={22} />
            </div>
            <span className="text-xl font-bold" style={{ color: '#0C3B2E' }}>
              TicketHub Admin
            </span>
          </Link>

          <div className="bg-white rounded-2xl shadow-2xl p-8">
            <div className="text-center mb-6">
              <h2 className={`text-3xl font-bold mb-2 transition-all duration-500 delay-500 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`} style={{ color: '#0C3B2E' }}>
                Welcome Back
              </h2>
              <p className={`text-sm text-gray-500 transition-all duration-500 delay-600 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                Enter your credentials to access the admin dashboard.
              </p>
            </div>

            {/* Success Message */}
            {success && (
              <div className="p-3 bg-green-50 border border-green-200 rounded-lg text-green-700 text-sm mb-4">
                {success}
              </div>
            )}

            {/* Error Message */}
            {error && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm mb-4">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              <div className={`transition-all duration-500 delay-700 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                  Business Email
                </label>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: '#6B7280' }} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="name@company.com"
                    className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                    style={{ borderColor: '#E5E7EB' }}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    required
                  />
                </div>
              </div>

              <div className={`transition-all duration-500 delay-[800ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <div className="flex justify-between items-center mb-2">
                  <label className="text-sm font-semibold" style={{ color: '#0C3B2E' }}>
                    Password
                  </label>
                  <Link to="/forgot-password" className="text-sm font-semibold hover:underline" style={{ color: '#6D9773' }}>
                    Forgot Password?
                  </Link>
                </div>

                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: '#6B7280' }} />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full pl-12 pr-12 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                    style={{ borderColor: '#E5E7EB' }}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 hover:opacity-70 transition-opacity"
                    style={{ color: '#6B7280' }}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>

              <div className={`flex items-center transition-all duration-500 delay-[900ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={remember}
                    onChange={(e) => setRemember(e.target.checked)}
                    className="w-4 h-4 rounded border-gray-300 cursor-pointer"
                    style={{ accentColor: '#6D9773' }}
                  />
                  <span className="text-sm text-gray-600">Remember this device</span>
                </label>
              </div>

              <button
                type="submit"
                disabled={loading}
                onMouseEnter={() => setBtnHover(true)}
                onMouseLeave={() => setBtnHover(false)}
                className={`w-full text-white py-3 rounded-lg font-semibold text-sm transition-all duration-150 hover:shadow-lg active:scale-[0.98] disabled:opacity-50 ${
                  mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
                }`}
                style={{
                  backgroundColor: btnHover ? '#0C3B2E' : '#6D9773',
                  transitionDelay: mounted ? '0ms' : '1000ms',
                }}
              >
                {loading ? 'Logging in...' : 'Login to Portal'}
              </button>
            </form>

            {/* ✅ Restricted Access Notice */}
            <div className={`mt-6 p-3 rounded-lg text-center transition-all duration-500 delay-[1100ms] ${
              mounted ? 'opacity-100' : 'opacity-0'
            }`} style={{ backgroundColor: '#FEF3C7' }}>
              <p className="text-xs font-semibold flex items-center justify-center gap-1.5" style={{ color: '#92400E' }}>
                <Lock size={12} />
                Restricted Access • Only authorized administrators can login
              </p>
            </div>

            {/* ✅ Copyright inside card at bottom */}
            <p className={`text-center text-[10px] text-gray-400 mt-6 pt-6 border-t border-gray-100 transition-all duration-500 delay-[1200ms] ${
              mounted ? 'opacity-100' : 'opacity-0'
            }`}>
              © 2024 TicketHub Global. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}