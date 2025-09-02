import { create } from 'zustand';
import { api, setToken } from '../lib/api';

type AuthState = {
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
};

export const useAuth = create<AuthState>((set) => ({
  token: localStorage.getItem('token'),
  async login(email, password) {
    const data = await api<{accessToken:string}>('/api/auth/login', { method:'POST', auth:false, body:{ email, password } });
    setToken(data.accessToken);
    set({ token: data.accessToken });
  },
  logout() {
    setToken(null);
    set({ token: null });
  }
}));
