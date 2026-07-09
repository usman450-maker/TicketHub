/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // ✅ TUMHARE EXACT COLORS
        primary: {
          DEFAULT: '#6D9773',      // Main green
          dark: '#0C3B2E',         // Dark green (hover/active)
        },
        bronze: {
          DEFAULT: '#BB8A52',
        },
        accent: {
          DEFAULT: '#FFBAD0',
        },
        // Text
        'text-dark': '#0C3B2E',
        'text-grey': '#6B7280',
        // Backgrounds
        'bg-main': '#F9FAFB',
        'border-grey': '#E5E7EB',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}