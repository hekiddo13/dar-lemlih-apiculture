#!/bin/bash

WEB_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/web"

echo "Setting up React frontend with i18n..."

# Create i18n directory structure
mkdir -p "$WEB_PATH/src/i18n/locales"

# Create French translations
cat > "$WEB_PATH/src/i18n/locales/fr.json" << 'JSON'
{
  "common": {
    "welcome": "Bienvenue chez Dar Lemlih Apiculture",
    "search": "Rechercher",
    "cart": "Panier",
    "login": "Connexion",
    "logout": "Déconnexion",
    "register": "S'inscrire",
    "account": "Mon compte",
    "language": "Langue",
    "currency": "MAD",
    "addToCart": "Ajouter au panier",
    "viewCart": "Voir le panier",
    "checkout": "Commander",
    "total": "Total",
    "subtotal": "Sous-total",
    "shipping": "Livraison",
    "continueShopping": "Continuer vos achats"
  },
  "nav": {
    "home": "Accueil",
    "products": "Produits",
    "about": "À propos",
    "contact": "Contact"
  },
  "products": {
    "honey": "Miels",
    "pollen": "Pollen",
    "hiveProducts": "Produits de la ruche",
    "featured": "Produits vedettes",
    "allProducts": "Tous les produits",
    "price": "Prix",
    "weight": "Poids",
    "origin": "Origine",
    "ingredients": "Ingrédients",
    "inStock": "En stock",
    "outOfStock": "Rupture de stock",
    "halal": "Halal"
  },
  "auth": {
    "email": "Email",
    "password": "Mot de passe",
    "name": "Nom",
    "phone": "Téléphone",
    "forgotPassword": "Mot de passe oublié?",
    "resetPassword": "Réinitialiser le mot de passe",
    "createAccount": "Créer un compte",
    "alreadyHaveAccount": "Déjà un compte?",
    "noAccount": "Pas encore de compte?"
  }
}
JSON

# Create English translations
cat > "$WEB_PATH/src/i18n/locales/en.json" << 'JSON'
{
  "common": {
    "welcome": "Welcome to Dar Lemlih Apiculture",
    "search": "Search",
    "cart": "Cart",
    "login": "Login",
    "logout": "Logout",
    "register": "Register",
    "account": "My Account",
    "language": "Language",
    "currency": "MAD",
    "addToCart": "Add to Cart",
    "viewCart": "View Cart",
    "checkout": "Checkout",
    "total": "Total",
    "subtotal": "Subtotal",
    "shipping": "Shipping",
    "continueShopping": "Continue Shopping"
  },
  "nav": {
    "home": "Home",
    "products": "Products",
    "about": "About",
    "contact": "Contact"
  },
  "products": {
    "honey": "Honeys",
    "pollen": "Pollen",
    "hiveProducts": "Hive Products",
    "featured": "Featured Products",
    "allProducts": "All Products",
    "price": "Price",
    "weight": "Weight",
    "origin": "Origin",
    "ingredients": "Ingredients",
    "inStock": "In Stock",
    "outOfStock": "Out of Stock",
    "halal": "Halal"
  },
  "auth": {
    "email": "Email",
    "password": "Password",
    "name": "Name",
    "phone": "Phone",
    "forgotPassword": "Forgot Password?",
    "resetPassword": "Reset Password",
    "createAccount": "Create Account",
    "alreadyHaveAccount": "Already have an account?",
    "noAccount": "Don't have an account?"
  }
}
JSON

# Create Arabic translations
cat > "$WEB_PATH/src/i18n/locales/ar.json" << 'JSON'
{
  "common": {
    "welcome": "مرحباً بكم في دار لمليح لتربية النحل",
    "search": "بحث",
    "cart": "السلة",
    "login": "تسجيل الدخول",
    "logout": "تسجيل الخروج",
    "register": "إنشاء حساب",
    "account": "حسابي",
    "language": "اللغة",
    "currency": "درهم",
    "addToCart": "أضف إلى السلة",
    "viewCart": "عرض السلة",
    "checkout": "إتمام الطلب",
    "total": "المجموع",
    "subtotal": "المجموع الفرعي",
    "shipping": "الشحن",
    "continueShopping": "متابعة التسوق"
  },
  "nav": {
    "home": "الرئيسية",
    "products": "المنتجات",
    "about": "من نحن",
    "contact": "اتصل بنا"
  },
  "products": {
    "honey": "عسل",
    "pollen": "حبوب اللقاح",
    "hiveProducts": "منتجات النحل",
    "featured": "منتجات مميزة",
    "allProducts": "جميع المنتجات",
    "price": "السعر",
    "weight": "الوزن",
    "origin": "المنشأ",
    "ingredients": "المكونات",
    "inStock": "متوفر",
    "outOfStock": "نفذ المخزون",
    "halal": "حلال"
  },
  "auth": {
    "email": "البريد الإلكتروني",
    "password": "كلمة المرور",
    "name": "الاسم",
    "phone": "الهاتف",
    "forgotPassword": "نسيت كلمة المرور؟",
    "resetPassword": "إعادة تعيين كلمة المرور",
    "createAccount": "إنشاء حساب",
    "alreadyHaveAccount": "لديك حساب بالفعل؟",
    "noAccount": "ليس لديك حساب؟"
  }
}
JSON

# Create i18n configuration
cat > "$WEB_PATH/src/i18n/config.ts" << 'TS'
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

import frTranslations from './locales/fr.json';
import enTranslations from './locales/en.json';
import arTranslations from './locales/ar.json';

const resources = {
  fr: { translation: frTranslations },
  en: { translation: enTranslations },
  ar: { translation: arTranslations }
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'fr',
    debug: false,
    interpolation: {
      escapeValue: false
    },
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage']
    }
  });

export default i18n;
TS

# Update index.css for Tailwind
cat > "$WEB_PATH/src/index.css" << 'CSS'
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Arabic:wght@400;500;600;700&display=swap');
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
  }

  * {
    @apply border-border;
  }

  body {
    @apply bg-background text-foreground;
  }
}

@layer components {
  .container {
    @apply mx-auto px-4 sm:px-6 lg:px-8 max-w-7xl;
  }

  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-colors duration-200;
  }

  .btn-primary {
    @apply bg-honey text-white hover:bg-honey-dark;
  }

  .btn-secondary {
    @apply bg-gray-200 text-gray-800 hover:bg-gray-300;
  }
}

/* RTL Support */
[dir="rtl"] {
  font-family: 'Noto Sans Arabic', sans-serif;
}

[dir="rtl"] .rtl\:text-right {
  text-align: right;
}

[dir="rtl"] .rtl\:ml-auto {
  margin-right: auto;
  margin-left: 0;
}
CSS

# Create API client
mkdir -p "$WEB_PATH/src/lib"

cat > "$WEB_PATH/src/lib/api.ts" << 'TS'
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080'\;

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await api.post('/api/auth/refresh', null, {
          params: { refreshToken }
        });
        
        const { accessToken, refreshToken: newRefreshToken } = response.data;
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', newRefreshToken);
        
        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        // Refresh failed, redirect to login
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

export default api;
TS

# Create App.tsx with routing
cat > "$WEB_PATH/src/App.tsx" << 'TSX'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useEffect } from 'react';
import './i18n/config';

function App() {
  const { i18n } = useTranslation();

  useEffect(() => {
    // Set document direction based on language
    document.dir = i18n.language === 'ar' ? 'rtl' : 'ltr';
  }, [i18n.language]);

  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Toaster position="top-center" />
        <Routes>
          <Route path="/" element={<div className="container py-8"><h1 className="text-3xl font-bold text-center">Dar Lemlih Apiculture - E-Commerce Platform</h1><p className="text-center mt-4">🚧 Under Construction 🚧</p></div>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
TSX

# Create .env.example for frontend
cat > "$WEB_PATH/.env.example" << 'ENV'
VITE_API_URL=http://localhost:8080
VITE_APP_DEFAULT_LANG=fr
VITE_APP_SUPPORTED_LANGS=fr,en,ar
VITE_PAYMENT_PROVIDER=mock
ENV

# Create nginx configuration for production
cat > "$WEB_PATH/nginx.conf" << 'NGINX'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # React Router support
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
NGINX

echo "Frontend setup complete!"
