import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ShoppingCart, ChevronLeft, ChevronRight } from 'lucide-react';
import { api } from '../lib/api';
import { Product } from '../types';
import { useCartStore } from '../stores/cartStore';

export default function ProductDetailPage() {
  const { slug } = useParams<{ slug: string }>();
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const addItem = useCartStore(state => state.addItem);
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [selectedImage, setSelectedImage] = useState(0);

  const fetchProduct = useCallback(async () => {
    try {
      setLoading(true);
      const response = await api<Product>(`/api/products/${slug}`, { auth: false });
      setProduct(response);
    } catch (error) {
      console.error('Failed to fetch product:', error);
      navigate('/products');
    } finally {
      setLoading(false);
    }
  }, [slug, navigate]);

  useEffect(() => {
    fetchProduct();
  }, [fetchProduct]);

  const handleAddToCart = () => {
    if (product) {
      addItem(product, quantity);
      // You could add a toast notification here
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
