import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { api, setToken } from '../lib/api';
import { User } from '../types/user';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
  
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  fetchUser: () => Promise<void>;
  clearError: () => void;
}

interface RegisterData {
  name: string;
  email: string;
  password: string;
  phone?: string;
}

interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isAuthenticated: false,
      loading: false,
      error: null,

      login: async (email: string, password: string) => {
        set({ loading: true, error: null });
        try {
          const response = await api<LoginResponse>('/api/auth/login', {
            method: 'POST',
            auth: false,
            body: { email, password },
          });
          
          setToken(response.accessToken);
          set({
            user: response.user,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            isAuthenticated: true,
            loading: false,
          });
          
          // Store refresh token
          if (response.refreshToken) {
            localStorage.setItem('refreshToken', response.refreshToken);
          }
        } catch (error: any) {
          set({
            error: error.message || 'Login failed',
            loading: false,
          });
          throw error;
        }
      },

      register: async (data: RegisterData) => {
        set({ loading: true, error: null });
        try {
          await api('/api/auth/register', {
            method: 'POST',
            auth: false,
            body: data,
          });
          
          // Auto-login after registration
          await get().login(data.email, data.password);
        } catch (error: any) {
          set({
            error: error.message || 'Registration failed',
            loading: false,
          });
          throw error;
        }
      },

      logout: () => {
        setToken(null);
        localStorage.removeItem('refreshToken');
        set({
          user: null,
          accessToken: null,
          refreshToken: null,
          isAuthenticated: false,
          error: null,
        });
      },

      fetchUser: async () => {
        const token = get().accessToken;
        if (!token) return;
        
        set({ loading: true });
        try {
          const user = await api<User>('/api/auth/me');
          set({ user, isAuthenticated: true, loading: false });
        } catch (error) {
          set({ isAuthenticated: false, loading: false });
          get().logout();
        }
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
