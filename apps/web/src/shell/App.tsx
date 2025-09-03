import { Routes, Route, Navigate } from 'react-router-dom';
import React, { useEffect, useCallback } from 'react';
import AppHeader from '../components/layout/AppHeader';
import HomePage from '../pages/HomePage';
import ProductListPage from '../pages/ProductListPage';
import ProductDetailPage from '../pages/ProductDetailPage';
import CartPage from '../pages/CartPage';
import LoginPage from '../pages/auth/LoginPage';
import RegisterPage from '../pages/auth/RegisterPage';
import CheckoutPage from '../pages/CheckoutPage';
import OrderHistoryPage from '../pages/OrderHistoryPage';
import AdminDashboard from '../pages/admin/DashboardPage';
import AdminProducts from '../pages/admin/ProductsPage';
import { useAuthStore } from '../stores/authStore';

// Protected Route wrapper
function ProtectedRoute({ children, requireAdmin = false }: { children: React.ReactNode, requireAdmin?: boolean }) {
  const { isAuthenticated, user } = useAuthStore();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (requireAdmin && user?.role !== 'ADMIN') {
    return <Navigate to="/" replace />;
  }
  
  return <>{children}</>;
}

export default function App() {
  const { accessToken, fetchUser } = useAuthStore();
  
  const memoizedFetchUser = useCallback(() => {
    if (accessToken) {
      fetchUser();
    }
  }, [accessToken, fetchUser]);
  
  // Fetch user data on app load if token exists
  useEffect(() => {
    memoizedFetchUser();
  }, [memoizedFetchUser]);
  
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <AppHeader />
      <main className="flex-1">
        <Routes>
          {/* Public routes */}
          <Route path="/" element={<HomePage />} />
          <Route path="/products" element={<ProductListPage />} />
          <Route path="/products/:slug" element={<ProductDetailPage />} />
          <Route path="/cart" element={<CartPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          
          {/* Protected routes */}
          <Route path="/checkout" element={
            <ProtectedRoute>
              <CheckoutPage />
            </ProtectedRoute>
          } />
          <Route path="/orders" element={
            <ProtectedRoute>
              <OrderHistoryPage />
            </ProtectedRoute>
          } />
          
          {/* Admin routes */}
          <Route path="/admin" element={
            <ProtectedRoute requireAdmin>
              <AdminDashboard />
            </ProtectedRoute>
          } />
          <Route path="/admin/products" element={
            <ProtectedRoute requireAdmin>
              <AdminProducts />
            </ProtectedRoute>
          } />
          
          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}
