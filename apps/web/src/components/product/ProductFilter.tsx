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
