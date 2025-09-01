import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { CreditCard, Truck, Check } from 'lucide-react';
import { useCartStore } from '../store/useCartStore';
import api from '../lib/api';
import toast from 'react-hot-toast';
import CheckoutSteps from '../components/checkout/CheckoutSteps';

const checkoutSchema = z.object({
  shippingAddress: z.object({
    name: z.string().min(2),
    phone: z.string().min(10),
    line1: z.string().min(5),
    line2: z.string().optional(),
    city: z.string().min(2),
    region: z.string().min(2),
    postalCode: z.string().min(4),
    country: z.string().default('Morocco'),
  }),
  paymentMethod: z.enum(['card', 'cash']),
  notes: z.string().optional(),
});

type CheckoutForm = z.infer<typeof checkoutSchema>;

export default function CheckoutPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { cart, clearCart } = useCartStore();
  const [loading, setLoading] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CheckoutForm>({
    resolver: zodResolver(checkoutSchema),
    defaultValues: {
      shippingAddress: {
        country: 'Morocco',
      },
      paymentMethod: 'card',
    },
  });

  const onSubmit = async (data: CheckoutForm) => {
    try {
      setLoading(true);
      const response = await api.post('/api/orders/checkout', data);
      
      if (response.data.paymentUrl) {
        // Redirect to payment page
        window.location.href = response.data.paymentUrl;
      } else {
        // Order created successfully
        await clearCart();
        toast.success(t('checkout.orderSuccess'));
        navigate(`/orders/${response.data.orderNumber}`);
      }
    } catch (error) {
      console.error('Checkout failed:', error);
      toast.error(t('checkout.orderFailed'));
    } finally {
      setLoading(false);
    }
  };

  if (!cart || cart.items.length === 0) {
    navigate('/cart');
    return null;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">{t('common.checkout')}</h1>
      
      <CheckoutSteps currentStep={currentStep} />

      <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-8">
        <div className="lg:col-span-2 space-y-6">
          {/* Shipping Address */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
              <Truck size={24} />
              {t('checkout.shippingAddress')}
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('auth.name')} *
                </label>
                <input
                  {...register('shippingAddress.name')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.name && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.name.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('auth.phone')} *
                </label>
                <input
                  {...register('shippingAddress.phone')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.phone && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.phone.message}</p>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.addressLine1')} *
                </label>
                <input
                  {...register('shippingAddress.line1')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.line1 && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.line1.message}</p>
                )}
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.addressLine2')}
                </label>
                <input
                  {...register('shippingAddress.line2')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.city')} *
                </label>
                <input
                  {...register('shippingAddress.city')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.city && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.city.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.region')} *
                </label>
                <input
                  {...register('shippingAddress.region')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.region && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.region.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.postalCode')} *
                </label>
                <input
                  {...register('shippingAddress.postalCode')}
                  className="w-full px-3 py-2 border rounded-lg"
                />
                {errors.shippingAddress?.postalCode && (
                  <p className="text-red-500 text-sm mt-1">{errors.shippingAddress.postalCode.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">
                  {t('checkout.country')} *
                </label>
                <input
                  {...register('shippingAddress.country')}
                  className="w-full px-3 py-2 border rounded-lg"
                  readOnly
                />
              </div>
            </div>
          </div>

          {/* Payment Method */}
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
              <CreditCard size={24} />
              {t('checkout.paymentMethod')}
            </h2>
            
            <div className="space-y-3">
              <label className="flex items-center gap-3 p-3 border rounded-lg cursor-pointer hover:bg-gray-50">
                <input
                  type="radio"
                  value="card"
                  {...register('paymentMethod')}
                  className="text-honey"
                />
                <CreditCard size={20} />
                <span>{t('checkout.payByCard')}</span>
              </label>
              
              <label className="flex items-center gap-3 p-3 border rounded-lg cursor-pointer hover:bg-gray-50">
                <input
                  type="radio"
                  value="cash"
                  {...register('paymentMethod')}
                  className="text-honey"
                />
                <span>💵</span>
                <span>{t('checkout.cashOnDelivery')}</span>
              </label>
            </div>
          </div>

          {/* Notes */}
          <div className="bg-white rounded-lg shadow p-6">
            <label className="block text-sm font-medium mb-1">
              {t('checkout.orderNotes')}
            </label>
            <textarea
              {...register('notes')}
              rows={3}
              className="w-full px-3 py-2 border rounded-lg"
              placeholder={t('checkout.notesPlaceholder')}
            />
          </div>
        </div>

        {/* Order Summary */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow p-6 sticky top-4">
            <h2 className="text-xl font-semibold mb-4">{t('checkout.orderSummary')}</h2>
            
            <div className="space-y-3 mb-4">
              {cart.items.map((item) => (
                <div key={item.id} className="flex justify-between text-sm">
                  <span>{item.productName} x{item.quantity}</span>
                  <span>{item.totalPrice} {cart.currency}</span>
                </div>
              ))}
            </div>
            
            <hr className="my-4" />
            
            <div className="space-y-2">
              <div className="flex justify-between">
                <span>{t('common.subtotal')}</span>
                <span>{cart.subtotal} {cart.currency}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('common.shipping')}</span>
                <span>{cart.shippingCost} {cart.currency}</span>
              </div>
              <hr className="my-2" />
              <div className="flex justify-between font-bold text-lg">
                <span>{t('common.total')}</span>
                <span className="text-honey">{cart.total} {cart.currency}</span>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full btn btn-primary mt-6"
            >
              {loading ? t('common.processing') : t('checkout.placeOrder')}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
}
