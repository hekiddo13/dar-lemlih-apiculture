import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';
import { ArrowRight, Truck, Shield, Award } from 'lucide-react';
import { useEffect, useState } from 'react';
import api from '../lib/api';
import { Product, Category } from '../types';
import ProductCard from '../components/product/ProductCard';

export default function HomePage() {
  const { t } = useTranslation();
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [productsRes, categoriesRes] = await Promise.all([
        api.get('/api/products/featured?size=4'),
        api.get('/api/categories')
      ]);
      setFeaturedProducts(productsRes.data.content);
      setCategories(categoriesRes.data);
    } catch (error) {
      console.error('Failed to fetch data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-honey-light to-honey-dark text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-5xl font-bold mb-6">
              {t('common.welcome')}
            </h1>
            <p className="text-xl mb-8">
              Discover the finest honey and bee products from Morocco's most pristine regions.
            </p>
            <Link to="/products" className="btn bg-white text-honey hover:bg-gray-100 inline-flex items-center">
              Shop Now <ArrowRight className="ml-2" size={20} />
            </Link>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-12 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <Truck className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">Free Shipping</h3>
              <p className="text-gray-600">On orders over 300 MAD</p>
            </div>
            <div className="text-center">
              <Shield className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">100% Natural</h3>
              <p className="text-gray-600">Pure, raw, and unprocessed</p>
            </div>
            <div className="text-center">
              <Award className="mx-auto mb-4 text-honey" size={48} />
              <h3 className="font-semibold mb-2">Premium Quality</h3>
              <p className="text-gray-600">Award-winning bee products</p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Products */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            {t('products.featured')}
          </h2>
          
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {[1,2,3,4].map(i => (
                <div key={i} className="bg-gray-200 rounded-lg h-96 animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {featuredProducts.map(product => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Categories */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">Shop by Category</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {categories.map(category => (
              <Link
                key={category.id}
                to={`/products?category=${category.slug}`}
                className="group relative overflow-hidden rounded-lg shadow-lg hover:shadow-xl transition-shadow"
              >
                <div className="aspect-w-16 aspect-h-9 bg-gray-200">
                  {category.image ? (
                    <img src={category.image} alt={category.nameFr} className="w-full h-64 object-cover" />
                  ) : (
                    <div className="w-full h-64 flex items-center justify-center bg-gradient-to-br from-honey-light to-honey">
                      <span className="text-8xl">🍯</span>
                    </div>
                  )}
                </div>
                <div className="absolute inset-0 bg-black bg-opacity-40 group-hover:bg-opacity-50 transition-colors flex items-center justify-center">
                  <h3 className="text-white text-2xl font-bold">{category.nameFr}</h3>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
