/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#0f172a',    // Dark blue slate
          navy: '#1e3a8a',    // Deep medical blue
          primary: '#0284c7', // Sky medical blue
          teal: '#0d9488',    // Medical teal/green
          emerald: '#10b981', // Success green
          accent: '#06b6d4',  // Cyan accent
          danger: '#ef4444',  // Emergency red
          warning: '#f59e0b', // Priority amber
        },
      },
      fontFamily: {
        sans: ['"Plus Jakarta Sans"', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

