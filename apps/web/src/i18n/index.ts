import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Default translations
const defaultTranslations = {
  home: 'Accueil',
  products: 'Produits',
  cart: 'Panier',
  login: 'Connexion',
  register: 'S\'inscrire',
  welcome: 'Bienvenue',
  search: 'Rechercher',
  addToCart: 'Ajouter au panier',
  checkout: 'Commander',
  total: 'Total',
  subtotal: 'Sous-total',
  shipping: 'Livraison',
  orderHistory: 'Mes commandes',
  logout: 'Déconnexion',
  email: 'Email',
  password: 'Mot de passe',
  name: 'Nom',
  phone: 'Téléphone'
};

const resources = {
  fr: { translation: defaultTranslations },
  en: { translation: { ...defaultTranslations, home: 'Home', products: 'Products', cart: 'Cart', login: 'Login', register: 'Register' } },
  ar: { translation: { ...defaultTranslations, home: 'الرئيسية', products: 'المنتجات', cart: 'السلة' } },
};

// Initialize i18n synchronously with defaults
i18n.use(initReactI18next).init({
  resources,
  lng: localStorage.getItem('lang') || 'fr',
  fallbackLng: 'fr',
  interpolation: { escapeValue: false },
});

// Load actual translations asynchronously
Promise.all([
  import('../locales/fr/common.json').catch(() => null),
  import('../locales/en/common.json').catch(() => null),
  import('../locales/ar/common.json').catch(() => null)
]).then(([frData, enData, arData]) => {
  if (frData) i18n.addResourceBundle('fr', 'translation', frData, true, true);
  if (enData) i18n.addResourceBundle('en', 'translation', enData, true, true);
  if (arData) i18n.addResourceBundle('ar', 'translation', arData, true, true);
});

// set lang + dir on <html>
const html = document.documentElement;
const setLangDir = (lng: string) => {
  html.setAttribute('lang', lng);
  html.setAttribute('dir', lng === 'ar' ? 'rtl' : 'ltr');
};
setLangDir(i18n.language);
i18n.on('languageChanged', (lng) => {
  localStorage.setItem('lang', lng);
  setLangDir(lng);
});

export default i18n;
