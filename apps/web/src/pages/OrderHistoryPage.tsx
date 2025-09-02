import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Package, Calendar, CreditCard, ChevronRight } from 'lucide-react';
import { api } from '../lib/api';
import { Order } from '../types';
import { format } from 'date-fns';

export default function OrderHistoryPage() {
  const { t } = useTranslation();
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const response = await api.get('/api/orders/my-orders');
      setOrders(response.data);
    } catch (error) {
      console.error('Failed to fetch orders:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'PENDING': return 'bg-yellow-100 text-yellow-800';
      case 'PROCESSING': return 'bg-blue-100 text-blue-800';
      case 'SHIPPED': return 'bg-purple-100 text-purple-800';
      case 'DELIVERED': return 'bg-green-100 text-green-800';
      case 'CANCELLED': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="bg-gray-200 h-32 rounded-lg" />
          ))}
        </div>
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <Package size={64} className="mx-auto mb-4 text-gray-400" />
        <h2 className="text-2xl font-bold mb-4">{t('orders.noOrders')}</h2>
        <Link to="/products" className="btn btn-primary">
          {t('common.startShopping')}
        </Link>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">{t('orders.myOrders')}</h1>

      <div className="space-y-4">
        {orders.map((order) => (
          <div key={order.id} className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-semibold text-lg">
                  {t('orders.orderNumber')}: {order.orderNumber}
                </h3>
                <div className="flex items-center gap-4 text-sm text-gray-600 mt-1">
                  <span className="flex items-center gap-1">
                    <Calendar size={14} />
                    {format(new Date(order.createdAt), 'PPP')}
                  </span>
                  <span className="flex items-center gap-1">
                    <CreditCard size={14} />
                    {order.paymentMethod}
                  </span>
                </div>
              </div>
              
              <div className="text-right">
                <span className={`px-3 py-1 rounded-full text-sm ${getStatusColor(order.status)}`}>
                  {t(`orders.status.${order.status}`)}
                </span>
                <p className="mt-2 font-semibold">
                  {order.total} {order.currency}
                </p>
              </div>
            </div>

            <div className="border-t pt-4">
              <div className="flex items-center justify-between">
                <div className="space-y-1">
                  {order.items.slice(0, 2).map((item) => (
                    <p key={item.id} className="text-sm text-gray-600">
                      {item.productName} x{item.quantity}
                    </p>
                  ))}
                  {order.items.length > 2 && (
                    <p className="text-sm text-gray-500">
                      +{order.items.length - 2} {t('orders.moreItems')}
                    </p>
                  )}
                </div>
                
                <Link
                  to={`/orders/${order.orderNumber}`}
                  className="flex items-center gap-1 text-honey hover:underline"
                >
                  {t('orders.viewDetails')}
                  <ChevronRight size={16} />
                </Link>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
