import { Link, useNavigate, useLocation } from 'react-router-dom'
import { ArrowLeft, Mail, RefreshCw } from 'lucide-react'
import { useState, useEffect, useRef } from 'react'
import {
  verifySignupOtp,
  resendSignupOtp,
  verifyOtp,
  resendOtp,
  verifyGoogleSignupOtp,
  resendGoogleSignupOtp,
} from '../../services/authService'

export default function OtpVerificationPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const inputRefs = useRef([])

  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [mounted, setMounted] = useState(false)
  const [loading, setLoading] = useState(false)
  const [resendLoading, setResendLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [timer, setTimer] = useState(60)

  const { type, name, email, phone, password } = location.state || {}

  useEffect(() => {
    setMounted(true)
    if (!email) {
      navigate('/signup')
      return
    }
    if (inputRefs.current[0]) {
      inputRefs.current[0].focus()
    }
  }, [email, navigate])

  useEffect(() => {
    if (timer > 0) {
      const interval = setInterval(() => setTimer((t) => t - 1), 1000)
      return () => clearInterval(interval)
    }
  }, [timer])

  const handleChange = (index, value) => {
    if (!/^\d*$/.test(value)) return

    const newOtp = [...otp]
    newOtp[index] = value.slice(-1)
    setOtp(newOtp)

    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
  }

  const handleKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e) => {
    e.preventDefault()
    const pastedData = e.clipboardData.getData('text').slice(0, 6)
    if (/^\d+$/.test(pastedData)) {
      const newOtp = pastedData.split('').concat(Array(6).fill('')).slice(0, 6)
      setOtp(newOtp)
      inputRefs.current[Math.min(pastedData.length, 5)]?.focus()
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')

    const otpString = otp.join('')
    if (otpString.length !== 6) {
      setError('Please enter complete 6-digit OTP')
      return
    }

    setLoading(true)

    let result
    if (type === 'signup') {
      result = await verifySignupOtp({
        name,
        email,
        phone,
        password,
        otp: otpString,
      })
    } else if (type === 'google-signup') {
      result = await verifyGoogleSignupOtp({
        name,
        email,
        otp: otpString,
      })
    } else if (type === 'forgot-password') {
      result = await verifyOtp({ email, otp: otpString })
    }

    setLoading(false)

    if (result.success) {
      if (type === 'signup' || type === 'google-signup') {
        navigate('/login', {
          state: { message: 'Account created successfully! Please login.' },
        })
      } else if (type === 'forgot-password') {
        navigate('/reset-password', {
          state: { email, verified: true },
        })
      }
    } else {
      setError(result.message)
    }
  }

  const handleResend = async () => {
    setError('')
    setSuccess('')
    setResendLoading(true)

    let result
    if (type === 'signup') {
      result = await resendSignupOtp({ name, email })
    } else if (type === 'google-signup') {
      result = await resendGoogleSignupOtp({ name, email })
    } else if (type === 'forgot-password') {
      result = await resendOtp(email)
    }

    setResendLoading(false)

    if (result.success) {
      setSuccess('OTP resent successfully!')
      setTimer(60)
      setOtp(['', '', '', '', '', ''])
      inputRefs.current[0]?.focus()
    } else {
      setError(result.message)
    }
  }

  const isOtpComplete = otp.join('').length === 6

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
      <div className={`max-w-md w-full transition-all duration-500 ${
        mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
      }`}>
        {/* Back Button */}
        <Link
          to={type === 'forgot-password' ? '/forgot-password' : type === 'google-signup' ? '/signup' : '/signup'}
          className="inline-flex items-center gap-1.5 text-sm mb-3 hover:opacity-70 transition-opacity duration-150 font-medium"
          style={{ color: '#6D9773' }}
        >
          <ArrowLeft size={16} />
          Back
        </Link>

        {/* Main Card */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          {/* Envelope Icon */}
          <div className="flex justify-center mb-5">
            <div
              className="w-16 h-16 rounded-2xl flex items-center justify-center"
              style={{ backgroundColor: '#0C3B2E' }}
            >
              <Mail className="text-white" size={28} />
            </div>
          </div>

          {/* Heading */}
          <h2 className="text-center text-2xl font-bold mb-2" style={{ color: '#0C3B2E' }}>
            Enter Verification Code
          </h2>

          {/* Subtitle */}
          <p className="text-center text-sm text-gray-500 mb-6">
            Code sent to{' '}
            <span className="font-semibold" style={{ color: '#0C3B2E' }}>
              {email}
            </span>
          </p>

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

          <form onSubmit={handleSubmit}>
            {/* OTP Inputs */}
            <div className="flex justify-center gap-2 mb-4">
              {otp.map((digit, index) => (
                <input
                  key={index}
                  ref={(el) => (inputRefs.current[index] = el)}
                  type="text"
                  inputMode="numeric"
                  maxLength="1"
                  value={digit}
                  onChange={(e) => handleChange(index, e.target.value)}
                  onKeyDown={(e) => handleKeyDown(index, e)}
                  onPaste={index === 0 ? handlePaste : undefined}
                  className="w-12 h-14 text-center text-xl font-bold border-2 rounded-lg focus:outline-none transition-all"
                  style={{
                    borderColor: digit ? '#0C3B2E' : '#E5E7EB',
                    color: '#0C3B2E',
                  }}
                  onFocus={(e) => {
                    e.target.style.borderColor = '#0C3B2E'
                    e.target.style.boxShadow = '0 0 0 3px rgba(12, 59, 46, 0.1)'
                  }}
                  onBlur={(e) => {
                    if (!digit) e.target.style.borderColor = '#E5E7EB'
                    e.target.style.boxShadow = 'none'
                  }}
                />
              ))}
            </div>

            {/* Timer */}
            <div className="text-center text-sm text-gray-500 mb-5">
              {timer > 0 ? (
                <span>
                  OTP expires in{' '}
                  <span className="font-bold" style={{ color: '#0C3B2E' }}>
                    0:{timer.toString().padStart(2, '0')}
                  </span>
                </span>
              ) : (
                <span className="text-red-500 font-semibold">OTP Expired</span>
              )}
            </div>

            {/* Verify Button */}
            <button
              type="submit"
              disabled={loading || !isOtpComplete}
              className="w-full text-white py-3.5 rounded-lg font-semibold text-base transition-all duration-150 hover:shadow-lg active:scale-[0.98] disabled:cursor-not-allowed"
              style={{
                backgroundColor: isOtpComplete && !loading ? '#6D9773' : '#B5CBB9',
              }}
              onMouseEnter={(e) => {
                if (isOtpComplete && !loading) {
                  e.currentTarget.style.backgroundColor = '#0C3B2E'
                }
              }}
              onMouseLeave={(e) => {
                if (isOtpComplete && !loading) {
                  e.currentTarget.style.backgroundColor = '#6D9773'
                }
              }}
            >
              {loading ? 'Verifying...' : 'Verify OTP'}
            </button>
          </form>

          {/* Resend Section */}
          <div className="text-center mt-5">
            <p className="text-sm text-gray-600 mb-2">Didn't receive the code?</p>
            <button
              type="button"
              onClick={handleResend}
              disabled={timer > 0 || resendLoading}
              className="inline-flex items-center gap-2 text-sm font-semibold hover:underline disabled:opacity-50 disabled:no-underline disabled:cursor-not-allowed transition-all"
              style={{ color: timer > 0 ? '#9CA3AF' : '#6D9773' }}
            >
              <RefreshCw size={14} className={resendLoading ? 'animate-spin' : ''} />
              {resendLoading
                ? 'Sending...'
                : timer > 0
                ? `Resend in ${timer}s`
                : 'Resend OTP'}
            </button>
          </div>
        </div>

        {/* Footer */}
        <p className="text-center text-xs text-gray-400 mt-4">
          © 2024 TicketHub Global. All rights reserved.
        </p>
      </div>
    </div>
  )
}