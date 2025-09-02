# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Dar Lemlih Apiculture is a production-ready multilingual e-commerce platform for terroir products (honey, pollen, etc.) with secure authentication, payment processing, and admin back-office.

## Tech Stack

- **Frontend**: React.js with Vite, TypeScript, Tailwind CSS
- **Backend**: Spring Boot 3, Java 21  
- **Database**: MySQL 8
- **Authentication**: JWT (access/refresh tokens)
- **Payments**: Provider-agnostic with Stripe-like abstractions
- **I18n**: French, Arabic, English with RTL support
- **Containerization**: Docker & Docker Compose

## Project Structure

```
/
├── apps/
│   ├── api/          # Spring Boot backend
│   └── web/          # React frontend
├── infra/
│   ├── docker/       # Docker configurations
│   └── ci/           # CI/CD pipelines
└── Makefile          # Development automation
```

## Common Development Commands

### Quick Start with Make (Recommended)
```bash
# Start complete development environment
make dev

# View all available commands
make help

# Run tests for both frontend and backend
make test

# Run only backend tests
make test-api

# Run only frontend tests
make test-web

# Format code
make format

# Lint frontend code
make lint

# Seed database with demo data
make seed

# View logs
make logs        # All services
make logs-api    # Backend only
make logs-web    # Frontend only

# Clean up Docker resources
make clean
```

### Backend Development (Spring Boot)
```bash
# Run backend locally (without Docker)
cd apps/api
./mvnw spring-boot:run

# Run backend tests
cd apps/api
./mvnw test

# Run a single test class
cd apps/api
./mvnw test -Dtest=CartControllerTest

# Build backend
cd apps/api
./mvnw clean package

# Format Java code
cd apps/api
./mvnw spotless:apply
```

### Frontend Development (React)
```bash
# Install dependencies
cd apps/web
npm install

# Run development server
cd apps/web
npm run dev

# Build for production
cd apps/web
npm run build

# Run linting
cd apps/web
npm run lint

# Format code (if configured)
cd apps/web
npm run format
```

### Docker Commands
```bash
# Start all services with Docker Compose
docker-compose -f infra/docker/docker-compose.yml up -d

# Rebuild images
docker-compose -f infra/docker/docker-compose.yml build

# Stop all services
docker-compose -f infra/docker/docker-compose.yml down

# View logs
docker-compose -f infra/docker/docker-compose.yml logs -f [service_name]
```

## Service URLs

When running with `make dev` or Docker Compose:

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **phpMyAdmin**: http://localhost:8090
- **MailHog** (email testing): http://localhost:8025

## Default Credentials

- **Admin**: admin@darlemlih.ma / Admin!234
- **Customer**: customer@darlemlih.ma / Customer!234
- **phpMyAdmin**: dar / lemlih

## High-Level Architecture

### Backend Architecture (Spring Boot)

The backend follows a layered architecture pattern:

1. **Controllers** (`/controllers`): REST API endpoints, request/response handling
   - `AuthController`: Authentication endpoints (login, register, refresh)
   - `ProductController`: Product CRUD and search
   - `CartController`: Shopping cart management
   - `OrderController`: Order processing and history
   - `AdminController`: Admin dashboard and management

2. **Services** (`/services`): Business logic layer
   - `AuthService`: JWT token management, user authentication
   - `CartService`: Cart operations with session management
   - `OrderService`: Order processing, payment integration
   - `ProductService`: Product management and search

3. **Repositories** (`/repositories`): Data access layer using Spring Data JPA
   - Extends `JpaRepository` for CRUD operations
   - Custom query methods for complex searches

4. **Entities** (`/entities`): JPA entities mapping to database tables
   - `User`, `Product`, `Cart`, `Order`, `Category`, etc.
   - Relationships configured with JPA annotations

5. **DTOs** (`/dto`): Data Transfer Objects for API communication
   - Organized by feature (auth, cart, order, product)
   - Input validation with Jakarta Bean Validation

6. **Security Configuration**:
   - JWT-based authentication with access/refresh tokens
   - Role-based access control (CUSTOMER, ADMIN)
   - CORS configuration for frontend integration

### Frontend Architecture (React + TypeScript)

The frontend uses modern React patterns with TypeScript:

1. **State Management** (`/store`): Zustand stores for global state
   - `useAuthStore`: Authentication state and user session
   - `useCartStore`: Shopping cart state management

2. **Components** (`/components`): Reusable UI components
   - `/layout`: Header, Footer, Navigation
   - `/product`: ProductCard, ProductGrid, ProductFilter
   - `/cart`: CartItem, CartSummary
   - `/checkout`: CheckoutSteps, AddressForm
   - `/common`: Shared components

3. **Pages** (`/pages`): Route-level components
   - Public: HomePage, ProductListPage, ProductDetailPage
   - Auth: LoginPage, RegisterPage
   - Protected: CheckoutPage, OrderHistoryPage
   - Admin: DashboardPage, ProductsPage

4. **API Integration** (`/lib/api.ts`):
   - Axios instance with interceptors
   - Automatic token refresh on 401
   - Request/response interceptors for auth

5. **Internationalization** (`/i18n`):
   - Support for French (default), English, Arabic
   - RTL support for Arabic
   - Language detection and persistence

6. **Routing**: React Router v6 with protected routes
   - Public routes accessible to all
   - Protected routes require authentication
   - Admin routes require ADMIN role

## Key Technical Patterns

### Authentication Flow
1. User logs in with email/password
2. Backend validates credentials and returns JWT tokens
3. Access token (15min) stored in memory/localStorage
4. Refresh token (7 days) used to renew access token
5. Automatic token refresh on 401 responses

### Shopping Cart Management
- Guest carts stored in session (frontend)
- Authenticated carts persisted in database
- Cart merge on login
- Real-time stock validation

### Payment Processing
- Provider-agnostic design with adapter pattern
- Mock provider for development
- Ready for Stripe/CheckoutCom integration
- Webhook handling for payment confirmations

### Multi-language Support
- i18next for translation management
- Language stored in localStorage
- Dynamic RTL switching for Arabic
- All product data stored in three languages

## Database Schema

Key tables and relationships:
- `users` → `orders` (one-to-many)
- `users` → `cart` (one-to-one)
- `cart` → `cart_items` → `products` (many-to-many)
- `orders` → `order_items` → `products` (many-to-many)
- `categories` → `products` (one-to-many)

## Environment Variables

### Backend (.env)
- `DB_URL`: MySQL connection string
- `JWT_SECRET`: Secret for JWT signing (min 256 bits)
- `PAYMENT_PROVIDER`: Payment gateway (mock|stripe|checkoutcom)
- `SMTP_HOST`, `SMTP_PORT`: Email configuration

### Frontend (.env)
- `VITE_API_URL`: Backend API URL
- `VITE_APP_DEFAULT_LANG`: Default language (fr|en|ar)
- `VITE_PAYMENT_PROVIDER`: Payment provider

## Testing Strategy

### Backend Testing
- Unit tests for services and utilities
- Integration tests for controllers
- Repository tests with @DataJpaTest
- Testcontainers for database testing

### Frontend Testing
- Component testing with React Testing Library
- API mocking with MSW
- E2E testing with Playwright (if configured)

## Deployment Considerations

1. Use environment-specific configurations
2. Enable HTTPS in production
3. Configure proper CORS origins
4. Set strong JWT secrets
5. Enable rate limiting on auth endpoints
6. Configure CDN for static assets
7. Set up monitoring and logging
8. Database backups and migration strategy

## Common Issues and Solutions

### Issue: Cannot connect to database
- Ensure MySQL is running on port 3306
- Check database credentials in .env
- Wait for database health check in Docker

### Issue: CORS errors in browser
- Check CORS configuration in Spring Security
- Ensure frontend URL is whitelisted
- Verify API_URL in frontend .env

### Issue: Authentication not working
- Check JWT secret configuration
- Verify token expiration times
- Clear localStorage and retry

### Issue: Arabic text not displaying correctly
- Ensure RTL support is enabled
- Check font loading for Arabic
- Verify i18n configuration
