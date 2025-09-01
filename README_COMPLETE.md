# 🍯 Dar Lemlih Apiculture - Production-Ready E-Commerce Platform

A **production-ready multilingual e-commerce platform** for terroir products (honey, pollen, etc.) built with modern technologies and best practices.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)
![React](https://img.shields.io/badge/React-18.2-61DAFB.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)

## 🌟 Features

### Core Features
- 🌐 **Multilingual Support** (French, English, Arabic with RTL)
- 🔐 **JWT Authentication** with access/refresh tokens
- 💳 **Payment Gateway Abstraction** (Mock, Stripe-ready)
- 🛒 **Full E-Commerce Flow** (Cart, Checkout, Orders)
- 📱 **Responsive Design** with Tailwind CSS
- 🎨 **Admin Dashboard** for management
- 📧 **Email Notifications** with templates
- 🐳 **Docker-Ready** for easy deployment
- 🔄 **Hot Reload** in development

### Technical Highlights
- **Backend**: Spring Boot 3, Java 21, MySQL, Flyway
- **Frontend**: React 18, Vite, TypeScript, Tailwind CSS
- **State Management**: Zustand with persistence
- **i18n**: react-i18next with RTL support
- **API Documentation**: OpenAPI 3.0 / Swagger
- **Security**: JWT, BCrypt, CORS, Rate Limiting

## 📁 Project Structure

```
dar-lemlih-apiculture/
├── apps/
│   ├── api/                    # Spring Boot Backend
│   │   ├── src/main/java/      # Java source code
│   │   ├── src/main/resources/ # Resources & migrations
│   │   └── pom.xml             # Maven configuration
│   └── web/                    # React Frontend
│       ├── src/                # TypeScript/React source
│       ├── public/             # Static assets
│       └── package.json        # NPM configuration
├── infra/
│   ├── docker/                 # Docker configurations
│   │   ├── docker-compose.yml  # Multi-container setup
│   │   ├── Dockerfile.api      # API container
│   │   └── Dockerfile.web      # Web container
│   └── ci/                     # CI/CD pipelines
├── Makefile                    # Development commands
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

- **Docker & Docker Compose** (recommended)
- **Java 21** (for local development)
- **Node.js 20+** (for local development)
- **MySQL 8** (or use Docker)

### 🐳 Option 1: Docker Setup (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/your-org/dar-lemlih-apiculture.git
cd dar-lemlih-apiculture

# 2. Copy environment files
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env

# 3. Start all services with Docker Compose
make dev

# OR directly with docker-compose:
docker-compose -f infra/docker/docker-compose.yml up -d

# 4. Wait for services to be ready (check logs)
docker-compose -f infra/docker/docker-compose.yml logs -f

# 5. Services are now available at:
# - Frontend: http://localhost:5173
# - Backend API: http://localhost:8080
# - Swagger UI: http://localhost:8080/swagger-ui.html
# - phpMyAdmin: http://localhost:8090
# - MailHog: http://localhost:8025
```

### 💻 Option 2: Local Development Setup

#### Backend Setup

```bash
# 1. Navigate to API directory
cd apps/api

# 2. Install dependencies
./mvnw clean install

# 3. Start MySQL (if not using Docker)
mysql.server start

# 4. Create database
mysql -u root -p -e "CREATE DATABASE darlemlih;"

# 5. Copy and configure environment
cp .env.example .env
# Edit .env with your database credentials

# 6. Run the application
./mvnw spring-boot:run

# API will be available at http://localhost:8080
```

#### Frontend Setup

```bash
# 1. Navigate to web directory
cd apps/web

# 2. Install dependencies
npm install

# 3. Copy and configure environment
cp .env.example .env

# 4. Start development server
npm run dev

# Frontend will be available at http://localhost:5173
```

## 🔧 Environment Variables

### Backend (.env)

```env
# Database
DB_URL=jdbc:mysql://localhost:3306/darlemlih
DB_USER=dar
DB_PASSWORD=lemlih

# JWT
JWT_SECRET=your_secret_key_min_256_bits
JWT_ACCESS_TTL_MIN=15
JWT_REFRESH_TTL_DAYS=7

# Payment Provider
PAYMENT_PROVIDER=mock  # Options: mock, stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Email (using MailHog in dev)
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=

# URLs
APP_BASE_URL=http://localhost:8080
WEB_BASE_URL=http://localhost:5173
```

### Frontend (.env)

```env
VITE_API_URL=http://localhost:8080
VITE_APP_DEFAULT_LANG=fr
VITE_APP_SUPPORTED_LANGS=fr,en,ar
VITE_PAYMENT_PROVIDER=mock
```

## 📦 Database Setup

The database is automatically initialized with Flyway migrations. Seed data includes:

- **3 Categories**: Miels, Pollen, Produits de la Ruche
- **5 Products**: Various honey types and pollen
- **2 Users**: 
  - Admin: `admin@darlemlih.ma` / `Admin!234`
  - Customer: `customer@darlemlih.ma` / `Customer!234`
- **1 Sample Order**: Paid order with 2 items

### Manual Seed (if needed)

```bash
# Using API endpoint
curl -X POST http://localhost:8080/api/admin/seed

# OR using Make command
make seed
```

## 🛠️ Development Commands

```bash
# Show all available commands
make help

# Start development environment
make dev

# Build Docker images
make build

# View logs
make logs
make logs-api  # API logs only
make logs-web  # Frontend logs only

# Stop services
make down

# Clean up (remove volumes)
make clean

# Run tests
make test
make test-api  # Backend tests only
make test-web  # Frontend tests only

# Format code
make format

# Lint code
make lint
```

## 📚 API Documentation

### Interactive Documentation
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

### Key Endpoints

#### Authentication
```bash
# Register
POST /api/auth/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+212600000000"
}

# Login
POST /api/auth/login
{
  "email": "john@example.com",
  "password": "password123"
}

# Refresh Token
POST /api/auth/refresh?refreshToken={token}
```

#### Products
```bash
# Get all products (with pagination)
GET /api/products?page=0&size=20&search=honey&categoryId=1&minPrice=50&maxPrice=200

# Get product by slug
GET /api/products/miel-oranger-500g

# Get featured products
GET /api/products/featured
```

#### Cart
```bash
# Get cart (requires auth)
GET /api/cart
Authorization: Bearer {token}

# Add to cart
POST /api/cart/add
{
  "productId": 1,
  "quantity": 2
}

# Update quantity
PUT /api/cart/update
{
  "productId": 1,
  "quantity": 3
}

# Remove from cart
DELETE /api/cart/remove/1
```

#### Orders
```bash
# Checkout
POST /api/orders/checkout
{
  "shippingAddress": {
    "name": "John Doe",
    "phone": "+212600000000",
    "line1": "123 Main St",
    "city": "Casablanca",
    "region": "Casablanca-Settat",
    "postalCode": "20000",
    "country": "Morocco"
  },
  "paymentMethod": "card"
}

# Get user orders
GET /api/orders

# Get order details
GET /api/orders/ORD-2025-000001
```

## 🌍 Internationalization

The platform supports three languages with automatic RTL for Arabic:

```javascript
// Change language programmatically
i18n.changeLanguage('ar'); // Switch to Arabic
i18n.changeLanguage('en'); // Switch to English
i18n.changeLanguage('fr'); // Switch to French
```

Translation files are located in:
- `apps/web/src/i18n/locales/fr.json`
- `apps/web/src/i18n/locales/en.json`
- `apps/web/src/i18n/locales/ar.json`

## 💳 Payment Integration

### Mock Payment Gateway (Default)
The platform includes a mock payment gateway for testing:

```java
// Configure in .env
PAYMENT_PROVIDER=mock
```

### Stripe Integration
To enable Stripe:

1. Set environment variables:
```env
PAYMENT_PROVIDER=stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

2. Configure webhook endpoint:
```
https://yourdomain.com/api/payments/webhook
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>

# Or change the port in .env
SERVER_PORT=8081
```

#### 2. Database Connection Failed
```bash
# Check MySQL is running
docker ps | grep mysql

# Check credentials in .env
DB_USER=dar
DB_PASSWORD=lemlih

# Test connection
mysql -u dar -plemlih -h localhost darlemlih
```

#### 3. Frontend Can't Connect to API
```bash
# Check CORS settings in application.yml
# Ensure VITE_API_URL matches backend URL
VITE_API_URL=http://localhost:8080

# Check backend is running
curl http://localhost:8080/actuator/health
```

#### 4. Docker Build Fails
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache

# Check Docker resources
docker system df
```

#### 5. npm install Fails
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

## 🧪 Testing

### Backend Tests
```bash
cd apps/api
./mvnw test

# Run specific test class
./mvnw test -Dtest=AuthControllerTest

# Run with coverage
./mvnw test jacoco:report
```

### Frontend Tests
```bash
cd apps/web
npm test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

### E2E Tests (Coming Soon)
```bash
npm run test:e2e
```

## 📈 Performance Optimization

### Backend
- Connection pooling with HikariCP
- Query optimization with indexes
- Caching with Spring Cache
- Async processing for emails

### Frontend
- Code splitting with React.lazy
- Image optimization
- Bundle size optimization
- PWA support (coming soon)

## 🔒 Security

- **JWT** with short-lived access tokens (15 min)
- **BCrypt** password hashing (12 rounds)
- **CORS** configured for specific origins
- **Rate limiting** on auth endpoints
- **Input validation** with Bean Validation
- **SQL injection** prevention with JPA
- **XSS protection** with React
- **HTTPS** ready with SSL/TLS

## 🚢 Production Deployment

### Docker Production Build
```bash
# Build production images
docker build -f infra/docker/Dockerfile.api -t darlemlih-api:latest apps/api
docker build -f infra/docker/Dockerfile.web -t darlemlih-web:latest apps/web

# Push to registry
docker tag darlemlih-api:latest your-registry/darlemlih-api:latest
docker push your-registry/darlemlih-api:latest
```

### Environment-Specific Configs
```bash
# Production
SPRING_PROFILES_ACTIVE=prod
NODE_ENV=production

# Staging
SPRING_PROFILES_ACTIVE=staging
NODE_ENV=staging
```

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support, email support@darlemlih.ma or open an issue in the GitHub repository.

## 🙏 Acknowledgments

- Spring Boot team for the amazing framework
- React team for the powerful UI library
- Vite for the blazing fast build tool
- Tailwind CSS for the utility-first CSS framework
- All contributors who have helped this project grow

---

**Built with ❤️ by the Dar Lemlih Apiculture Team**
