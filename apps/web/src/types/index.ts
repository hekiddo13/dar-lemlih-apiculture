export interface Product {
  id: string;
  slug: string;
  nameFr: string;
  nameEn: string;
  nameAr: string;
  descriptionFr: string;
  descriptionEn: string;
  descriptionAr: string;
  price: number;
  currency: string;
  images: string[];
  stockQuantity: number;
  categoryId: string;
  categoryName?: string;
  isHalal: boolean;
  origin?: string;
  ingredients?: string;
  weightGrams?: number;
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: string;
  nameFr: string;
  nameEn: string;
  nameAr: string;
  slug: string;
  description?: string;
}

export interface CartItem {
  id: string;
  productId: string;
  productName: string;
  productSlug: string;
  productImage?: string;
  price: number;
  quantity: number;
  totalPrice: number;
  stockQuantity: number;
}

export interface Cart {
  id: string;
  items: CartItem[];
  subtotal: number;
  shippingCost: number;
  total: number;
  currency: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  status: 'PENDING' | 'PROCESSING' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED';
  items: OrderItem[];
  subtotal: number;
  shippingCost: number;
  total: number;
  currency: string;
  shippingAddress: Address;
  paymentMethod: string;
  paymentStatus: string;
  customerName?: string;
  createdAt: string;
  updatedAt: string;
}

export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  price: number;
  quantity: number;
  totalPrice: number;
}

export interface Address {
  name: string;
  phone: string;
  line1: string;
  line2?: string;
  city: string;
  region: string;
  postalCode: string;
  country: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: 'USER' | 'ADMIN';
}
