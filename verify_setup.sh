#!/bin/bash

echo "🔍 Verifying Dar Lemlih Apiculture E-Commerce Platform Setup"
echo "============================================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Check directories
echo ""
echo "📁 Checking directory structure:"
[ -d "apps/api" ] && check 0 "Backend API directory exists" || check 1 "Backend API directory missing"
[ -d "apps/web" ] && check 0 "Frontend Web directory exists" || check 1 "Frontend Web directory missing"
[ -d "infra/docker" ] && check 0 "Docker infrastructure exists" || check 1 "Docker infrastructure missing"

# Check backend files
echo ""
echo "☕ Checking Spring Boot backend:"
[ -f "apps/api/pom.xml" ] && check 0 "Maven configuration (pom.xml)" || check 1 "Maven configuration missing"
[ -f "apps/api/src/main/resources/application.yml" ] && check 0 "Application configuration" || check 1 "Application configuration missing"
[ -d "apps/api/src/main/java/com/darlemlih/apiculture/entities" ] && check 0 "Entity classes" || check 1 "Entity classes missing"
[ -d "apps/api/src/main/java/com/darlemlih/apiculture/controllers" ] && check 0 "Controllers" || check 1 "Controllers missing"
[ -d "apps/api/src/main/java/com/darlemlih/apiculture/services" ] && check 0 "Services" || check 1 "Services missing"
[ -d "apps/api/src/main/java/com/darlemlih/apiculture/security" ] && check 0 "Security components" || check 1 "Security components missing"
[ -d "apps/api/src/main/java/com/darlemlih/apiculture/payments" ] && check 0 "Payment gateway" || check 1 "Payment gateway missing"
[ -f "apps/api/src/main/resources/db/migration/V1__initial_schema.sql" ] && check 0 "Database migrations" || check 1 "Database migrations missing"

# Check frontend files
echo ""
echo "⚛️ Checking React frontend:"
[ -f "apps/web/package.json" ] && check 0 "Package.json configuration" || check 1 "Package.json missing"
[ -f "apps/web/tailwind.config.js" ] && check 0 "Tailwind CSS configuration" || check 1 "Tailwind configuration missing"
[ -f "apps/web/src/App.tsx" ] && check 0 "Main App component" || check 1 "Main App component missing"
[ -d "apps/web/src/components" ] && check 0 "Components directory" || check 1 "Components directory missing"
[ -d "apps/web/src/pages" ] && check 0 "Pages directory" || check 1 "Pages directory missing"
[ -d "apps/web/src/store" ] && check 0 "State management (Zustand)" || check 1 "State management missing"
[ -d "apps/web/src/i18n" ] && check 0 "Internationalization setup" || check 1 "i18n setup missing"
[ -f "apps/web/src/lib/api.ts" ] && check 0 "API client" || check 1 "API client missing"

# Check Docker files
echo ""
echo "🐳 Checking Docker configuration:"
[ -f "infra/docker/docker-compose.yml" ] && check 0 "Docker Compose configuration" || check 1 "Docker Compose missing"
[ -f "infra/docker/Dockerfile.api" ] && check 0 "API Dockerfile" || check 1 "API Dockerfile missing"
[ -f "infra/docker/Dockerfile.web" ] && check 0 "Web Dockerfile" || check 1 "Web Dockerfile missing"

# Check utilities
echo ""
echo "🛠️ Checking utilities:"
[ -f "Makefile" ] && check 0 "Makefile with dev commands" || check 1 "Makefile missing"
[ -f ".env.example" ] || [ -f "apps/api/.env.example" ] && check 0 "Environment examples" || check 1 "Environment examples missing"

# Check key backend components
echo ""
echo "🔑 Checking key backend components:"
if [ -f "apps/api/src/main/java/com/darlemlih/apiculture/controllers/AuthController.java" ]; then
    check 0 "JWT Authentication Controller"
else
    check 1 "JWT Authentication Controller missing"
fi

if [ -f "apps/api/src/main/java/com/darlemlih/apiculture/controllers/ProductController.java" ]; then
    check 0 "Product Controller"
else
    check 1 "Product Controller missing"
fi

if [ -f "apps/api/src/main/java/com/darlemlih/apiculture/controllers/CartController.java" ]; then
    check 0 "Cart Controller"
else
    check 1 "Cart Controller missing"
fi

if [ -f "apps/api/src/main/java/com/darlemlih/apiculture/controllers/OrderController.java" ]; then
    check 0 "Order Controller"
else
    check 1 "Order Controller missing"
fi

# Check frontend components
echo ""
echo "🎨 Checking key frontend components:"
if [ -f "apps/web/src/components/layout/Header.tsx" ]; then
    check 0 "Header component with language switcher"
else
    check 1 "Header component missing"
fi

if [ -f "apps/web/src/components/product/ProductCard.tsx" ]; then
    check 0 "Product Card component"
else
    check 1 "Product Card component missing"
fi

if [ -f "apps/web/src/pages/HomePage.tsx" ]; then
    check 0 "Homepage with featured products"
else
    check 1 "Homepage missing"
fi

# Check i18n translations
echo ""
echo "🌍 Checking translations:"
[ -f "apps/web/src/i18n/locales/fr.json" ] && check 0 "French translations" || check 1 "French translations missing"
[ -f "apps/web/src/i18n/locales/en.json" ] && check 0 "English translations" || check 1 "English translations missing"
[ -f "apps/web/src/i18n/locales/ar.json" ] && check 0 "Arabic translations (RTL)" || check 1 "Arabic translations missing"

# Summary
echo ""
echo "============================================================"
echo -e "${GREEN}✅ Setup verification complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "  1. Copy environment files:"
echo "     ${YELLOW}cp apps/api/.env.example apps/api/.env${NC}"
echo "     ${YELLOW}cp apps/web/.env.example apps/web/.env${NC}"
echo ""
echo "  2. Start with Docker:"
echo "     ${YELLOW}make dev${NC}"
echo "     OR"
echo "     ${YELLOW}docker-compose -f infra/docker/docker-compose.yml up -d${NC}"
echo ""
echo "  3. Access services:"
echo "     • Frontend:    http://localhost:5173"
echo "     • Backend API: http://localhost:8080"
echo "     • Swagger UI:  http://localhost:8080/swagger-ui.html"
echo "     • phpMyAdmin:  http://localhost:8090"
echo "     • MailHog:     http://localhost:8025"
echo ""
echo "  4. Default credentials:"
echo "     • Admin:    admin@darlemlih.ma / Admin!234"
echo "     • Customer: customer@darlemlih.ma / Customer!234"
echo ""
echo "============================================================"
