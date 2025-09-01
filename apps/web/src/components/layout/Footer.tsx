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
