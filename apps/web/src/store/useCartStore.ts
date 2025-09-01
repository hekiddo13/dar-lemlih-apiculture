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
