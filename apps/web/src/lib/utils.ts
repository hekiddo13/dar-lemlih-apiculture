import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatPrice(price: number, currency = 'MAD'): string {
  return new Intl.NumberFormat('fr-MA', {
    style: 'currency',
    currency,
  }).format(price);
}

export function getLocalizedField<T extends Record<string, any>>(
  obj: T,
  field: string,
  lang: string
): string {
  const langSuffix = lang.charAt(0).toUpperCase() + lang.slice(1);
  const localizedField = `${field}${langSuffix}`;
  return obj[localizedField] || obj[`${field}Fr`] || obj[field] || '';
}
