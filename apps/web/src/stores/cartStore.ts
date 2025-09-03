import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { CartItem, Product } from '../types';

interface CartState {
  items: CartItem[];
  isOpen: boolean;
  
  addItem: (product: Product, quantity?: number) => void;
  updateQuantity: (productId: string | number, quantity: number) => void;
  removeItem: (productId: string | number) => void;
  clearCart: () => void;
  toggleCart: () => void;
  getTotalPrice: () => number;
  getTotalItems: () => number;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      isOpen: false,

      addItem: (product: Product, quantity = 1) => {
        const currentItems = get().items;
        const existingItem = currentItems.find(
          item => item.productId === product.id
        );

        if (existingItem) {
          // Update quantity if item exists
          set({
            items: currentItems.map(item =>
              item.productId === product.id
                ? {
                    ...item,
                    quantity: Math.min(
                      item.quantity + quantity,
                      product.stockQuantity
                    ),
                    totalPrice: item.price * (item.quantity + quantity),
                  }
                : item
            ),
          });
        } else {
          // Add new item
          const newItem: CartItem = {
            id: `cart-${product.id}-${Date.now()}`,
            productId: product.id,
            productName: product.nameFr || product.nameEn || '',
            productSlug: product.slug,
            productImage: product.images?.[0],
            price: product.price,
            quantity: Math.min(quantity, product.stockQuantity),
            totalPrice: product.price * quantity,
            stockQuantity: product.stockQuantity,
          };
          set({ items: [...currentItems, newItem] });
        }
      },

      updateQuantity: (productId: string | number, quantity: number) => {
        if (quantity <= 0) {
          get().removeItem(productId);
          return;
        }

        set({
          items: get().items.map(item =>
            item.productId === productId
              ? {
                  ...item,
                  quantity: Math.min(quantity, item.stockQuantity),
                  totalPrice: item.price * Math.min(quantity, item.stockQuantity),
                }
              : item
          ),
        });
      },

      removeItem: (productId: string | number) => {
        set({
          items: get().items.filter(item => item.productId !== productId),
        });
      },

      clearCart: () => {
        set({ items: [] });
      },

      toggleCart: () => {
        set({ isOpen: !get().isOpen });
      },

      getTotalPrice: () => {
        return get().items.reduce((total, item) => total + item.totalPrice, 0);
      },

      getTotalItems: () => {
        return get().items.reduce((total, item) => total + item.quantity, 0);
      },
    }),
    {
      name: 'cart-storage',
      partialize: (state) => ({ items: state.items }),
    }
  )
);
