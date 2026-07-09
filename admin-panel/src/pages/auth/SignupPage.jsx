import { Link } from 'react-router-dom'
import { 
  Ticket, Mail, Lock, User, Phone, Building2, 
  Eye, EyeOff, TrendingUp, DollarSign, ChevronDown, Shapes
} from 'lucide-react'
import { useState, useEffect } from 'react'

export default function SignupPage() {
  const [formData, setFormData] = useState({
    companyName: '',
    fullName: '',
    email: '',
    phone: '',
    orgType: '',
    password: '',
    confirmPassword: '',
    agreed: false
  })
  const [showPassword, setShowPassword] = useState(false)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target
    setFormData({ ...formData, [name]: type === 'checkbox' ? checked : value })
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    console.log('Signup:', formData)
  }

  const inputStyle = {
    borderColor: '#E5E7EB'
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
    <div className="min-h-screen flex bg-gray-50">
      {/* ============ LEFT SIDE ============ */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden sticky top-0 h-screen">
        <div 
          className="absolute inset-0 transition-transform duration-1000 hover:scale-105"
          style={{
            backgroundImage: `linear-gradient(135deg, rgba(12, 59, 46, 0.92), rgba(12, 59, 46, 0.85)), url('https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1200')`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        ></div>

        <div className="relative z-10 flex flex-col justify-between p-12 text-white w-full">
          {/* Logo */}
          <div className={`flex items-center gap-2 transition-all duration-700 ${
            mounted ? 'opacity-100 translate-y-0' : 'opacity-0 -translate-y-4'
          }`}>
            <div className="w-10 h-10 rounded-lg flex items-center justify-center border border-white/20">
              <Ticket className="text-white" size={22} />
            </div>
            <span className="text-xl font-bold">TicketHub Admin</span>
          </div>

          {/* Main Text */}
          <div>
            <h1 className={`text-4xl xl:text-5xl font-bold leading-tight mb-6 transition-all duration-700 delay-200 ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              Powering the
              <br />
              <span style={{color: '#BB8A52'}}>Ecosystem</span> of
              <br />
              Global Mobility.
            </h1>
            <p className={`text-lg text-white/70 max-w-md transition-all duration-700 delay-400 ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
            }`}>
              The centralized dashboard for industry leaders in entertainment and transit logistics. 
              Manage, scale, and thrive.
            </p>
          </div>

          {/* Bottom Stats Cards */}
          <div className="space-y-3">
            <div className={`bg-black/30 backdrop-blur-md rounded-xl p-4 border border-white/10 max-w-xs transition-all duration-700 delay-500 hover:scale-105 hover:bg-black/40 ${
              mounted ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'
            }`}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-white/60 tracking-widest mb-1">TODAY'S BOOKINGS</p>
                  <p className="text-2xl font-bold">12,482</p>
                </div>
                <div className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center">
                  <TrendingUp size={18} style={{color: '#6D9773'}} />
                </div>
              </div>
            </div>

            <div className={`bg-black/30 backdrop-blur-md rounded-xl p-4 border border-white/10 max-w-xs transition-all duration-700 delay-700 hover:scale-105 hover:bg-black/40 ${
              mounted ? 'opacity-100 translate-x-0' : 'opacity-0 -translate-x-8'
            }`}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-white/60 tracking-widest mb-1">REVENUE (24H)</p>
                  <p className="text-2xl font-bold">$1.2M</p>
                </div>
                <div className="w-10 h-10 rounded-full flex items-center justify-center" style={{backgroundColor: '#BB8A52'}}>
                  <DollarSign size={18} className="text-white" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ============ RIGHT SIDE - FORM ============ */}
      <div className="w-full lg:w-1/2 flex items-start justify-center p-6 py-8 relative">
        <div className={`max-w-lg w-full transition-all duration-700 delay-300 ${
          mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
        }`}>
          {/* Mobile Logo */}
          <div className="lg:hidden flex items-center justify-center gap-2 mb-6">
            <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{backgroundColor: '#0C3B2E'}}>
              <Ticket className="text-white" size={22} />
            </div>
            <span className="text-xl font-bold" style={{color: '#0C3B2E'}}>TicketHub Admin</span>
          </div>

          {/* Signup Card */}
          <div className="bg-white rounded-2xl shadow-2xl p-8 hover:shadow-3xl transition-shadow duration-500">
            <div className="mb-6">
              <h2 className={`text-2xl font-bold mb-2 transition-all duration-500 delay-500 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`} style={{color: '#0C3B2E'}}>
                Create Admin Account
              </h2>
              <p className={`text-sm text-gray-500 transition-all duration-500 delay-600 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                Register your organization to access the TicketHub ecosystem.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Company Name + Full Name */}
              <div className={`grid grid-cols-1 md:grid-cols-2 gap-4 transition-all duration-500 delay-700 ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Company Name
                  </label>
                  <div className="relative">
                    <Building2 className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type="text"
                      name="companyName"
                      value={formData.companyName}
                      onChange={handleChange}
                      placeholder="Acme Logistics"
                      className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Full Name
                  </label>
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type="text"
                      name="fullName"
                      value={formData.fullName}
                      onChange={handleChange}
                      placeholder="Johnathan Doe"
                      className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Email + Phone */}
              <div className={`grid grid-cols-1 md:grid-cols-2 gap-4 transition-all duration-500 delay-[800ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Business Email
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      placeholder="admin@acme.com"
                      className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Phone Number
                  </label>
                  <div className="relative">
                    <Phone className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type="tel"
                      name="phone"
                      value={formData.phone}
                      onChange={handleChange}
                      placeholder="+1 (555) 000-0000"
                      className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                    />
                  </div>
                </div>
              </div>

              {/* Organization Type */}
              <div className={`transition-all duration-500 delay-[900ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                  Organization Type
                </label>
                <div className="relative">
                  <Shapes className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                  <select
                    name="orgType"
                    value={formData.orgType}
                    onChange={handleChange}
                    className="w-full pl-12 pr-10 py-3 border rounded-lg focus:outline-none transition-all text-sm appearance-none bg-white cursor-pointer"
                    style={{
                      ...inputStyle,
                      color: formData.orgType ? '#0C3B2E' : '#6B7280'
                    }}
                    onFocus={handleFocus}
                    onBlur={handleBlur}
                    required
                  >
                    <option value="">Select partner type...</option>
                    <option value="cinema">Cinema Chain</option>
                    <option value="airline">Airline</option>
                    <option value="bus">Bus Operator</option>
                    <option value="train">Rail Operator</option>
                    <option value="events">Event Organizer</option>
                    <option value="sports">Sports Venue</option>
                    <option value="parks">Theme Park</option>
                  </select>
                  <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none" size={18} style={{color: '#6B7280'}} />
                </div>
              </div>

              {/* Password + Confirm */}
              <div className={`grid grid-cols-1 md:grid-cols-2 gap-4 transition-all duration-500 delay-[1000ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      name="password"
                      value={formData.password}
                      onChange={handleChange}
                      placeholder="••••••••"
                      className="w-full pl-12 pr-12 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-4 top-1/2 -translate-y-1/2 hover:opacity-70 transition-opacity"
                      style={{color: '#6B7280'}}
                    >
                      {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                    </button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-semibold mb-2" style={{color: '#0C3B2E'}}>
                    Confirm Password
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{color: '#6B7280'}} />
                    <input
                      type="password"
                      name="confirmPassword"
                      value={formData.confirmPassword}
                      onChange={handleChange}
                      placeholder="••••••••"
                      className="w-full pl-12 pr-4 py-3 border rounded-lg focus:outline-none transition-all text-sm"
                      style={inputStyle}
                      onFocus={handleFocus}
                      onBlur={handleBlur}
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Terms */}
              <div className={`flex items-start gap-2 transition-all duration-500 delay-[1100ms] ${
                mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
              }`}>
                <input 
                  type="checkbox" 
                  name="agreed"
                  checked={formData.agreed}
                  onChange={handleChange}
                  className="w-4 h-4 rounded border-gray-300 mt-0.5 cursor-pointer" 
                  style={{accentColor: '#6D9773'}}
                  required
                />
                <label className="text-sm text-gray-600 leading-relaxed">
                  I agree to the{' '}
                  <a href="#" className="font-semibold hover:underline" style={{color: '#6D9773'}}>Terms & Conditions</a>
                  {' '}and{' '}
                  <a href="#" className="font-semibold hover:underline" style={{color: '#6D9773'}}>Privacy Policy</a>.
                </label>
              </div>

              {/* Create Account Button */}
              <button
                type="submit"
                className={`w-full text-white py-3.5 rounded-lg font-semibold text-sm transition-all hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] delay-[1200ms] duration-500 ${
                  mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
                }`}
                style={{backgroundColor: '#6D9773'}}
                onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#0C3B2E'}
                onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#6D9773'}
              >
                Create Account
              </button>
            </form>

            {/* Divider */}
            <div className={`my-6 flex items-center gap-4 transition-all duration-500 delay-[1300ms] ${
              mounted ? 'opacity-100' : 'opacity-0'
            }`}>
              <div className="flex-1 h-px bg-gray-200"></div>
              <span className="text-xs text-gray-400 tracking-widest">OR SIGN UP WITH</span>
              <div className="flex-1 h-px bg-gray-200"></div>
            </div>

            {/* Social Signup */}
            <div className={`grid grid-cols-2 gap-3 transition-all duration-500 delay-[1400ms] ${
              mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'
            }`}>
              <button className="flex items-center justify-center gap-2 py-3 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50 transition-all hover:scale-105 hover:shadow-md">
                <svg width="18" height="18" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span style={{color: '#0C3B2E'}}>Google</span>
              </button>
              <button className="flex items-center justify-center gap-2 py-3 border border-gray-200 rounded-lg font-semibold text-sm hover:bg-gray-50 transition-all hover:scale-105 hover:shadow-md">
                <svg width="18" height="18" viewBox="0 0 24 24">
                  <path fill="#F25022" d="M11.4 11.4H0V0h11.4v11.4z"/>
                  <path fill="#7FBA00" d="M24 11.4H12.6V0H24v11.4z"/>
                  <path fill="#00A4EF" d="M11.4 24H0V12.6h11.4V24z"/>
                  <path fill="#FFB900" d="M24 24H12.6V12.6H24V24z"/>
                </svg>
                <span style={{color: '#0C3B2E'}}>Microsoft</span>
              </button>
            </div>

            {/* Login Link */}
            <p className={`text-center text-sm text-gray-600 mt-6 transition-all duration-500 delay-[1500ms] ${
              mounted ? 'opacity-100' : 'opacity-0'
            }`}>
              Already have an admin account?{' '}
              <Link to="/login" className="font-semibold hover:underline" style={{color: '#6D9773'}}>
                Login here
              </Link>
            </p>
          </div>

          {/* Copyright */}
          <p className="text-center text-xs text-gray-400 mt-4">
            © 2024 TicketHub Global. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  )
}