import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { 
  ShoppingCart, 
  Package, 
  Users, 
  DollarSign,
  TrendingUp,
  TrendingDown,
  Calendar
} from 'lucide-react';
import { api } from '../../lib/api';
import { format } from 'date-fns';

export default function DashboardPage() {
  const { t } = useTranslation();
  const [stats, setStats] = useState<any>({});
  const [recentOrders, setRecentOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const [statsRes, ordersRes] = await Promise.all([
        api.get('/api/admin/stats'),
        api.get('/api/admin/orders?limit=5')
      ]);
      setStats(statsRes.data);
      setRecentOrders(ordersRes.data.content || ordersRes.data);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const StatCard = ({ icon: Icon, title, value, change, color }: any) => (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-gray-600 text-sm">{title}</p>
          <p className="text-2xl font-bold mt-1">{value}</p>
          {change && (
            <div className="flex items-center gap-1 mt-2">
              {change > 0 ? (
                <TrendingUp size={16} className="text-green-500" />
              ) : (
                <TrendingDown size={16} className="text-red-500" />
              )}
              <span className={`text-sm ${change > 0 ? 'text-green-500' : 'text-red-500'}`}>
                {Math.abs(change)}%
              </span>
            </div>
          )}
        </div>
        <div className={`p-3 rounded-full ${color}`}>
          <Icon size={24} className="text-white" />
        </div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="bg-gray-200 h-32 rounded-lg animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold">{t('admin.dashboard')}</h1>
        <div className="flex items-center gap-2 text-gray-600">
          <Calendar size={20} />
          <span>{format(new Date(), 'PPP')}</span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          icon={DollarSign}
          title={t('admin.totalRevenue')}
          value={`${stats.totalRevenue || 0} MAD`}
          change={stats.revenueChange}
          color="bg-green-500"
        />
        <StatCard
          icon={ShoppingCart}
          title={t('admin.totalOrders')}
          value={stats.totalOrders || 0}
          change={stats.ordersChange}
          color="bg-blue-500"
        />
        <StatCard
          icon={Package}
          title={t('admin.totalProducts')}
          value={stats.totalProducts || 0}
          color="bg-purple-500"
        />
        <StatCard
          icon={Users}
          title={t('admin.totalCustomers')}
          value={stats.totalCustomers || 0}
          change={stats.customersChange}
          color="bg-orange-500"
        />
      </div>

      {/* Recent Orders */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-semibold">{t('admin.recentOrders')}</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  {t('orders.orderNumber')}
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  {t('orders.customer')}
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  {t('orders.date')}
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  {t('orders.status')}
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                  {t('orders.total')}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {recentOrders.map((order) => (
                <tr key={order.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 text-sm">{order.orderNumber}</td>
                  <td className="px-6 py-4 text-sm">{order.customerName}</td>
                  <td className="px-6 py-4 text-sm">
                    {format(new Date(order.createdAt), 'PP')}
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800">
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm font-medium">
                    {order.total} {order.currency}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
