import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import fr from '../locales/fr/common.json';
import en from '../locales/en/common.json';
import ar from '../locales/ar/common.json';

const resources = {
  fr: { translation: fr },
  en: { translation: en },
  ar: { translation: ar },
};

i18n.use(initReactI18next).init({
  resources,
  lng: localStorage.getItem('lang') || 'fr',
  fallbackLng: 'fr',
  interpolation: { escapeValue: false },
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
