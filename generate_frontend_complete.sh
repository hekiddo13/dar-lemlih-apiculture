#!/bin/bash

echo "🚀 Generating complete frontend pages and components for Dar Lemlih Apiculture..."

WEB_PATH="/Users/salimtagemouati/dar-lemlih-apiculture/apps/web/src"

# Create directories
mkdir -p "$WEB_PATH/pages/auth"
mkdir -p "$WEB_PATH/pages/admin"
mkdir -p "$WEB_PATH/components/common"
mkdir -p "$WEB_PATH/components/admin"
mkdir -p "$WEB_PATH/hooks"
mkdir -p "$WEB_PATH/utils"

# ========== PAGES ==========

# ProductListPage with filters
cat > "$WEB_PATH/pages/ProductListPage.tsx" << 'EOF'
import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Filter, Search } from 'lucide-react';
import api from '../lib/api';
import { Product, Category } from '../types';
import ProductGrid from '../components/product/ProductGrid';
import ProductFilter from '../components/product/ProductFilter';

export default function ProductListPage() {
  const { t, i18n } = useTranslation();
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [showFilters, setShowFilters] = useState(false);
  
  const [filters, setFilters] = useState({
    search: searchParams.get('search') || '',
    category: searchParams.get('category') || '',
    minPrice: searchParams.get('minPrice') || '',
    maxPrice: searchParams.get('maxPrice') || '',
    inStock: searchParams.get('inStock') === 'true',
  });

  useEffect(() => {
    fetchProducts();
    fetchCategories();
  }, [searchParams]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      if (filters.search) params.append('search', filters.search);
      if (filters.category) params.append('categoryId', filters.category);
      if (filters.minPrice) params.append('minPrice', filters.minPrice);
      if (filters.maxPrice) params.append('maxPrice', filters.maxPrice);
      
      const response = await api.get(`/api/products?${params}`);
      setProducts(response.data.content || response.data);
    } catch (error) {
      console.error('Failed to fetch products:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      const response = await api.get('/api/categories');
      setCategories(response.data);
    } catch (error) {
      console.error('Failed to fetch categories:', error);
    }
  };

  const handleFilterChange = (newFilters: typeof filters) => {
    setFilters(newFilters);
    const params = new URLSearchParams();
    Object.entries(newFilters).forEach(([key, value]) => {
      if (value) params.set(key, value.toString());
    });
    setSearchParams(params);
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold">{t('products.allProducts')}</h1>
        <button
          onClick={() => setShowFilters(!showFilters)}
          className="lg:hidden btn btn-secondary flex items-center gap-2"
        >
          <Filter size={20} />
          {t('products.filters')}
        </button>
      </div>

      <div className="flex gap-8">
        {/* Filters Sidebar */}
        <aside className={`${showFilters ? 'block' : 'hidden'} lg:block w-64 flex-shrink-0`}>
          <ProductFilter
            filters={filters}
            categories={categories}
            onFilterChange={handleFilterChange}
          />
        </aside>

        {/* Products Grid */}
        <main className="flex-1">
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="bg-gray-200 rounded-lg h-96 animate-pulse" />
              ))}
            </div>
          ) : products.length > 0 ? (
            <ProductGrid products={products} />
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">{t('products.noResults')}</p>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}
EOF

# ProductDetailPage
cat > "$WEB_PATH/pages/ProductDetailPage.tsx" << 'EOF'
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ShoppingCart, Heart, Share2, ChevronLeft, ChevronRight } from 'lucide-react';
import api from '../lib/api';
import { Product } from '../types';
import { useCartStore } from '../store/useCartStore';
import { useAuthStore } from '../store/useAuthStore';
import toast from 'react-hot-toast';

export default function ProductDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { addToCart } = useCartStore();
  const { isAuthenticated } = useAuthStore();
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [selectedImage, setSelectedImage] = useState(0);

  useEffect(() => {
    fetchProduct();
  }, [slug]);

  const fetchProduct = async () => {
    try {
      setLoading(true);
      const response = await api.get(`/api/products/${slug}`);
      setProduct(response.data);
    } catch (error) {
      console.error('Failed to fetch product:', error);
      toast.error(t('errors.productNotFound'));
      navigate('/products');
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      toast.error(t('auth.loginRequired'));
      navigate('/login');
      return;
    }
    if (product) {
      await addToCart(product.id, quantity);
    }
  };

  const getName = () => {
    if (!product) return '';
    switch (i18n.language) {
      case 'ar': return product.nameAr;
      case 'en': return product.nameEn;
      default: return product.nameFr;
    }
  };

  const getDescription = () => {
    if (!product) return '';
    switch (i18n.language) {
      case 'ar': return product.descriptionAr;
      case 'en': return product.descriptionEn;
      default: return product.descriptionFr;
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <div className="bg-gray-200 rounded-lg h-96 animate-pulse" />
          <div className="space-y-4">
            <div className="bg-gray-200 h-8 w-3/4 rounded animate-pulse" />
            <div className="bg-gray-200 h-4 w-full rounded animate-pulse" />
            <div className="bg-gray-200 h-4 w-5/6 rounded animate-pulse" />
          </div>
        </div>
      </div>
    );
  }

  if (!product) return null;

  return (
    <div className="container mx-auto px-4 py-8">
      <button
        onClick={() => navigate('/products')}
        className="mb-6 flex items-center text-gray-600 hover:text-gray-900"
      >
        <ChevronLeft size={20} />
        {t('common.back')}
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Images */}
        <div>
          <div className="relative aspect-square bg-gray-100 rounded-lg overflow-hidden mb-4">
            {product.images && product.images.length > 0 ? (
              <img
                src={product.images[selectedImage]}
                alt={getName()}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="flex items-center justify-center h-full">
                <span className="text-9xl">🍯</span>
              </div>
            )}
            
            {product.images && product.images.length > 1 && (
              <>
                <button
                  onClick={() => setSelectedImage((prev) => (prev - 1 + product.images.length) % product.images.length)}
                  className="absolute left-2 top-1/2 -translate-y-1/2 bg-white/80 p-2 rounded-full"
                >
                  <ChevronLeft size={20} />
                </button>
                <button
                  onClick={() => setSelectedImage((prev) => (prev + 1) % product.images.length)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 bg-white/80 p-2 rounded-full"
                >
                  <ChevronRight size={20} />
                </button>
              </>
            )}
          </div>

          {/* Thumbnails */}
          {product.images && product.images.length > 1 && (
            <div className="flex gap-2">
              {product.images.map((img, idx) => (
                <button
                  key={idx}
                  onClick={() => setSelectedImage(idx)}
                  className={`w-20 h-20 rounded-lg overflow-hidden border-2 ${
                    selectedImage === idx ? 'border-honey' : 'border-gray-200'
                  }`}
                >
                  <img src={img} alt="" className="w-full h-full object-cover" />
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Product Info */}
        <div>
          <h1 className="text-3xl font-bold mb-4">{getName()}</h1>
          
          <div className="flex items-center gap-4 mb-6">
            <span className="text-3xl font-bold text-honey">
              {product.price} {product.currency}
            </span>
            {product.isHalal && (
              <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm">
                {t('products.halal')}
              </span>
            )}
          </div>

          <p className="text-gray-600 mb-6">{getDescription()}</p>

          {/* Product Details */}
          <div className="space-y-3 mb-6">
            {product.weightGrams && (
              <div className="flex justify-between">
                <span className="text-gray-600">{t('products.weight')}:</span>
                <span>{product.weightGrams}g</span>
              </div>
            )}
            {product.origin && (
              <div className="flex justify-between">
                <span className="text-gray-600">{t('products.origin')}:</span>
                <span>{product.origin}</span>
              </div>
            )}
            {product.ingredients && (
              <div>
                <span className="text-gray-600">{t('products.ingredients')}:</span>
                <p className="mt-1">{product.ingredients}</p>
              </div>
            )}
          </div>

          {/* Add to Cart */}
          <div className="flex items-center gap-4 mb-6">
            <div className="flex items-center border rounded-lg">
              <button
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
                className="px-4 py-2 hover:bg-gray-100"
              >
                -
              </button>
              <span className="px-4 py-2 border-x">{quantity}</span>
              <button
                onClick={() => setQuantity(Math.min(product.stockQuantity, quantity + 1))}
                className="px-4 py-2 hover:bg-gray-100"
              >
                +
              </button>
            </div>
            
            <button
              onClick={handleAddToCart}
              disabled={product.stockQuantity === 0}
              className="flex-1 btn btn-primary flex items-center justify-center gap-2"
            >
              <ShoppingCart size={20} />
              {product.stockQuantity > 0 ? t('common.addToCart') : t('products.outOfStock')}
            </button>
          </div>

          {/* Stock Status */}
          <div className="flex items-center gap-4">
            {product.stockQuantity > 0 ? (
              <span className="text-green-600">
                ✓ {t('products.inStock')} ({product.stockQuantity} {t('products.available')})
              </span>
            ) : (
              <span className="text-red-600">{t('products.outOfStock')}</span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# CartPage
cat > "$WEB_PATH/pages/CartPage.tsx" << 'EOF'
import { useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Trash2, Plus, Minus, ShoppingBag } from 'lucide-react';
import { useCartStore } from '../store/useCartStore';
import { useAuthStore } from '../store/useAuthStore';

export default function CartPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { cart, fetchCart, updateQuantity, removeFromCart, loading } = useCartStore();
  const { isAuthenticated } = useAuthStore();

  useEffect(() => {
    if (isAuthenticated) {
      fetchCart();
    }
  }, [isAuthenticated]);

  const handleCheckout = () => {
    if (!isAuthenticated) {
      navigate('/login?redirect=/checkout');
    } else {
      navigate('/checkout');
    }
  };

  if (!isAuthenticated) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <ShoppingBag size={64} className="mx-auto mb-4 text-gray-400" />
        <h2 className="text-2xl font-bold mb-4">{t('cart.loginRequired')}</h2>
        <Link to="/login" className="btn btn-primary">
          {t('common.login')}
        </Link>
      </div>
    );
  }

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

  if (!cart || cart.items.length === 0) {
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

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">{t('common.cart')}</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="space-y-4">
            {cart.items.map((item) => (
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
                        {item.totalPrice} {cart.currency}
                      </span>
                      <button
                        onClick={() => removeFromCart(item.productId)}
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
                <span>{cart.subtotal} {cart.currency}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('common.shipping')}</span>
                <span>{cart.shippingCost} {cart.currency}</span>
              </div>
              <hr />
              <div className="flex justify-between font-bold text-lg">
                <span>{t('common.total')}</span>
                <span className="text-honey">{cart.total} {cart.currency}</span>
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
EOF

# CheckoutPage
cat > "$WEB_PATH/pages/CheckoutPage.tsx" << 'EOF'
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
EOF

# Auth Pages - Login
cat > "$WEB_PATH/pages/auth/LoginPage.tsx" << 'EOF'
import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Eye, EyeOff } from 'lucide-react';
import { useAuthStore } from '../../store/useAuthStore';
import toast from 'react-hot-toast';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

type LoginForm = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { login } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  
  const redirect = searchParams.get('redirect') || '/';

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginForm) => {
    try {
      setLoading(true);
      await login(data.email, data.password);
      toast.success(t('auth.loginSuccess'));
      navigate(redirect);
    } catch (error: any) {
      toast.error(error.response?.data?.message || t('auth.loginFailed'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[70vh] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <h1 className="text-2xl font-bold text-center mb-6">{t('common.login')}</h1>
          
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.email')}
              </label>
              <input
                type="email"
                {...register('email')}
                className="w-full px-3 py-2 border rounded-lg"
                placeholder="email@example.com"
              />
              {errors.email && (
                <p className="text-red-500 text-sm mt-1">{errors.email.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">
                {t('auth.password')}
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

            <div className="flex items-center justify-between">
              <Link
                to="/forgot-password"
                className="text-sm text-honey hover:underline"
              >
                {t('auth.forgotPassword')}
              </Link>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full btn btn-primary"
            >
              {loading ? t('common.loading') : t('common.login')}
            </button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-gray-600">
              {t('auth.noAccount')}{' '}
              <Link to="/register" className="text-honey hover:underline">
                {t('common.register')}
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
EOF

# Components
echo "Creating components..."

# ProductGrid Component
cat > "$WEB_PATH/components/product/ProductGrid.tsx" << 'EOF'
import { Product } from '../../types';
import ProductCard from './ProductCard';

interface ProductGridProps {
  products: Product[];
}

export default function ProductGrid({ products }: ProductGridProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {products.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}
EOF

# ProductFilter Component
cat > "$WEB_PATH/components/product/ProductFilter.tsx" << 'EOF'
import { useTranslation } from 'react-i18next';
import { Category } from '../../types';

interface FilterProps {
  filters: {
    search: string;
    category: string;
    minPrice: string;
    maxPrice: string;
    inStock: boolean;
  };
  categories: Category[];
  onFilterChange: (filters: any) => void;
}

export default function ProductFilter({ filters, categories, onFilterChange }: FilterProps) {
  const { t, i18n } = useTranslation();

  const getCategoryName = (category: Category) => {
    switch (i18n.language) {
      case 'ar': return category.nameAr;
      case 'en': return category.nameEn;
      default: return category.nameFr;
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="font-semibold mb-3">{t('products.search')}</h3>
        <input
          type="text"
          value={filters.search}
          onChange={(e) => onFilterChange({ ...filters, search: e.target.value })}
          placeholder={t('products.searchPlaceholder')}
          className="w-full px-3 py-2 border rounded-lg"
        />
      </div>

      <div>
        <h3 className="font-semibold mb-3">{t('products.category')}</h3>
        <select
          value={filters.category}
          onChange={(e) => onFilterChange({ ...filters, category: e.target.value })}
          className="w-full px-3 py-2 border rounded-lg"
        >
          <option value="">{t('products.allCategories')}</option>
          {categories.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {getCategoryName(cat)}
            </option>
          ))}
        </select>
      </div>

      <div>
        <h3 className="font-semibold mb-3">{t('products.priceRange')}</h3>
        <div className="flex gap-2">
          <input
            type="number"
            value={filters.minPrice}
            onChange={(e) => onFilterChange({ ...filters, minPrice: e.target.value })}
            placeholder={t('products.min')}
            className="w-full px-3 py-2 border rounded-lg"
          />
          <input
            type="number"
            value={filters.maxPrice}
            onChange={(e) => onFilterChange({ ...filters, maxPrice: e.target.value })}
            placeholder={t('products.max')}
            className="w-full px-3 py-2 border rounded-lg"
          />
        </div>
      </div>

      <div>
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            checked={filters.inStock}
            onChange={(e) => onFilterChange({ ...filters, inStock: e.target.checked })}
            className="rounded"
          />
          <span>{t('products.inStockOnly')}</span>
        </label>
      </div>
    </div>
  );
}
EOF

# CheckoutSteps Component
cat > "$WEB_PATH/components/checkout/CheckoutSteps.tsx" << 'EOF'
import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';

interface CheckoutStepsProps {
  currentStep: number;
}

export default function CheckoutSteps({ currentStep }: CheckoutStepsProps) {
  const { t } = useTranslation();
  
  const steps = [
    { id: 1, name: t('checkout.step1') },
    { id: 2, name: t('checkout.step2') },
    { id: 3, name: t('checkout.step3') },
  ];

  return (
    <div className="flex items-center justify-center mb-8">
      {steps.map((step, index) => (
        <div key={step.id} className="flex items-center">
          <div
            className={`
              w-10 h-10 rounded-full flex items-center justify-center
              ${currentStep > step.id ? 'bg-green-500 text-white' : 
                currentStep === step.id ? 'bg-honey text-white' : 
                'bg-gray-200 text-gray-600'}
            `}
          >
            {currentStep > step.id ? <Check size={20} /> : step.id}
          </div>
          <span className="ml-2 text-sm font-medium">{step.name}</span>
          {index < steps.length - 1 && (
            <div className={`w-20 h-1 mx-4 ${currentStep > step.id ? 'bg-green-500' : 'bg-gray-200'}`} />
          )}
        </div>
      ))}
    </div>
  );
}
EOF

# Update i18n translations
echo "Updating translations..."

# Add more translations to existing files
cat >> "$WEB_PATH/i18n/locales/fr.json" << 'EOF'
{
  "products": {
    "allProducts": "Tous les produits",
    "filters": "Filtres",
    "noResults": "Aucun produit trouvé",
    "search": "Rechercher",
    "searchPlaceholder": "Rechercher un produit...",
    "category": "Catégorie",
    "allCategories": "Toutes les catégories",
    "priceRange": "Gamme de prix",
    "min": "Min",
    "max": "Max",
    "inStockOnly": "En stock uniquement",
    "available": "disponibles"
  },
  "cart": {
    "empty": "Votre panier est vide",
    "loginRequired": "Connectez-vous pour voir votre panier",
    "summary": "Résumé de la commande"
  },
  "checkout": {
    "shippingAddress": "Adresse de livraison",
    "addressLine1": "Adresse ligne 1",
    "addressLine2": "Adresse ligne 2",
    "city": "Ville",
    "region": "Région",
    "postalCode": "Code postal",
    "country": "Pays",
    "paymentMethod": "Méthode de paiement",
    "payByCard": "Payer par carte",
    "cashOnDelivery": "Paiement à la livraison",
    "orderNotes": "Notes de commande",
    "notesPlaceholder": "Instructions spéciales pour votre commande",
    "orderSummary": "Résumé de la commande",
    "placeOrder": "Passer la commande",
    "orderSuccess": "Commande passée avec succès!",
    "orderFailed": "Échec de la commande",
    "step1": "Livraison",
    "step2": "Paiement",
    "step3": "Confirmation"
  },
  "auth": {
    "loginSuccess": "Connexion réussie",
    "loginFailed": "Échec de la connexion"
  },
  "common": {
    "loading": "Chargement...",
    "processing": "Traitement...",
    "back": "Retour"
  },
  "errors": {
    "productNotFound": "Produit introuvable"
  }
}
EOF

echo "✅ Frontend pages and components generation complete!"
echo "Created:"
echo "  - ProductListPage with filters"
echo "  - ProductDetailPage with image gallery"
echo "  - CartPage with quantity management"
echo "  - CheckoutPage with form validation"
echo "  - LoginPage with authentication"
echo "  - ProductGrid, ProductFilter, CheckoutSteps components"
echo "  - Updated i18n translations"
