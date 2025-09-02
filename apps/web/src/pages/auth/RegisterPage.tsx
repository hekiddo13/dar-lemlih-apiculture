import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Eye, EyeOff } from 'lucide-react';
import { api } from '../../lib/api';
import toast from 'react-hot-toast';

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
  confirmPassword: z.string(),
  phone: z.string().optional(),
  acceptTerms: z.boolean().refine(val => val === true, {
    message: 'You must accept the terms and conditions',
  }),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"],
});

type RegisterForm = z.infer<typeof registerSchema>;

export default function RegisterPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterForm>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterForm) => {
    try {
      setLoading(true);
      await api.post('/api/auth/register', {
        name: data.name,
        email: data.email,
        password: data.password,
        phone: data.phone,
      });
      toast.success(t('auth.registerSuccess'));
      navigate('/login');
    } catch (error: any) {
      toast.error(error.response?.data?.message || t('auth.registerFailed'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h1 className="text-2xl font-bold text-center mb-6">{t('common.register')}</h1>
          
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.name')} *
              </label>
              <input
                {...register('name')}
                className="w-full px-3 py-2 border rounded-lg"
              />
              {errors.name && (
                <p className="text-red-500 text-sm mt-1">{errors.name.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.email')} *
              </label>
              <input
                type="email"
                {...register('email')}
                className="w-full px-3 py-2 border rounded-lg"
              />
              {errors.email && (
                <p className="text-red-500 text-sm mt-1">{errors.email.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.phone')}
              </label>
              <input
                {...register('phone')}
                className="w-full px-3 py-2 border rounded-lg"
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.password')} *
              </label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  {...register('password')}
                  className="w-full px-3 py-2 border rounded-lg pr-10"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-2 top-1/2 -translate-y-1/2"
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              </div>
              {errors.password && (
                <p className="text-red-500 text-sm mt-1">{errors.password.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.confirmPassword')} *
              </label>
              <input
                type="password"
                {...register('confirmPassword')}
                className="w-full px-3 py-2 border rounded-lg"
              />
              {errors.confirmPassword && (
                <p className="text-red-500 text-sm mt-1">{errors.confirmPassword.message}</p>
              )}
            </div>

            <div>
              <label className="flex items-center gap-2">
                <input
                  type="checkbox"
                  {...register('acceptTerms')}
                  className="rounded"
                />
                <span className="text-sm">
                  {t('auth.acceptTerms')}{' '}
                  <Link to="/terms" className="text-honey hover:underline">
                    {t('auth.termsAndConditions')}
                  </Link>
                </span>
              </label>
              {errors.acceptTerms && (
                <p className="text-red-500 text-sm mt-1">{errors.acceptTerms.message}</p>
              )}
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full btn btn-primary"
            >
              {loading ? t('common.loading') : t('common.register')}
            </button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-gray-600">
              {t('auth.haveAccount')}{' '}
              <Link to="/login" className="text-honey hover:underline">
                {t('common.login')}
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
