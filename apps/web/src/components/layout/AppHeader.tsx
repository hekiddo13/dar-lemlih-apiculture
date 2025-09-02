import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
  Menu,
  X,
  ShoppingCart,
  User,
  LogOut,
  Package,
  Globe,
  ChevronDown,
} from 'lucide-react';
import { useAuthStore } from '../../stores/authStore';
import { useCartStore } from '../../stores/cartStore';
import Button from '../ui/Button';
import { cn } from '../../lib/utils';

export default function AppHeader() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isLangMenuOpen, setIsLangMenuOpen] = useState(false);
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false);
  
  const { user, isAuthenticated, logout } = useAuthStore();
  const { items } = useCartStore();
  
  const cartItemsCount = items.reduce((acc, item) => acc + item.quantity, 0);

  const languages = [
    { code: 'fr', name: 'Français', flag: '🇫🇷' },
    { code: 'en', name: 'English', flag: '🇬🇧' },
    { code: 'ar', name: 'العربية', flag: '🇲🇦' },
  ];

  const currentLang = languages.find(lang => lang.code === i18n.language) || languages[0];

  const handleLanguageChange = (langCode: string) => {
    i18n.changeLanguage(langCode);
    setIsLangMenuOpen(false);
  };

  const handleLogout = () => {
    logout();
    navigate('/');
    setIsUserMenuOpen(false);
  };

  // Close menus when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      setIsLangMenuOpen(false);
      setIsUserMenuOpen(false);
    };
    
    if (isLangMenuOpen || isUserMenuOpen) {
      document.addEventListener('click', handleClickOutside);
      return () => document.removeEventListener('click', handleClickOutside);
    }
  }, [isLangMenuOpen, isUserMenuOpen]);

  return (
    <header className="bg-white shadow-sm sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2">
            <span className="text-2xl">🍯</span>
            <span className="font-bold text-xl text-orange-600">
              Dar Lemlih
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <Link
              to="/"
              className="text-gray-700 hover:text-orange-600 transition-colors"
            >
              {t('nav.home')}
            </Link>
            <Link
              to="/products"
              className="text-gray-700 hover:text-orange-600 transition-colors"
            >
              {t('nav.products')}
            </Link>
            {isAuthenticated && user?.role === 'ADMIN' && (
              <Link
                to="/admin"
                className="text-gray-700 hover:text-orange-600 transition-colors"
              >
                {t('nav.admin')}
              </Link>
            )}
          </nav>

          {/* Right side actions */}
          <div className="flex items-center space-x-4">
            {/* Language Switcher */}
            <div className="relative">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setIsLangMenuOpen(!isLangMenuOpen);
                }}
                className="flex items-center space-x-1 text-gray-700 hover:text-orange-600 transition-colors"
              >
                <Globe className="h-5 w-5" />
                <span className="hidden sm:inline">{currentLang.flag}</span>
                <ChevronDown className="h-4 w-4" />
              </button>
              
              {isLangMenuOpen && (
                <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 border">
                  {languages.map(lang => (
                    <button
                      key={lang.code}
                      onClick={() => handleLanguageChange(lang.code)}
                      className={cn(
                        'w-full px-4 py-2 text-left hover:bg-gray-100 flex items-center space-x-2',
                        lang.code === i18n.language && 'bg-orange-50'
                      )}
                    >
                      <span>{lang.flag}</span>
                      <span>{lang.name}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Cart */}
            <Link
              to="/cart"
              className="relative text-gray-700 hover:text-orange-600 transition-colors"
            >
              <ShoppingCart className="h-6 w-6" />
              {cartItemsCount > 0 && (
                <span className="absolute -top-2 -right-2 bg-orange-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                  {cartItemsCount}
                </span>
              )}
            </Link>

            {/* User Menu */}
            {isAuthenticated ? (
              <div className="relative">
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsUserMenuOpen(!isUserMenuOpen);
                  }}
                  className="flex items-center space-x-2 text-gray-700 hover:text-orange-600 transition-colors"
                >
                  <User className="h-6 w-6" />
                  <span className="hidden sm:inline">{user?.name}</span>
                  <ChevronDown className="h-4 w-4" />
                </button>
                
                {isUserMenuOpen && (
                  <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 border">
                    <Link
                      to="/orders"
                      className="w-full px-4 py-2 text-left hover:bg-gray-100 flex items-center space-x-2"
                    >
                      <Package className="h-4 w-4" />
                      <span>{t('nav.orders')}</span>
                    </Link>
                    <button
                      onClick={handleLogout}
                      className="w-full px-4 py-2 text-left hover:bg-gray-100 flex items-center space-x-2 text-red-600"
                    >
                      <LogOut className="h-4 w-4" />
                      <span>{t('nav.logout')}</span>
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <div className="hidden md:flex items-center space-x-2">
                <Link to="/login">
                  <Button variant="ghost" size="sm">
                    {t('nav.login')}
                  </Button>
                </Link>
                <Link to="/register">
                  <Button size="sm">
                    {t('nav.register')}
                  </Button>
                </Link>
              </div>
            )}

            {/* Mobile menu button */}
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="md:hidden text-gray-700 hover:text-orange-600"
            >
              {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMenuOpen && (
        <div className="md:hidden bg-white border-t">
          <div className="px-4 py-2 space-y-1">
            <Link
              to="/"
              className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
              onClick={() => setIsMenuOpen(false)}
            >
              {t('nav.home')}
            </Link>
            <Link
              to="/products"
              className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
              onClick={() => setIsMenuOpen(false)}
            >
              {t('nav.products')}
            </Link>
            {isAuthenticated && user?.role === 'ADMIN' && (
              <Link
                to="/admin"
                className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
                onClick={() => setIsMenuOpen(false)}
              >
                {t('nav.admin')}
              </Link>
            )}
            {isAuthenticated ? (
              <>
                <Link
                  to="/orders"
                  className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {t('nav.orders')}
                </Link>
                <button
                  onClick={() => {
                    handleLogout();
                    setIsMenuOpen(false);
                  }}
                  className="block w-full text-left px-3 py-2 text-red-600 hover:bg-gray-100 rounded"
                >
                  {t('nav.logout')}
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {t('nav.login')}
                </Link>
                <Link
                  to="/register"
                  className="block px-3 py-2 text-gray-700 hover:bg-gray-100 rounded"
                  onClick={() => setIsMenuOpen(false)}
                >
                  {t('nav.register')}
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
