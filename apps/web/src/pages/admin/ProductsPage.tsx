import React, { useState, useEffect, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { Plus, Edit, Trash2, Search, X } from 'lucide-react';
import { api } from '../../lib/api';
import { Product } from '../../types';
import toast from 'react-hot-toast';

export default function ProductsPage() {
  const { t, i18n } = useTranslation();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [form, setForm] = useState<Partial<Product & { sku: string }>>({
    nameFr: '',
    nameEn: '',
    nameAr: '',
    descriptionFr: '',
    descriptionEn: '',
    descriptionAr: '',
    price: 0,
    currency: 'MAD',
    stockQuantity: 0,
    slug: '',
    sku: '',
    isActive: true,
    isFeatured: false,
  });

  const fetchProducts = useCallback(async () => {
    try {
      setLoading(true);
      const response = await api.get('/api/admin/products');
      setProducts(response.data.content || response.data);
    } catch (error) {
      console.error('Failed to fetch products:', error);
      toast.error(t('errors.fetchFailed'));
    } finally {
      setLoading(false);
    }
  }, [t]);

  useEffect(() => {
    fetchProducts();
  }, [fetchProducts]);

  const handleDelete = async (id: string) => {
    if (!window.confirm(t('admin.confirmDelete'))) return;
    
    try {
      await api.delete(`/api/admin/products/${id}`);
      toast.success(t('admin.deleteSuccess'));
      fetchProducts();
    } catch (error) {
      toast.error(t('errors.deleteFailed'));
    }
  };

  const handleEdit = (product: Product) => {
    setEditingProduct(product);
    setForm({ ...product, sku: product.sku || '' });
    setShowModal(true);
  };

  const getName = (product: Product) => {
    switch (i18n.language) {
      case 'ar': return product.nameAr;
      case 'en': return product.nameEn;
      default: return product.nameFr;
    }
  };

  const filteredProducts = products.filter(product =>
    getName(product).toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold">{t('admin.products')}</h1>
        <button
          onClick={() => {
            setEditingProduct(null);
            setForm({
              nameFr: '', nameEn: '', nameAr: '',
              descriptionFr: '', descriptionEn: '', descriptionAr: '',
              price: 0, currency: 'MAD', stockQuantity: 0,
              slug: '', sku: '', isActive: true, isFeatured: false,
            });
            setShowModal(true);
          }}
          className="btn btn-primary flex items-center gap-2"
        >
          <Plus size={20} />
          {t('admin.addProduct')}
        </button>
      </div>

      {/* Search Bar */}
      <div className="mb-6">
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder={t('admin.searchProducts')}
            className="w-full pl-10 pr-4 py-2 border rounded-lg"
          />
        </div>
      </div>

      {/* Products Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.image')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.name')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.category')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.price')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.stock')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                {t('admin.actions')}
              </th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {loading ? (
              <tr>
                <td colSpan={6} className="px-6 py-4 text-center">
                  {t('common.loading')}
                </td>
              </tr>
            ) : filteredProducts.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-6 py-4 text-center text-gray-500">
                  {t('admin.noProducts')}
                </td>
              </tr>
            ) : (
              filteredProducts.map((product) => (
                <tr key={product.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    {product.images?.[0] ? (
                      <img
                        src={product.images[0]}
                        alt={getName(product)}
                        className="w-12 h-12 object-cover rounded"
                      />
                    ) : (
                      <div className="w-12 h-12 bg-gray-200 rounded flex items-center justify-center">
                        🍯
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4 font-medium">{getName(product)}</td>
                  <td className="px-6 py-4 text-sm">{product.categoryName}</td>
                  <td className="px-6 py-4 text-sm">
                    {product.price} {product.currency}
                  </td>
                  <td className="px-6 py-4 text-sm">
                    <span className={`${
                      product.stockQuantity > 0 ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {product.stockQuantity}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleEdit(product)}
                        className="p-1 text-blue-600 hover:bg-blue-50 rounded"
                      >
                        <Edit size={18} />
                      </button>
                      <button
                        onClick={() => handleDelete(product.id)}
                        className="p-1 text-red-600 hover:bg-red-50 rounded"
                      >
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Create/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="bg-white rounded-lg shadow-lg w-full max-w-2xl">
            <div className="flex items-center justify-between px-6 py-4 border-b">
              <h3 className="text-lg font-semibold">
                {editingProduct ? t('admin.editProduct') : t('admin.addProduct')}
              </h3>
              <button onClick={() => setShowModal(false)} className="p-1 hover:bg-gray-100 rounded">
                <X size={18} />
              </button>
            </div>
            <form
              onSubmit={async (e) => {
                e.preventDefault();
                try {
                  const payload = {
                    ...form,
                  } as any;
                  if (editingProduct) {
                    // Optional: implement update later
                    toast.error(t('admin.updateNotImplemented'));
                    return;
                  }
                  await api.post('/api/admin/products', payload);
                  toast.success(t('admin.createSuccess'));
                  setShowModal(false);
                  fetchProducts();
                } catch (err) {
                  toast.error(t('errors.saveFailed'));
                }
              }}
            >
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 p-6">
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.sku')}</label>
                  <input
                    value={form.sku || ''}
                    onChange={(e) => setForm({ ...form, sku: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Slug</label>
                  <input
                    value={form.slug || ''}
                    onChange={(e) => setForm({ ...form, slug: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.nameFr')}</label>
                  <input
                    value={form.nameFr || ''}
                    onChange={(e) => setForm({ ...form, nameFr: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.nameEn')}</label>
                  <input
                    value={form.nameEn || ''}
                    onChange={(e) => setForm({ ...form, nameEn: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.nameAr')}</label>
                  <input
                    value={form.nameAr || ''}
                    onChange={(e) => setForm({ ...form, nameAr: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.price')}</label>
                  <input
                    type="number"
                    min={0}
                    step={0.01}
                    value={form.price ?? 0}
                    onChange={(e) => setForm({ ...form, price: Number(e.target.value) })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">{t('admin.stock')}</label>
                  <input
                    type="number"
                    min={0}
                    value={form.stockQuantity ?? 0}
                    onChange={(e) => setForm({ ...form, stockQuantity: Number(e.target.value) })}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div className="flex items-center gap-4 mt-2">
                  <label className="inline-flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={!!form.isActive}
                      onChange={(e) => setForm({ ...form, isActive: e.target.checked })}
                    />
                    <span>{t('admin.active')}</span>
                  </label>
                  <label className="inline-flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={!!form.isFeatured}
                      onChange={(e) => setForm({ ...form, isFeatured: e.target.checked })}
                    />
                    <span>{t('admin.featured')}</span>
                  </label>
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-1">{t('admin.descriptionFr')}</label>
                  <textarea
                    rows={3}
                    value={form.descriptionFr || ''}
                    onChange={(e) => setForm({ ...form, descriptionFr: e.target.value })}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
              </div>
              <div className="flex justify-end gap-3 px-6 py-4 border-t">
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>
                  {t('common.cancel')}
                </button>
                <button type="submit" className="btn btn-primary">
                  {editingProduct ? t('common.save') : t('common.create')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
