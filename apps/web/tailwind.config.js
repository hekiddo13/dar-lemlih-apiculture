/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#fef5e7',
          100: '#fde7c2',
          200: '#fbd588',
          300: '#f8ba44',
          400: '#f59e0b',
          500: '#e07c09',
          600: '#c25d05',
          700: '#9b4307',
          800: '#7e360d',
          900: '#6a2e0e',
        },
        honey: {
          light: '#fbbf24',
          DEFAULT: '#f59e0b',
          dark: '#d97706',
        }
      },
      fontFamily: {
        'arabic': ['Noto Sans Arabic', 'sans-serif'],
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(20px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [
    function({ addUtilities }) {
      addUtilities({
        '.rtl': {
          direction: 'rtl',
        },
        '.ltr': {
          direction: 'ltr',
        },
      })
    }
  ],
}
