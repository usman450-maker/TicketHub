import { Link, useNavigate } from 'react-router-dom'
import { Ticket, Mail, ArrowLeft, KeyRound } from 'lucide-react'
import { useState, useEffect } from 'react'
import { forgotPassword } from '../../services/authService'

export default function ForgotPasswordPage() {
  const navigate = useNavigate()

  const [email, setEmail] = useState('')
  const [mounted, setMounted] = useState(false)
  const [btnHover, setBtnHover] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    const result = await forgotPassword(email)

    setLoading(false)

    if (result.success) {
      // Navigate to OTP page
      navigate('/verify-otp', {
        state: {
          type: 'forgot-password',
          email,
        },
      })
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
          <Link to="/" className={`flex items-center gap-2 hover:opacity-80 transition-opacity duration-150 w-fit ${
            mounted ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'
          }`}>
            <div className="w-10 h-10 rounded-lg flex items-center justify-center border border-white/20">
              <Ticket className="text-white" size={22} />
            </div>
            <span className="text-xl font-bold">TicketHub Admin</span>
          </Link>

          <div>
            <div className="w-20 h-20 rounded-2xl flex items-center justify-center mb-6" style={{ backgroundColor: '#BB8A52' }}>
              <KeyRound className="text-white" size={40} />
            </div>
            <h1 className={`text-4xl xl:text-5xl font-bold leading-tight mb-5 transition-all duration-700 delay-200 ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              Forgot Your
              <br />
              <span style={{ color: '#BB8A52' }}>Password?</span>
              <br />
              We Got You.
            </h1>

            <p className={`text-base text-white/70 max-w-md transition-all duration-700 delay-400 ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              Enter your registered email and we'll send you a verification code to reset your password.
            </p>
          </div>

          <p className="text-xs text-white/60">© 2024 TicketHub Global.</p>
        </div>
      </div>

      {/* RIGHT SIDE */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-5 relative">
        <div className={`max-w-md w-full transition-all duration-700 delay-300 ${
          mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}>
          <Link to="/login"
            className="inline-flex items-center gap-1 text-xs mb-3 hover:opacity-70 transition-opacity duration-150"
            style={{ color: '#6B7280' }}>
            <ArrowLeft size={14} />
            Back to Login
          </Link>

          <div className="bg-white rounded-2xl shadow-2xl p-8">
            <div className="text-center mb-6">
              <div className="w-16 h-16 rounded-2xl mx-auto mb-4 flex items-center justify-center" style={{ backgroundColor: '#0C3B2E' }}>
                <KeyRound className="text-white" size={28} />
              </div>
              <h2 className="text-2xl font-bold mb-1" style={{ color: '#0C3B2E' }}>
                Forgot Password
              </h2>
              <p className="text-xs text-gray-500">
                Enter your email address and we'll send you an OTP.
              </p>
            </div>

            {error && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm mb-4">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold mb-2" style={{ color: '#0C3B2E' }}>
                  Email Address
                </label>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: '#6B7280' }} />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="admin@company.com"
                    className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                    style={{ borderColor: '#E5E7EB' }}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    required
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                onMouseEnter={() => setBtnHover(true)}
                onMouseLeave={() => setBtnHover(false)}
                className="w-full text-white py-3 rounded-lg font-semibold text-sm transition-all duration-150 hover:shadow-lg active:scale-[0.98] disabled:opacity-50"
                style={{ backgroundColor: btnHover ? '#0C3B2E' : '#6D9773' }}
              >
                {loading ? 'Sending OTP...' : 'Send Verification Code'}
              </button>
            </form>

            <p className="text-center text-xs text-gray-600 mt-5">
              Remember your password?{' '}
              <Link to="/login" className="font-semibold hover:underline" style={{ color: '#6D9773' }}>
                Login here
              </Link>
            </p>
          </div>

          <p className="text-center text-[10px] text-gray-400 mt-3">
            © 2024 TicketHub Global. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}