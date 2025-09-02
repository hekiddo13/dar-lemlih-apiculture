import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Trash2, Plus, Minus, ShoppingBag } from 'lucide-react';
import { useCartStore } from "../stores/cartStore";

export default function CartPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { items, updateQuantity, removeItem, getTotalPrice } = useCartStore();

  const handleCheckout = () => {
    if (items.length === 0) return;
    navigate('/checkout');
  };

  if (items.length === 0) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <ShoppingBag size={64} className="mx-auto mb-4 text-gray-400" />
        <h2 className="text-2xl font-bold mb-4">{t('cart.empty')}</h2>
        <Link to="/products" className="btn btn-primary">
          {t('common.continueShopping')}
        </Link>
      </div>
    );
  }

  const subtotal = getTotalPrice();
  const shippingCost = items.length > 0 ? 20 : 0; // Flat demo shipping
  const total = subtotal + shippingCost;
  const currency = 'MAD';

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">{t('common.cart')}</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="space-y-4">
            {items.map((item) => (
              <div key={item.id} className="bg-white rounded-lg shadow p-4 flex gap-4">
                <img
                  src={item.productImage || '/placeholder.jpg'}
                  alt={item.productName}
                  className="w-24 h-24 object-cover rounded"
                />
                
                <div className="flex-1">
                  <Link
                    to={`/products/${item.productSlug}`}
                    className="font-semibold hover:text-honey"
                  >
                    {item.productName}
                  </Link>
                  
                  <div className="flex items-center justify-between mt-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => updateQuantity(item.productId, Math.max(1, item.quantity - 1))}
                        className="p-1 rounded hover:bg-gray-100"
                      >
                        <Minus size={16} />
                      </button>
                      <span className="px-3 py-1 border rounded">{item.quantity}</span>
                      <button
                        onClick={() => updateQuantity(item.productId, Math.min(item.stockQuantity, item.quantity + 1))}
                        className="p-1 rounded hover:bg-gray-100"
                      >
                        <Plus size={16} />
                      </button>
                    </div>
                    
                    <div className="flex items-center gap-4">
                      <span className="font-semibold">
                        {item.totalPrice} {currency}
                      </span>
                      <button
                        onClick={() => removeItem(item.productId)}
                        className="text-red-500 hover:text-red-700"
                      >
                        <Trash2 size={20} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Order Summary */}
        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow p-6 sticky top-4">
            <h2 className="text-xl font-semibold mb-4">{t('cart.summary')}</h2>
            
            <div className="space-y-2 mb-4">
              <div className="flex justify-between">
                <span>{t('common.subtotal')}</span>
                <span>{subtotal} {currency}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('common.shipping')}</span>
                <span>{shippingCost} {currency}</span>
              </div>
              <hr />
              <div className="flex justify-between font-bold text-lg">
                <span>{t('common.total')}</span>
                <span className="text-honey">{total} {currency}</span>
              </div>
            </div>

            <button
              onClick={handleCheckout}
              className="w-full btn btn-primary"
            >
              {t('common.checkout')}
            </button>
            
            <Link
              to="/products"
              className="block text-center mt-4 text-gray-600 hover:text-honey"
            >
              {t('common.continueShopping')}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
