import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useAuthStore } from "../stores/authStore"

// Layout
import Navbar from './components/layout/Navbar';
import Footer from './components/layout/Footer';

// Public Pages
import HomePage from './pages/HomePage';
import ProductListPage from './pages/ProductListPage';
import ProductDetailPage from './pages/ProductDetailPage';
import CartPage from './pages/CartPage';
import CheckoutPage from './pages/CheckoutPage';
import OrderHistoryPage from './pages/OrderHistoryPage';

// Auth Pages
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';

// Admin Pages
import DashboardPage from './pages/admin/DashboardPage';
import ProductsPage from './pages/admin/ProductsPage';

// Protected Route Component
function ProtectedRoute({ children, adminOnly = false }: { children: React.ReactNode; adminOnly?: boolean }) {
  const { isAuthenticated, user } = useAuthStore();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (adminOnly && user?.role !== 'ADMIN') {
    return <Navigate to="/" replace />;
  }
  
  return <>{children}</>;
}

export default function App() {
  return (
    <Router>
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <main className="flex-1">
          <Routes>
            {/* Public Routes */}
            <Route path="/" element={<HomePage />} />
            <Route path="/products" element={<ProductListPage />} />
            <Route path="/products/:slug" element={<ProductDetailPage />} />
            <Route path="/cart" element={<CartPage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            
            {/* Protected Routes */}
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
            
            {/* Admin Routes */}
            <Route path="/admin" element={
              <ProtectedRoute adminOnly>
                <DashboardPage />
              </ProtectedRoute>
            } />
            <Route path="/admin/products" element={
              <ProtectedRoute adminOnly>
                <ProductsPage />
              </ProtectedRoute>
            } />
          </Routes>
        </main>
        <Footer />
        <Toaster position="top-right" />
      </div>
    </Router>
  );
}
