import { Link } from 'react-router-dom'
import { 
  Film, Bus, Train, Plane, Music, Trophy,
  Users, Ticket, Clock, DollarSign, 
  Network, ShieldCheck, Zap, Globe,
  BarChart3, Cloud, Check, ArrowRight,
  Menu, X, Smartphone, Download, Star,
  ChevronRight, Play, MapPin, CreditCard,
  QrCode, Bell, Search, Heart, Headphones,
  RefreshCw, Lock, Wifi, TreePine
} from 'lucide-react'
import { useState, useEffect, useRef } from 'react'

export default function LandingPage() {
  const [mobileMenu, setMobileMenu] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  // ✅ Scroll detection for navbar
  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  // ✅ Smooth scroll to section
  const scrollToSection = (id) => {
    const element = document.getElementById(id)
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
    setMobileMenu(false)
  }

  // ✅ Intersection Observer for animations
  const useInView = () => {
    const ref = useRef(null)
    const [isVisible, setIsVisible] = useState(false)
    
    useEffect(() => {
      const observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) setIsVisible(true)
        },
        { threshold: 0.1 }
      )
      if (ref.current) observer.observe(ref.current)
      return () => observer.disconnect()
    }, [])
    
    return [ref, isVisible]
  }

  const services = [
    { icon: Film, title: 'Movie Management', subtitle: 'Manage Cinemas',
      image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800' },
    { icon: Bus, title: 'Bus Fleet Control', subtitle: 'View Routes',
      image: 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800' },
    { icon: Train, title: 'Rail Operations', subtitle: 'Network Status',
      image: 'https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=800' },
    { icon: Plane, title: 'Aviation Hub', subtitle: 'Global Sales',
      image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800' },
    { icon: Music, title: 'Event Ticketing', subtitle: 'View Events',
      image: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800' },
    { icon: Trophy, title: 'Sports Arena', subtitle: 'Stadium Maps',
      image: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800' },
  ]

  const extraCards = [
    { icon: TreePine, title: 'Theme Parks', subtitle: 'Park Passes',
      image: 'https://images.unsplash.com/photo-1597466599360-3b9775841aec?w=800' },
    { icon: CreditCard, title: 'Payment Hub', subtitle: 'Transactions',
      image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800' },
    { icon: RefreshCw, title: 'Refund Center', subtitle: 'Process Refunds',
      image: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800' },
  ]

  const infrastructure = [
    { icon: Network, title: 'Multi-Service Ecosystem',
      desc: 'The only platform that unites transport, entertainment, and hospitality under a single dashboard.' },
    { icon: Zap, title: 'Instant QR',
      desc: 'Hardware-accelerated ticket validation for rapid entry management.' },
    { icon: Globe, title: 'Global Payments',
      desc: 'Seamless Stripe & regional gateway integrations.' },
    { icon: BarChart3, title: 'Live Analytics',
      desc: 'Real-time data visualization of sales and operational health.' },
    { icon: ShieldCheck, title: 'Military-Grade Security',
      desc: 'Auth0 authentication and SOC2 Type II compliance standards.' },
    { icon: Cloud, title: '99.9% Uptime',
      desc: 'Distributed cloud storage with zero-latency failover.' },
  ]

  const howToUseSteps = [
    { step: '01', icon: Search, title: 'Search & Discover',
      desc: 'Browse movies, flights, buses, trains, events, sports matches, and theme parks all in one app.' },
    { step: '02', icon: Ticket, title: 'Select & Customize',
      desc: 'Pick your seats, choose your class, select dates and add passengers with our intuitive interface.' },
    { step: '03', icon: CreditCard, title: 'Secure Payment',
      desc: 'Pay securely with Stripe. Support for Visa, Mastercard, Amex and more.' },
    { step: '04', icon: QrCode, title: 'Get Digital Ticket',
      desc: 'Receive instant QR code ticket on your phone. Save to gallery or show at venue.' },
  ]

  const appFeatures = [
    { icon: Bell, title: 'Push Notifications', desc: 'Real-time booking updates and alerts' },
    { icon: Heart, title: 'Save Favorites', desc: 'Bookmark your preferred routes and events' },
    { icon: Lock, title: 'Secure & Private', desc: 'Bank-level encryption for all data' },
    { icon: Wifi, title: 'Offline Tickets', desc: 'Access your tickets without internet' },
    { icon: RefreshCw, title: 'Easy Refunds', desc: 'One-tap refund requests with tracking' },
    { icon: Headphones, title: '24/7 Support', desc: 'Round-the-clock customer assistance' },
  ]

  const stats = [
    { number: '1M+', label: 'BOOKINGS PROCESSED' },
    { number: '500+', label: 'GLOBAL PARTNERS' },
    { number: '100+', label: 'CITIES COVERED' },
    { number: '99.9%', label: 'SYSTEM UPTIME' },
  ]

  const testimonials = [
    { name: 'Ahmed Khan', role: 'Travel Manager', image: 'https://i.pravatar.cc/150?img=12',
      text: 'TicketHub has completely transformed how we manage travel bookings across our organization.', rating: 5 },
    { name: 'Sarah Ali', role: 'Event Organizer', image: 'https://i.pravatar.cc/150?img=5',
      text: 'The event ticketing system is phenomenal. QR validation makes entry management seamless.', rating: 5 },
    { name: 'Hassan Malik', role: 'Cinema Manager', image: 'https://i.pravatar.cc/150?img=15',
      text: 'Managing multiple cinema locations from one dashboard has never been easier. Brilliant platform!', rating: 5 },
  ]

  const partners = ['CINEMAX', 'SkyLine', 'METRO', 'GlobalEvent', 'URBAN BUS', 'ARENA']

  // ✅ Animated Section Component
  const AnimatedSection = ({ children, className = '', delay = 0 }) => {
    const [ref, isVisible] = useInView()
    return (
      <div 
        ref={ref}
        className={`transition-all duration-700 ${className}`}
        style={{
          opacity: isVisible ? 1 : 0,
          transform: isVisible ? 'translateY(0)' : 'translateY(40px)',
          transitionDelay: `${delay}ms`
        }}
      >
        {children}
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-white">
      
      {/* ============ NAVBAR ============ */}
      <nav 
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          scrolled 
            ? 'bg-white shadow-lg py-2' 
            : 'bg-transparent py-4'
        }`}
      >
        <div className="max-w-7xl mx-auto px-6">
          <div className="flex items-center justify-between">
            <Link to="/" className={`text-lg font-bold transition-colors duration-300 ${
              scrolled ? '' : 'text-white'
            }`} style={{color: scrolled ? '#0C3B2E' : 'white'}}>
              TicketHub Admin
            </Link>

            <div className="hidden md:flex items-center gap-8 text-sm">
              {[
                { id: 'solutions', label: 'Solutions' },
                { id: 'platform', label: 'Platform' },
                { id: 'how-to-use', label: 'How it Works' },
                { id: 'mobile-app', label: 'Mobile App' },
                { id: 'enterprise', label: 'Enterprise' },
              ].map((item) => (
                <button 
                  key={item.id}
                  onClick={() => scrollToSection(item.id)}
                  className={`transition-colors duration-300 hover:opacity-80 font-medium cursor-pointer ${
                    scrolled ? 'text-gray-600 hover:text-gray-900' : 'text-white/80 hover:text-white'
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>

            <div className="hidden md:flex items-center gap-4">
              <Link to="/login" className={`text-sm transition-colors duration-300 ${
                scrolled ? 'text-gray-600' : 'text-white/80'
              }`}>
                Log in
              </Link>
              <Link 
                to="/signup" 
                className="text-white px-5 py-2 rounded-full text-sm font-semibold transition-all hover:scale-105 hover:shadow-lg"
                style={{backgroundColor: '#BB8A52'}}
              >
                Get Started
              </Link>
            </div>

            <button 
              className="md:hidden"
              onClick={() => setMobileMenu(!mobileMenu)}
              style={{color: scrolled ? '#0C3B2E' : 'white'}}
            >
              {mobileMenu ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenu && (
          <div className="md:hidden bg-white border-t border-gray-100 shadow-xl animate-fade-in-down">
            <div className="px-6 py-4 space-y-3">
              {['solutions', 'platform', 'how-to-use', 'mobile-app', 'enterprise'].map((id) => (
                <button 
                  key={id}
                  onClick={() => scrollToSection(id)}
                  className="block w-full text-left py-2 font-medium capitalize"
                  style={{color: '#0C3B2E'}}
                >
                  {id.replace('-', ' ')}
                </button>
              ))}
              <div className="pt-3 border-t border-gray-100 flex gap-3">
                <Link to="/login" className="flex-1 text-center py-2 border rounded-full text-sm font-semibold"
                  style={{borderColor: '#0C3B2E', color: '#0C3B2E'}}>
                  Log in
                </Link>
                <Link to="/signup" className="flex-1 text-center py-2 text-white rounded-full text-sm font-semibold"
                  style={{backgroundColor: '#BB8A52'}}>
                  Get Started
                </Link>
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* ============ HERO SECTION ============ */}
      <section className="relative min-h-screen flex items-center overflow-hidden">
        <div 
          className="absolute inset-0"
          style={{
            backgroundImage: `linear-gradient(135deg, rgba(12, 59, 46, 0.92), rgba(12, 59, 46, 0.8)), url('https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=1920')`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        ></div>

        <div className="relative z-10 max-w-7xl mx-auto px-6 w-full pt-24 pb-16">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className="text-white">
              <div className="inline-flex items-center gap-2 text-xs mb-6 animate-fade-in-down" style={{color: '#BB8A52'}}>
                <span>▲</span>
                <span className="tracking-widest">NEW: GLOBAL MULTI-SERVICE SUPPORT</span>
              </div>
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight mb-4 animate-fade-in-up delay-100">
                Manage Every Booking
                <span className="block mt-1 animate-fade-in-up delay-200" style={{color: '#BB8A52'}}>
                  From One Platform.
                </span>
              </h1>
              <p className="text-white/80 mb-8 max-w-md leading-relaxed animate-fade-in-up delay-300">
                TicketHub helps businesses manage movies, buses, trains, flights, events, sports, 
                and theme park bookings through one centralized enterprise-grade platform.
              </p>
              <div className="flex flex-wrap gap-3 animate-fade-in-up delay-400">
                <Link 
                  to="/signup"
                  className="inline-flex items-center gap-2 text-white px-6 py-3 rounded-full text-sm font-semibold transition-all hover:scale-105 hover:shadow-xl"
                  style={{backgroundColor: '#BB8A52'}}
                >
                  Access Portal
                  <ArrowRight size={16} />
                </Link>
                <button className="text-white/90 hover:text-white text-sm font-medium flex items-center gap-2 px-4 py-3 rounded-full border border-white/30 hover:bg-white/10 transition-all">
                  <Play size={16} />
                  Learn More
                </button>
              </div>
            </div>

            {/* Floating Cards */}
            <div className="hidden lg:block relative h-[420px]">
              <div className="absolute top-8 left-8 bg-white rounded-2xl shadow-2xl p-5 z-30 w-56 animate-float">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{backgroundColor: '#F3F4F6'}}>
                    <DollarSign size={16} style={{color: '#0C3B2E'}} />
                  </div>
                  <span className="text-xs text-gray-500">Revenue Today</span>
                </div>
                <div className="text-2xl font-bold" style={{color: '#0C3B2E'}}>$142,500.00</div>
                <div className="text-xs mt-1 font-medium" style={{color: '#6D9773'}}>↑ +12.4% from yesterday</div>
              </div>

              <div className="absolute top-4 right-0 bg-white rounded-2xl shadow-2xl p-5 z-20 w-52 animate-float-delayed">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{backgroundColor: '#F3F4F6'}}>
                    <Ticket size={16} style={{color: '#0C3B2E'}} />
                  </div>
                  <span className="text-xs text-gray-500">Bookings Today</span>
                </div>
                <div className="text-2xl font-bold" style={{color: '#0C3B2E'}}>24,930</div>
                <div className="mt-2 h-1.5 rounded-full bg-gray-100">
                  <div className="h-full w-3/4 rounded-full" style={{backgroundColor: '#BB8A52'}}></div>
                </div>
              </div>

              <div className="absolute bottom-16 left-12 bg-white rounded-2xl shadow-2xl p-5 z-30 w-56 animate-float">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{backgroundColor: '#F3F4F6'}}>
                    <Network size={16} style={{color: '#0C3B2E'}} />
                  </div>
                  <span className="text-xs text-gray-500">Active Routes</span>
                </div>
                <div className="text-2xl font-bold" style={{color: '#0C3B2E'}}>1,248</div>
                <div className="text-xs text-gray-500 mt-1">Global flight & bus paths</div>
              </div>

              <div className="absolute bottom-2 right-4 bg-white rounded-2xl shadow-2xl p-5 z-20 w-52 animate-float-delayed">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{backgroundColor: '#F3F4F6'}}>
                    <ShieldCheck size={16} style={{color: '#0C3B2E'}} />
                  </div>
                  <span className="text-xs text-gray-500">Verified Tickets</span>
                </div>
                <div className="text-xl font-bold" style={{color: '#0C3B2E'}}>99.8% Approval</div>
                <div className="text-xs text-gray-500 mt-1">Rate</div>
              </div>
            </div>
          </div>
        </div>

        <div className="absolute bottom-6 left-1/2 -translate-x-1/2 text-white/50 animate-bounce">
          <ChevronRight size={28} className="rotate-90" />
        </div>
      </section>

      {/* ============ SOLUTIONS - COMPREHENSIVE MANAGEMENT ============ */}
      <section id="solutions" className="py-24 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <AnimatedSection>
            <div className="text-center mb-16">
              <h2 className="text-4xl md:text-5xl font-bold mb-4" style={{color: '#0C3B2E'}}>
                Comprehensive Management
              </h2>
              <p className="text-gray-500 max-w-xl mx-auto">
                Streamline diverse booking streams into a single, cohesive administrative experience.
              </p>
            </div>
          </AnimatedSection>

          {/* Main 6 cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            {services.map((service, i) => (
              <AnimatedSection key={i} delay={i * 100}>
                <div className="group relative rounded-2xl overflow-hidden h-56 cursor-pointer shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2">
                  <img src={service.image} alt={service.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
                  <div className="absolute inset-0 transition-all duration-300" style={{
                    background: 'linear-gradient(to top, rgba(12, 59, 46, 0.95) 0%, rgba(12, 59, 46, 0.4) 60%, transparent 100%)'
                  }}></div>
                  <div className="absolute top-4 right-4 w-10 h-10 rounded-xl flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 transform group-hover:translate-y-0 translate-y-4"
                    style={{backgroundColor: '#BB8A52'}}>
                    <service.icon className="text-white" size={20} />
                  </div>
                  <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
                    <h3 className="text-lg font-bold mb-1">{service.title}</h3>
                    <div className="flex items-center gap-1 text-xs font-semibold transition-all group-hover:gap-2" style={{color: '#BB8A52'}}>
                      {service.subtitle}
                      <ArrowRight size={12} />
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>

          {/* Extra 3 cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {extraCards.map((card, i) => (
              <AnimatedSection key={i} delay={(i + 6) * 100}>
                <div className="group relative rounded-2xl overflow-hidden h-56 cursor-pointer shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2">
                  <img src={card.image} alt={card.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
                  <div className="absolute inset-0" style={{
                    background: 'linear-gradient(to top, rgba(12, 59, 46, 0.95) 0%, rgba(12, 59, 46, 0.4) 60%, transparent 100%)'
                  }}></div>
                  <div className="absolute top-4 right-4 w-10 h-10 rounded-xl flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300"
                    style={{backgroundColor: '#BB8A52'}}>
                    <card.icon className="text-white" size={20} />
                  </div>
                  <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
                    <h3 className="text-lg font-bold mb-1">{card.title}</h3>
                    <div className="flex items-center gap-1 text-xs font-semibold" style={{color: '#BB8A52'}}>
                      {card.subtitle} <ArrowRight size={12} />
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ============ HOW TO USE ============ */}
      <section id="how-to-use" className="py-24" style={{backgroundColor: '#F9FAFB'}}>
        <div className="max-w-6xl mx-auto px-6">
          <AnimatedSection>
            <div className="text-center mb-16">
              <div className="inline-flex items-center gap-2 text-white px-4 py-2 rounded-full text-xs font-semibold mb-4 tracking-widest"
                style={{backgroundColor: '#BB8A52'}}>
                <Smartphone size={14} />
                HOW IT WORKS
              </div>
              <h2 className="text-4xl md:text-5xl font-bold mb-4" style={{color: '#0C3B2E'}}>
                Book in 4 Simple Steps
              </h2>
              <p className="text-gray-500 max-w-xl mx-auto">
                From searching to getting your digital ticket — it's fast, simple, and secure.
              </p>
            </div>
          </AnimatedSection>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            {howToUseSteps.map((step, i) => (
              <AnimatedSection key={i} delay={i * 150}>
                <div className="relative text-center group">
                  {/* Connector Line */}
                  {i < 3 && (
                    <div className="hidden md:block absolute top-12 left-[60%] w-[80%] h-0.5 bg-gray-200 z-0"></div>
                  )}
                  
                  {/* Step Number */}
                  <div className="relative z-10 w-24 h-24 mx-auto mb-6 rounded-2xl flex items-center justify-center transition-all duration-500 group-hover:scale-110 group-hover:shadow-xl group-hover:-translate-y-2"
                    style={{backgroundColor: '#0C3B2E'}}>
                    <step.icon className="text-white" size={36} />
                    <div className="absolute -top-2 -right-2 w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-lg"
                      style={{backgroundColor: '#BB8A52'}}>
                      {step.step}
                    </div>
                  </div>
                  
                  <h3 className="text-lg font-bold mb-2" style={{color: '#0C3B2E'}}>
                    {step.title}
                  </h3>
                  <p className="text-sm text-gray-500 leading-relaxed">
                    {step.desc}
                  </p>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ============ PLATFORM - ENTERPRISE INFRASTRUCTURE ============ */}
      <section id="platform" className="py-24 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <AnimatedSection>
            <div className="text-center mb-16">
              <h2 className="text-4xl md:text-5xl font-bold mb-4" style={{color: '#0C3B2E'}}>
                Enterprise Grade Infrastructure
              </h2>
              <p className="text-gray-500 max-w-xl mx-auto">
                Built for scale, security, and performance. The engine driving a billion bookings.
              </p>
            </div>
          </AnimatedSection>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {infrastructure.map((item, i) => (
              <AnimatedSection key={i} delay={i * 100}>
                <div className="bg-white p-8 rounded-2xl border border-gray-100 hover:shadow-xl hover:border-gray-200 hover:-translate-y-2 transition-all duration-500 group">
                  <div className="w-12 h-12 rounded-xl mb-4 flex items-center justify-center transition-all duration-300 group-hover:scale-110"
                    style={{backgroundColor: '#BB8A52'}}>
                    <item.icon size={24} className="text-white" />
                  </div>
                  <h3 className="text-lg font-bold mb-3" style={{color: '#0C3B2E'}}>
                    {item.title}
                  </h3>
                  <p className="text-sm text-gray-500 leading-relaxed">
                    {item.desc}
                  </p>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ============ MOBILE APP SECTION ============ */}
      <section id="mobile-app" className="py-24" style={{backgroundColor: '#0C3B2E'}}>
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            {/* Left - Phone Mockup */}
            <AnimatedSection>
              <div className="relative flex justify-center">
                {/* Phone Frame */}
                <div className="relative w-72 h-[580px] bg-gray-900 rounded-[3rem] p-3 shadow-2xl border-4 border-gray-700">
                  <div className="w-full h-full rounded-[2.5rem] overflow-hidden bg-white relative">
                    {/* Status Bar */}
                    <div className="h-12 flex items-center justify-center" style={{backgroundColor: '#0C3B2E'}}>
                      <div className="w-20 h-5 bg-black rounded-full"></div>
                    </div>
                    
                    {/* App Content */}
                    <div className="p-4" style={{backgroundColor: '#F9FAFB'}}>
                      {/* App Header */}
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-2">
                          <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{backgroundColor: '#6D9773'}}>
                            <Ticket className="text-white" size={14} />
                          </div>
                          <span className="text-sm font-bold" style={{color: '#0C3B2E'}}>TicketHub</span>
                        </div>
                        <Bell size={18} style={{color: '#0C3B2E'}} />
                      </div>

                      {/* Greeting */}
                      <h3 className="text-lg font-bold mb-1" style={{color: '#0C3B2E'}}>Hello, Ahmed</h3>
                      <p className="text-xs text-gray-500 mb-4">Where would you like to go?</p>

                      {/* Search */}
                      <div className="bg-white rounded-full px-3 py-2 mb-4 shadow-sm flex items-center gap-2">
                        <Search size={14} className="text-gray-400" />
                        <span className="text-xs text-gray-400">Search movies, flights...</span>
                      </div>

                      {/* Categories */}
                      <div className="grid grid-cols-4 gap-2 mb-4">
                        {[
                          { icon: Film, label: 'Movies' },
                          { icon: Bus, label: 'Bus' },
                          { icon: Train, label: 'Train' },
                          { icon: Plane, label: 'Flights' },
                        ].map((cat, i) => (
                          <div key={i} className="text-center">
                            <div className="w-10 h-10 mx-auto rounded-xl flex items-center justify-center mb-1" style={{backgroundColor: '#6D9773'}}>
                              <cat.icon className="text-white" size={16} />
                            </div>
                            <span className="text-[9px]" style={{color: '#0C3B2E'}}>{cat.label}</span>
                          </div>
                        ))}
                      </div>

                      {/* Trending Card */}
                      <div className="bg-white rounded-xl p-3 shadow-sm">
                        <div className="h-20 rounded-lg mb-2 overflow-hidden">
                          <img src="https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400"
                            alt="Movie" className="w-full h-full object-cover" />
                        </div>
                        <h4 className="text-xs font-bold" style={{color: '#0C3B2E'}}>Trending Now</h4>
                        <p className="text-[9px] text-gray-500">Avengers • IMAX</p>
                      </div>

                      {/* Bottom Nav */}
                      <div className="flex justify-around mt-4 pt-3 border-t border-gray-200">
                        {[
                          { icon: '🏠', label: 'Home' },
                          { icon: '🔍', label: 'Search' },
                          { icon: '🎫', label: 'Tickets' },
                          { icon: '💰', label: 'Wallet' },
                          { icon: '👤', label: 'Profile' },
                        ].map((nav, i) => (
                          <div key={i} className="text-center">
                            <span className="text-sm">{nav.icon}</span>
                            <p className="text-[8px] text-gray-500">{nav.label}</p>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Floating elements */}
                <div className="absolute -top-4 -right-8 bg-white rounded-xl shadow-xl p-3 animate-float z-20">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full flex items-center justify-center" style={{backgroundColor: '#6D9773'}}>
                      <Check className="text-white" size={14} />
                    </div>
                    <div>
                      <p className="text-xs font-bold" style={{color: '#0C3B2E'}}>Booking Confirmed!</p>
                      <p className="text-[10px] text-gray-500">LHE → DXB • Oct 25</p>
                    </div>
                  </div>
                </div>

                <div className="absolute bottom-20 -left-8 bg-white rounded-xl shadow-xl p-3 animate-float-delayed z-20">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full flex items-center justify-center" style={{backgroundColor: '#BB8A52'}}>
                      <Star className="text-white" size={14} />
                    </div>
                    <div>
                      <p className="text-xs font-bold" style={{color: '#0C3B2E'}}>4.8 Rating</p>
                      <p className="text-[10px] text-gray-500">500K+ users</p>
                    </div>
                  </div>
                </div>
              </div>
            </AnimatedSection>

            {/* Right - Features */}
            <div className="text-white">
              <AnimatedSection>
                <div className="inline-flex items-center gap-2 text-xs mb-4 tracking-widest" style={{color: '#BB8A52'}}>
                  <Smartphone size={14} />
                  MOBILE APP
                </div>
                <h2 className="text-3xl md:text-4xl font-bold mb-4">
                  Everything in Your
                  <span className="block" style={{color: '#BB8A52'}}>Pocket.</span>
                </h2>
                <p className="text-white/70 mb-8 leading-relaxed">
                  Download the TicketHub app and carry your tickets everywhere. Book on the go, 
                  get instant notifications, and manage all your bookings seamlessly.
                </p>
              </AnimatedSection>

              <div className="grid grid-cols-2 gap-4 mb-8">
                {appFeatures.map((feature, i) => (
                  <AnimatedSection key={i} delay={i * 100}>
                    <div className="flex items-start gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-all duration-300 group">
                      <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110"
                        style={{backgroundColor: '#BB8A52'}}>
                        <feature.icon className="text-white" size={16} />
                      </div>
                      <div>
                        <h4 className="text-sm font-bold">{feature.title}</h4>
                        <p className="text-xs text-white/60">{feature.desc}</p>
                      </div>
                    </div>
                  </AnimatedSection>
                ))}
              </div>

              <AnimatedSection delay={600}>
                <div className="flex gap-3">
                  <button className="flex items-center gap-2 bg-white text-black px-5 py-3 rounded-xl font-semibold text-sm hover:scale-105 transition-all shadow-lg">
                    <Download size={18} />
                    App Store
                  </button>
                  <button className="flex items-center gap-2 bg-white text-black px-5 py-3 rounded-xl font-semibold text-sm hover:scale-105 transition-all shadow-lg">
                    <Play size={18} />
                    Google Play
                  </button>
                </div>
              </AnimatedSection>
            </div>
          </div>
        </div>
      </section>

      {/* ============ ENTERPRISE - INSIGHTFUL DATA ============ */}
      <section id="enterprise" className="py-24 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <AnimatedSection>
              <div className="rounded-2xl overflow-hidden shadow-2xl hover:shadow-3xl transition-all duration-500 hover:-translate-y-2">
                <img 
                  src="https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800" 
                  alt="Analytics"
                  className="w-full h-auto"
                />
              </div>
            </AnimatedSection>

            <AnimatedSection delay={200}>
              <div>
                <h3 className="text-3xl md:text-4xl font-bold mb-4">
                  <span style={{color: '#BB8A52'}}>Insightful Data,</span>
                  <br />
                  <span style={{color: '#0C3B2E'}}>Smarter Decisions.</span>
                </h3>
                <p className="text-gray-500 mb-8 leading-relaxed">
                  Our advanced analytics suite provides a holistic view of your business 
                  operations. Track conversion rates, monitor peak booking hours, and 
                  identify high-value customer segments with ease.
                </p>
                <ul className="space-y-4">
                  {[
                    'Predictive demand forecasting for dynamic pricing',
                    'Customizable reporting for stakeholders',
                    'Real-time fraud detection and alerting'
                  ].map((item, i) => (
                    <AnimatedSection key={i} delay={300 + i * 100}>
                      <li className="flex items-center gap-3 group">
                        <div className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 transition-transform group-hover:scale-110"
                          style={{backgroundColor: '#BB8A52'}}>
                          <Check size={14} className="text-white" />
                        </div>
                        <span className="text-sm text-gray-600">{item}</span>
                      </li>
                    </AnimatedSection>
                  ))}
                </ul>
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* ============ TESTIMONIALS ============ */}
      <section className="py-24" style={{backgroundColor: '#F9FAFB'}}>
        <div className="max-w-6xl mx-auto px-6">
          <AnimatedSection>
            <div className="text-center mb-16">
              <h2 className="text-4xl md:text-5xl font-bold mb-4" style={{color: '#0C3B2E'}}>
                What Our Partners Say
              </h2>
              <p className="text-gray-500">Real experiences from real businesses.</p>
            </div>
          </AnimatedSection>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {testimonials.map((t, i) => (
              <AnimatedSection key={i} delay={i * 150}>
                <div className="bg-white p-8 rounded-2xl border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-500">
                  <div className="flex mb-4" style={{color: '#BB8A52'}}>
                    {[...Array(t.rating)].map((_, j) => (
                      <Star key={j} size={18} fill="currentColor" />
                    ))}
                  </div>
                  <p className="text-gray-600 mb-6 italic leading-relaxed">
                    "{t.text}"
                  </p>
                  <div className="flex items-center gap-3">
                    <img src={t.image} alt={t.name}
                      className="w-12 h-12 rounded-full object-cover border-2" style={{borderColor: '#6D9773'}} />
                    <div>
                      <h4 className="font-bold text-sm" style={{color: '#0C3B2E'}}>{t.name}</h4>
                      <p className="text-xs text-gray-500">{t.role}</p>
                    </div>
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ============ STATS ============ */}
      <section className="py-20 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat, i) => (
              <AnimatedSection key={i} delay={i * 100}>
                <div className="text-center group">
                  <div className="text-4xl md:text-5xl font-bold mb-2 transition-transform group-hover:scale-110" style={{color: '#0C3B2E'}}>
                    {stat.number}
                  </div>
                  <div className="text-xs text-gray-500 tracking-widest">
                    {stat.label}
                  </div>
                </div>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* ============ PARTNERS ============ */}
      <section className="py-12 bg-white border-t border-gray-100">
        <div className="max-w-6xl mx-auto px-6">
          <p className="text-center text-xs text-gray-400 mb-8 tracking-widest">
            TRUSTED BY INDUSTRY LEADERS
          </p>
          <div className="flex flex-wrap justify-center items-center gap-8 md:gap-12">
            {partners.map((partner, i) => (
              <div key={i} className="text-gray-400 hover:text-gray-700 transition-all duration-300 text-sm font-semibold cursor-pointer hover:scale-110">
                {partner}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ============ CTA ============ */}
      <section className="py-16 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <AnimatedSection>
            <div className="rounded-2xl p-12 relative overflow-hidden" style={{backgroundColor: '#0C3B2E'}}>
              <div className="absolute top-0 right-0 w-64 h-64 rounded-full opacity-10" style={{backgroundColor: '#BB8A52', filter: 'blur(80px)'}}></div>
              <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
                <div className="text-white">
                  <h3 className="text-2xl font-bold mb-2">
                    Ready to manage bookings smarter?
                  </h3>
                  <p className="text-white/70 text-sm">
                    Join 500+ businesses who have transformed their operations with TicketHub Admin Portal.
                  </p>
                </div>
                <div className="flex gap-3 flex-shrink-0">
                  <Link to="/signup"
                    className="text-white px-6 py-3 rounded-full text-sm font-semibold transition-all hover:scale-105 hover:shadow-xl"
                    style={{backgroundColor: '#BB8A52'}}>
                    Access Portal
                  </Link>
                  <button className="border border-white/30 text-white px-6 py-3 rounded-full text-sm font-semibold hover:bg-white/10 transition-all">
                    Contact Sales
                  </button>
                </div>
              </div>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* ============ FOOTER ============ */}
      <footer className="py-12 bg-white border-t border-gray-100">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-8">
            <div className="col-span-2 md:col-span-1">
              <div className="text-lg font-bold mb-3" style={{color: '#0C3B2E'}}>
                TicketHub Admin
              </div>
              <p className="text-xs text-gray-500 leading-relaxed mb-4">
                The world's leading unified booking infrastructure for transport, sports, and entertainment.
              </p>
              <div className="flex gap-3">
                {['f', 'in', 't'].map((s, i) => (
                  <a key={i} href="#"
                    className="w-8 h-8 rounded-full border border-gray-200 flex items-center justify-center text-gray-400 hover:border-gray-400 hover:text-gray-600 transition-all text-xs">
                    {s}
                  </a>
                ))}
              </div>
            </div>

            {[
              { title: 'PLATFORM', links: ['Movies', 'Transport', 'Events', 'Theme Parks'] },
              { title: 'COMPANY', links: ['About Us', 'Careers', 'Security', 'Status'] },
              { title: 'LEGAL', links: ['Privacy Policy', 'Terms of Service'] },
            ].map((section, i) => (
              <div key={i}>
                <h4 className="text-xs font-bold text-gray-400 tracking-widest mb-4">{section.title}</h4>
                <ul className="space-y-2 text-sm text-gray-600">
                  {section.links.map((link, j) => (
                    <li key={j}><a href="#" className="hover:text-gray-900 transition-colors">{link}</a></li>
                  ))}
                </ul>
              </div>
            ))}
          </div>

          <div className="pt-8 border-t border-gray-100 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-xs text-gray-400">
              © 2024 TicketHub Global. All rights reserved.
            </p>
            <div className="flex gap-4 text-xs text-gray-400">
              <a href="#" className="hover:text-gray-600">LinkedIn</a>
              <a href="#" className="hover:text-gray-600">X | Twitter</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}