import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { ShoppingCart, Eye } from 'lucide-react';
import { api } from '../lib/api';
import { Product } from '../types';
import { useCartStore } from '../stores/cartStore';
import { formatPrice, getLocalizedField } from '../lib/utils';
import Loader from '../components/ui/Loader';
import Error from '../components/ui/Error';
import Button from '../components/ui/Button';
import { Card, CardContent } from '../components/ui/Card';

interface ProductsResponse {
  content: Product[];
  totalElements: number;
  totalPages: number;
  number: number;
}

export default function ProductListPage() {
  const { t, i18n } = useTranslation();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const addItem = useCartStore(state => state.addItem);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api<ProductsResponse | Product[]>('/api/products', { auth: false });
      
      // Handle both paginated and non-paginated responses
      if ('content' in response) {
        setProducts(response.content);
      } else if (Array.isArray(response)) {
        setProducts(response);
      } else {
        setProducts([]);
      }
    } catch (err: any) {
      // Fallback demo products for MVP when backend is unavailable
      const demo: Product[] = [
        {
          id: 'p1',
          slug: 'forest-honey',
          nameFr: 'Miel de Forêt',
          nameEn: 'Forest Honey',
          nameAr: 'عسل الغابة',
          descriptionFr: 'Miel artisanal 100% naturel',
          descriptionEn: '100% natural artisanal honey',
          descriptionAr: 'عسل طبيعي 100%',
          price: 120,
          currency: 'MAD',
          images: [],
          stockQuantity: 25,
          categoryId: 'c1',
          categoryName: 'Miels',
          isHalal: true,
          isActive: true,
          isFeatured: true,
          origin: 'Atlas, Maroc',
          ingredients: 'Miel pur',
          weightGrams: 500,
        },
        {
          id: 'p2',
          slug: 'pollen-grains',
          nameFr: 'Grains de Pollen',
          nameEn: 'Bee Pollen',
          nameAr: 'حبوب اللقاح',
          price: 90,
          currency: 'MAD',
          images: [],
          stockQuantity: 40,
          isHalal: true,
          isActive: true,
          origin: 'Maroc',
          ingredients: 'Pollen',
          weightGrams: 250,
        },
      ];
      setProducts(demo);
      setError(null);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = (product: Product) => {
    addItem(product);
    // You could add a toast notification here
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <Loader size="lg" className="h-64" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto px-4 py-8">
        <Error message={error} retry={fetchProducts} />
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">{t('products.allProducts')}</h1>
      
      {products.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-500">{t('products.noProducts')}</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {products.map(product => (
            <Card key={product.id} className="hover:shadow-lg transition-shadow">
              <Link to={`/products/${product.slug}`}>
                <div className="aspect-square relative overflow-hidden bg-gray-100">
                  {product.images && product.images[0] ? (
                    <img
                      src={product.images[0]}
                      alt={getLocalizedField(product, 'name', i18n.language)}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <span className="text-6xl">🍯</span>
                    </div>
                  )}
                  {product.isFeatured && (
                    <span className="absolute top-2 right-2 bg-orange-500 text-white px-2 py-1 text-xs rounded">
                      {t('products.featured')}
                    </span>
                  )}
                </div>
              </Link>
              
              <CardContent className="p-4">
                <Link to={`/products/${product.slug}`}>
                  <h3 className="font-semibold mb-2 hover:text-orange-600 transition-colors">
                    {getLocalizedField(product, 'name', i18n.language)}
                  </h3>
                </Link>
                
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xl font-bold text-orange-600">
                    {formatPrice(product.price, product.currency)}
                  </span>
                  {product.stockQuantity > 0 ? (
                    <span className="text-sm text-green-600">
                      {t('products.inStock')}
                    </span>
                  ) : (
                    <span className="text-sm text-red-600">
                      {t('products.outOfStock')}
                    </span>
                  )}
                </div>
                
                <div className="flex gap-2">
                  <Button
                    onClick={() => handleAddToCart(product)}
                    disabled={product.stockQuantity === 0}
                    size="sm"
                    className="flex-1"
                  >
                    <ShoppingCart className="h-4 w-4 mr-1" />
                    {t('common.addToCart')}
                  </Button>
                  <Link to={`/products/${product.slug}`}>
                    <Button variant="outline" size="sm">
                      <Eye className="h-4 w-4" />
                    </Button>
                  </Link>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
