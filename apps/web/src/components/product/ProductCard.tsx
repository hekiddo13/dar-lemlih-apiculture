import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { ShoppingCart, Check } from 'lucide-react';
import { Product } from '../../types';
import { useCartStore } from '../../store/useCartStore';
import { useAuthStore } from '../../store/useAuthStore';
import toast from 'react-hot-toast';

interface ProductCardProps {
  product: Product;
}

export default function ProductCard({ product }: ProductCardProps) {
  const { t, i18n } = useTranslation();
  const { addToCart } = useCartStore();
  const { isAuthenticated } = useAuthStore();

  const getName = () => {
    switch (i18n.language) {
      case 'ar': return product.nameAr;
      case 'en': return product.nameEn;
      default: return product.nameFr;
    }
  };

  const getDescription = () => {
    switch (i18n.language) {
      case 'ar': return product.descriptionAr;
      case 'en': return product.descriptionEn;
      default: return product.descriptionFr;
    }
  };

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      toast.error('Please login to add items to cart');
      return;
    }
    await addToCart(product.id, 1);
  };

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300">
      <Link to={`/products/${product.slug}`}>
        <div className="aspect-w-1 aspect-h-1 w-full bg-gray-200">
          {product.images && product.images[0] ? (
            <img
              src={product.images[0]}
              alt={getName()}
              className="w-full h-48 object-cover"
            />
          ) : (
            <div className="w-full h-48 flex items-center justify-center bg-gray-100">
              <span className="text-6xl">🍯</span>
            </div>
          )}
        </div>
      </Link>

      <div className="p-4">
        <Link to={`/products/${product.slug}`}>
          <h3 className="font-semibold text-lg mb-2 hover:text-honey">{getName()}</h3>
        </Link>

        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
          {getDescription()}
        </p>

        <div className="flex items-center justify-between mb-3">
          <span className="text-2xl font-bold text-honey">
            {product.price} {product.currency}
          </span>
          {product.isHalal && (
            <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded">
              {t('products.halal')}
            </span>
          )}
        </div>

        <div className="flex items-center justify-between">
          {product.stockQuantity > 0 ? (
            <>
              <span className="text-sm text-green-600 flex items-center">
                <Check size={16} className="mr-1" />
                {t('products.inStock')}
              </span>
              <button
                onClick={handleAddToCart}
                className="btn btn-primary flex items-center space-x-1"
              >
                <ShoppingCart size={18} />
                <span>{t('common.addToCart')}</span>
              </button>
            </>
          ) : (
            <span className="text-sm text-red-600">{t('products.outOfStock')}</span>
          )}
        </div>
      </div>
    </div>
  );
}
