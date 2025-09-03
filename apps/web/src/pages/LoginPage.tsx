import { useState, FormEvent } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useAuthStore } from '../stores/authStore';
import Button from '../components/ui/Button';
import { Card, CardContent, CardHeader } from '../components/ui/Card';

export default function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const { login, loading, error, clearError } = useAuthStore();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  // Get redirect path from location state or default to home
  const from = location.state?.from?.pathname || '/';

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    clearError();
    
    try {
      await login(email, password);
      navigate(from, { replace: true });
    } catch (err) {
      // Error is handled in the store
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4 py-12">
      <Card className="w-full max-w-md">
        <CardHeader>
          <h2 className="text-2xl font-bold text-center">{t('auth.loginTitle')}</h2>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {t('auth.email')}
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="admin@darlemlih.ma"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {t('auth.password')}
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                placeholder="Admin!234"
              />
            </div>
            
            {error && (
              <div className="bg-red-50 text-red-600 p-3 rounded-lg text-sm">
                {error}
              </div>
            )}
            
            <Button
              type="submit"
              loading={loading}
              disabled={loading}
              className="w-full"
            >
              {t('auth.loginButton')}
            </Button>
            
            <p className="text-center text-sm text-gray-600">
              {t('auth.noAccount')}{' '}
              <Link to="/register" className="text-orange-600 hover:underline">
                {t('auth.registerButton')}
              </Link>
            </p>
            
            {/* Demo credentials hint */}
            <div className="mt-4 p-3 bg-blue-50 rounded-lg text-sm">
              <p className="font-semibold text-blue-900">Demo Credentials:</p>
              <p className="text-blue-700">Admin: admin@darlemlih.ma / Admin!234</p>
              <p className="text-blue-700">Customer: customer@darlemlih.ma / Customer!234</p>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
