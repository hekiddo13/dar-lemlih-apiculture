#!/bin/bash

WEB_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/web"

echo "🚀 Generating complete React frontend with i18n and RTL support..."

# Create directory structure
mkdir -p "$WEB_PATH/src/components/layout"
mkdir -p "$WEB_PATH/src/components/common"
mkdir -p "$WEB_PATH/src/components/product"
mkdir -p "$WEB_PATH/src/components/cart"
mkdir -p "$WEB_PATH/src/components/auth"
mkdir -p "$WEB_PATH/src/pages"
mkdir -p "$WEB_PATH/src/hooks"
mkdir -p "$WEB_PATH/src/store"
mkdir -p "$WEB_PATH/src/types"
mkdir -p "$WEB_PATH/src/utils"

# ===== TYPES =====
cat > "$WEB_PATH/src/types/index.ts" << 'TS'
export interface User {
  id: number;
  name: string;
  email: string;
  phone?: string;
  role: 'CUSTOMER' | 'ADMIN';
  emailVerified: boolean;
}

export interface Product {
  id: number;
  sku: string;
  slug: string;
  nameFr: string;
  nameEn: string;
  nameAr: string;
  descriptionFr: string;
  descriptionEn: string;
  descriptionAr: string;
  price: number;
  currency: string;
  stockQuantity: number;
  weightGrams?: number;
  ingredients?: string;
  origin?: string;
  isHalal: boolean;
  isActive: boolean;
  isFeatured: boolean;
  images: string[];
  categoryId?: number;
  categoryName?: string;
}

export interface Category {
  id: number;
  slug: string;
  nameFr: string;
  nameEn: string;
  nameAr: string;
  descriptionFr?: string;
  descriptionEn?: string;
  descriptionAr?: string;
  image?: string;
  displayOrder: number;
  productCount: number;
}

export interface CartItem {
  id: number;
  productId: number;
  productName: string;
  productSlug: string;
  productImage?: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  stockQuantity: number;
}

export interface Cart {
  id: number;
  items: CartItem[];
  subtotal: number;
  shippingCost: number;
  total: number;
  currency: string;
  totalItems: number;
}

export interface Order {
  id: number;
  orderNumber: string;
  status: string;
  subtotal: number;
  shippingCost: number;
  discount: number;
  total: number;
  currency: string;
  paymentProvider?: string;
  trackingNumber?: string;
  shippingAddress: ShippingAddress;
  items: OrderItem[];
  createdAt: string;
  updatedAt: string;
}

export interface OrderItem {
  id: number;
  productId: number;
  productName: string;
  productSku: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface ShippingAddress {
  name: string;
  phone: string;
  line1: string;
  line2?: string;
  city: string;
  region: string;
  postalCode: string;
  country: string;
}
TS

# ===== STORE (Zustand) =====
cat > "$WEB_PATH/src/store/useAuthStore.ts" << 'TS'
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { User } from '../types';
import api from '../lib/api';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: any) => Promise<void>;
  logout: () => void;
  setTokens: (accessToken: string, refreshToken: string) => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,

      login: async (email: string, password: string) => {
        const response = await api.post('/api/auth/login', { email, password });
        const { user, accessToken, refreshToken } = response.data;
        
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', refreshToken);
        
        set({
          user,
          accessToken,
          refreshToken,
          isAuthenticated: true,
        });
      },

      register: async (data: any) => {
        const response = await api.post('/api/auth/register', data);
        const { user, accessToken, refreshToken } = response.data;
        
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', refreshToken);
        
        set({
          user,
          accessToken,
          refreshToken,
          isAuthenticated: true,
        });
      },

      logout: () => {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        set({
          user: null,
          accessToken: null,
          refreshToken: null,
          isAuthenticated: false,
        });
      },

      setTokens: (accessToken: string, refreshToken: string) => {
        localStorage.setItem('accessToken', accessToken);
        localStorage.setItem('refreshToken', refreshToken);
        set({ accessToken, refreshToken });
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
TS

cat > "$WEB_PATH/src/store/useCartStore.ts" << 'TS'
import { create } from 'zustand';
import { Cart, CartItem } from '../types';
import api from '../lib/api';
import toast from 'react-hot-toast';

interface CartState {
  cart: Cart | null;
  loading: boolean;
  fetchCart: () => Promise<void>;
  addToCart: (productId: number, quantity: number) => Promise<void>;
  updateQuantity: (productId: number, quantity: number) => Promise<void>;
  removeFromCart: (productId: number) => Promise<void>;
  clearCart: () => Promise<void>;
}

export const useCartStore = create<CartState>((set, get) => ({
  cart: null,
  loading: false,

  fetchCart: async () => {
    try {
      set({ loading: true });
      const response = await api.get('/api/cart');
      set({ cart: response.data });
    } catch (error) {
      console.error('Failed to fetch cart:', error);
    } finally {
      set({ loading: false });
    }
  },

  addToCart: async (productId: number, quantity: number) => {
    try {
      const response = await api.post('/api/cart/add', { productId, quantity });
      set({ cart: response.data });
      toast.success('Added to cart!');
    } catch (error) {
      toast.error('Failed to add to cart');
      console.error(error);
    }
  },

  updateQuantity: async (productId: number, quantity: number) => {
    try {
      const response = await api.put('/api/cart/update', { productId, quantity });
      set({ cart: response.data });
    } catch (error) {
      toast.error('Failed to update quantity');
      console.error(error);
    }
  },

  removeFromCart: async (productId: number) => {
    try {
      const response = await api.delete(`/api/cart/remove/${productId}`);
      set({ cart: response.data });
      toast.success('Removed from cart');
    } catch (error) {
      toast.error('Failed to remove from cart');
      console.error(error);
    }
  },

  clearCart: async () => {
    try {
      await api.delete('/api/cart/clear');
      set({ cart: null });
    } catch (error) {
      toast.error('Failed to clear cart');
      console.error(error);
    }
  },
}));
TS

# ===== LAYOUT COMPONENTS =====
cat > "$WEB_PATH/src/components/layout/Header.tsx" << 'TSX'
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ShoppingCart, User, Menu, Globe, X } from 'lucide-react';
import { useState } from 'react';
import { useAuthStore } from '../../store/useAuthStore';
import { useCartStore } from '../../store/useCartStore';

export default function Header() {
  const { t, i18n } = useTranslation();
  const { isAuthenticated, logout } = useAuthStore();
  const { cart } = useCartStore();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [langMenuOpen, setLangMenuOpen] = useState(false);

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
    document.dir = lng === 'ar' ? 'rtl' : 'ltr';
    setLangMenuOpen(false);
  };

  const languages = [
    { code: 'fr', name: 'Français', flag: '🇫🇷' },
    { code: 'en', name: 'English', flag: '🇬🇧' },
    { code: 'ar', name: 'العربية', flag: '🇸🇦' },
  ];

  return (
    <header className="sticky top-0 z-50 bg-white shadow-md">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2 rtl:space-x-reverse">
            <span className="text-2xl">🍯</span>
            <span className="font-bold text-xl text-honey">Dar Lemlih</span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-8 rtl:space-x-reverse">
            <Link to="/" className="hover:text-honey transition-colors">
              {t('nav.home')}
            </Link>
            <Link to="/products" className="hover:text-honey transition-colors">
              {t('nav.products')}
            </Link>
            <Link to="/about" className="hover:text-honey transition-colors">
              {t('nav.about')}
            </Link>
            <Link to="/contact" className="hover:text-honey transition-colors">
              {t('nav.contact')}
            </Link>
          </nav>

          {/* Right Actions */}
          <div className="flex items-center space-x-4 rtl:space-x-reverse">
            {/* Language Selector */}
            <div className="relative">
              <button
                onClick={() => setLangMenuOpen(!langMenuOpen)}
                className="flex items-center space-x-1 rtl:space-x-reverse hover:text-honey"
              >
                <Globe size={20} />
                <span className="hidden sm:inline">{i18n.language.toUpperCase()}</span>
              </button>
              
              {langMenuOpen && (
                <div className="absolute right-0 rtl:left-0 rtl:right-auto mt-2 w-48 bg-white rounded-lg shadow-lg py-2">
                  {languages.map((lang) => (
                    <button
                      key={lang.code}
                      onClick={() => changeLanguage(lang.code)}
                      className={`w-full px-4 py-2 text-left rtl:text-right hover:bg-gray-100 flex items-center space-x-2 rtl:space-x-reverse ${
                        i18n.language === lang.code ? 'bg-gray-50 font-semibold' : ''
                      }`}
                    >
                      <span>{lang.flag}</span>
                      <span>{lang.name}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Cart */}
            <Link to="/cart" className="relative hover:text-honey">
              <ShoppingCart size={24} />
              {cart && cart.totalItems > 0 && (
                <span className="absolute -top-2 -right-2 rtl:-left-2 rtl:right-auto bg-honey text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                  {cart.totalItems}
                </span>
              )}
            </Link>

            {/* User Menu */}
            {isAuthenticated ? (
              <div className="relative group">
                <button className="hover:text-honey">
                  <User size={24} />
                </button>
                <div className="absolute right-0 rtl:left-0 rtl:right-auto mt-2 w-48 bg-white rounded-lg shadow-lg py-2 hidden group-hover:block">
                  <Link to="/account" className="block px-4 py-2 hover:bg-gray-100">
                    {t('common.account')}
                  </Link>
                  <Link to="/orders" className="block px-4 py-2 hover:bg-gray-100">
                    My Orders
                  </Link>
                  <hr className="my-2" />
                  <button
                    onClick={logout}
                    className="w-full text-left rtl:text-right px-4 py-2 hover:bg-gray-100"
                  >
                    {t('common.logout')}
                  </button>
                </div>
              </div>
            ) : (
              <Link to="/login" className="btn btn-primary">
                {t('common.login')}
              </Link>
            )}

            {/* Mobile Menu Toggle */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden"
            >
              {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <nav className="md:hidden py-4 border-t">
            <Link to="/" className="block py-2 hover:text-honey">
              {t('nav.home')}
            </Link>
            <Link to="/products" className="block py-2 hover:text-honey">
              {t('nav.products')}
            </Link>
            <Link to="/about" className="block py-2 hover:text-honey">
              {t('nav.about')}
            </Link>
            <Link to="/contact" className="block py-2 hover:text-honey">
              {t('nav.contact')}
            </Link>
          </nav>
        )}
      </div>
    </header>
  );
}
TSX

cat > "$WEB_PATH/src/components/layout/Footer.tsx" << 'TSX'
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { Facebook, Instagram, Twitter, Mail, Phone, MapPin } from 'lucide-react';

export default function Footer() {
  const { t } = useTranslation();

  return (
    <footer className="bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Company Info */}
          <div>
            <h3 className="text-xl font-bold mb-4 flex items-center">
              <span className="mr-2">🍯</span> Dar Lemlih
            </h3>
            <p className="text-gray-400 mb-4">
              Premium honey and bee products from the heart of Morocco.
            </p>
            <div className="flex space-x-4 rtl:space-x-reverse">
              <a href="#" className="hover:text-honey"><Facebook size={20} /></a>
              <a href="#" className="hover:text-honey"><Instagram size={20} /></a>
              <a href="#" className="hover:text-honey"><Twitter size={20} /></a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="font-semibold mb-4">Quick Links</h4>
            <ul className="space-y-2">
              <li><Link to="/products" className="text-gray-400 hover:text-honey">{t('nav.products')}</Link></li>
              <li><Link to="/about" className="text-gray-400 hover:text-honey">{t('nav.about')}</Link></li>
              <li><Link to="/contact" className="text-gray-400 hover:text-honey">{t('nav.contact')}</Link></li>
              <li><Link to="/faq" className="text-gray-400 hover:text-honey">FAQ</Link></li>
            </ul>
          </div>

          {/* Categories */}
          <div>
            <h4 className="font-semibold mb-4">Categories</h4>
            <ul className="space-y-2">
              <li><Link to="/products?category=miels" className="text-gray-400 hover:text-honey">{t('products.honey')}</Link></li>
              <li><Link to="/products?category=pollen" className="text-gray-400 hover:text-honey">{t('products.pollen')}</Link></li>
              <li><Link to="/products?category=produits-ruche" className="text-gray-400 hover:text-honey">{t('products.hiveProducts')}</Link></li>
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="font-semibold mb-4">Contact</h4>
            <ul className="space-y-2 text-gray-400">
              <li className="flex items-center">
                <Mail size={16} className="mr-2" />
                contact@darlemlih.ma
              </li>
              <li className="flex items-center">
                <Phone size={16} className="mr-2" />
                +212 600 000 000
              </li>
              <li className="flex items-center">
                <MapPin size={16} className="mr-2" />
                Casablanca, Morocco
              </li>
            </ul>
          </div>
        </div>

        <hr className="my-8 border-gray-800" />

        <div className="text-center text-gray-400">
          <p>&copy; 2025 Dar Lemlih Apiculture. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
TSX

# ===== PRODUCT COMPONENTS =====
cat > "$WEB_PATH/src/components/product/ProductCard.tsx" << 'TSX'
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ShoppingCart, Check } from 'lucide-react';
import { Product } from '../../types';
import { useCartStore } from '../../store/useCartStore';
import { useAuthStore } from '../../store/useAuthStore';
import toast from 'react-hot-toast';

interface ProductCardProps {
  product: Product;
}

export default function ProductCard({ product }: ProductCardProps) {
  const { t, i18n } = useTranslation();
  const { addToCart } = useCartStore();
  const { isAuthenticated } = useAuthStore();

  const getName = () => {
    switch (i18n.language) {
      case 'ar': return product.nameAr;
      case 'en': return product.nameEn;
      default: return product.nameFr;
    }
  };

  const getDescription = () => {
    switch (i18n.language) {
      case 'ar': return product.descriptionAr;
      case 'en': return product.descriptionEn;
      default: return product.descriptionFr;
    }
  };

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      toast.error('Please login to add items to cart');
      return;
    }
    await addToCart(product.id, 1);
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300">
      <Link to={`/products/${product.slug}`}>
        <div className="aspect-w-1 aspect-h-1 w-full bg-gray-200">
          {product.images && product.images[0] ? (
            <img
              src={product.images[0]}
              alt={getName()}
              className="w-full h-48 object-cover"
            />
          ) : (
            <div className="w-full h-48 flex items-center justify-center bg-gray-100">
              <span className="text-6xl">🍯</span>
            </div>
          )}
        </div>
      </Link>

      <div className="p-4">
        <Link to={`/products/${product.slug}`}>
          <h3 className="font-semibold text-lg mb-2 hover:text-honey">{getName()}</h3>
        </Link>

        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
          {getDescription()}
        </p>

        <div className="flex items-center justify-between mb-3">
          <span className="text-2xl font-bold text-honey">
            {product.price} {product.currency}
          </span>
          {product.isHalal && (
            <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded">
              {t('products.halal')}
            </span>
          )}
        </div>

        <div className="flex items-center justify-between">
          {product.stockQuantity > 0 ? (
            <>
              <span className="text-sm text-green-600 flex items-center">
                <Check size={16} className="mr-1" />
                {t('products.inStock')}
              </span>
              <button
                onClick={handleAddToCart}
                className="btn btn-primary flex items-center space-x-1"
              >
                <ShoppingCart size={18} />
                <span>{t('common.addToCart')}</span>
              </button>
            </>
          ) : (
            <span className="text-sm text-red-600">{t('products.outOfStock')}</span>
          )}
        </div>
      </div>
    </div>
  );
}
TSX

# ===== HOME PAGE =====
cat > "$WEB_PATH/src/pages/HomePage.tsx" << 'TSX'
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { ArrowRight, Truck, Shield, Award } from 'lucide-react';
import { useEffect, useState } from 'react';
import api from '../lib/api';
import { Product, Category } from '../types';
import ProductCard from '../components/product/ProductCard';

export default function HomePage() {
  const { t } = useTranslation();
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [productsRes, categoriesRes] = await Promise.all([
        api.get('/api/products/featured?size=4'),
        api.get('/api/categories')
      ]);
      setFeaturedProducts(productsRes.data.content);
      setCategories(categoriesRes.data);
    } catch (error) {
      console.error('Failed to fetch data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-honey-light to-honey-dark text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-5xl font-bold mb-6">
              {t('common.welcome')}
            </h1>
            <p className="text-xl mb-8">
              Discover the finest honey and bee products from Morocco's most pristine regions.
            </p>
            <Link to="/products" className="btn bg-white text-honey hover:bg-gray-100 inline-flex items-center">
              Shop Now <ArrowRight className="ml-2" size={20} />
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-12 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <Truck className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">Free Shipping</h3>
              <p className="text-gray-600">On orders over 300 MAD</p>
            </div>
            <div className="text-center">
              <Shield className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">100% Natural</h3>
              <p className="text-gray-600">Pure, raw, and unprocessed</p>
            </div>
            <div className="text-center">
              <Award className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">Premium Quality</h3>
              <p className="text-gray-600">Award-winning bee products</p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Products */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            {t('products.featured')}
          </h2>
          
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {[1,2,3,4].map(i => (
                <div key={i} className="bg-gray-200 rounded-lg h-96 animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {featuredProducts.map(product => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Categories */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">Shop by Category</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {categories.map(category => (
              <Link
                key={category.id}
                to={`/products?category=${category.slug}`}
                className="group relative overflow-hidden rounded-lg shadow-lg hover:shadow-xl transition-shadow"
              >
                <div className="aspect-w-16 aspect-h-9 bg-gray-200">
                  {category.image ? (
                    <img src={category.image} alt={category.nameFr} className="w-full h-64 object-cover" />
                  ) : (
                    <div className="w-full h-64 flex items-center justify-center bg-gradient-to-br from-honey-light to-honey">
                      <span className="text-8xl">🍯</span>
                    </div>
                  )}
                </div>
                <div className="absolute inset-0 bg-black bg-opacity-40 group-hover:bg-opacity-50 transition-colors flex items-center justify-center">
                  <h3 className="text-white text-2xl font-bold">{category.nameFr}</h3>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
TSX

# ===== UPDATED APP.TSX =====
cat > "$WEB_PATH/src/App.tsx" << 'TSX'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useEffect } from 'react';
import './i18n/config';

// Layout
import Header from './components/layout/Header';
import Footer from './components/layout/Footer';

// Pages
import HomePage from './pages/HomePage';

function App() {
  const { i18n } = useTranslation();

  useEffect(() => {
    // Set document direction based on language
    document.dir = i18n.language === 'ar' ? 'rtl' : 'ltr';
    
    // Add language class to body for font selection
    document.body.className = i18n.language === 'ar' ? 'font-arabic' : '';
  }, [i18n.language]);

  return (
    <Router>
      <div className="min-h-screen flex flex-col">
        <Toaster 
          position="top-center"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#333',
              color: '#fff',
            },
          }}
        />
        <Header />
        <main className="flex-grow">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/products" element={<div className="container py-8">Products Page (Coming Soon)</div>} />
            <Route path="/products/:slug" element={<div className="container py-8">Product Details (Coming Soon)</div>} />
            <Route path="/cart" element={<div className="container py-8">Cart Page (Coming Soon)</div>} />
            <Route path="/checkout" element={<div className="container py-8">Checkout Page (Coming Soon)</div>} />
            <Route path="/login" element={<div className="container py-8">Login Page (Coming Soon)</div>} />
            <Route path="/register" element={<div className="container py-8">Register Page (Coming Soon)</div>} />
            <Route path="/account" element={<div className="container py-8">Account Page (Coming Soon)</div>} />
            <Route path="/orders" element={<div className="container py-8">Orders Page (Coming Soon)</div>} />
            <Route path="/about" element={<div className="container py-8">About Page (Coming Soon)</div>} />
            <Route path="/contact" element={<div className="container py-8">Contact Page (Coming Soon)</div>} />
          </Routes>
        </main>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
TSX

# Note: Install zustand manually with: npm install zustand

echo "✅ React frontend generation complete with i18n and RTL support!"
echo "📦 Don't forget to install zustand: cd apps/web && npm install zustand"
