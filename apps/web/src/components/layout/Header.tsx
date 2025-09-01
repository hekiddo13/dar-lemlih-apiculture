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
