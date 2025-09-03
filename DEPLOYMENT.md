# Dar Lemlih Apiculture - Deployment Guide

## Current Status

✅ **Backend**: Running on port 8080 with health checks
✅ **Database**: MySQL 8 running with migrations applied
✅ **Frontend**: Built successfully, served on port 5173
✅ **Data**: Products and categories seeded in database
✅ **Infrastructure**: Docker Compose stack operational

⚠️ **Known Issue**: Authentication login endpoint returning 500 error (needs investigation)

## Quick Start Deployment

### Option A: Local Docker Compose (Fastest)

This is the fastest way to get the application running locally with all dependencies.

```bash
# 1. Clone the repository
git clone https://github.com/your-org/dar-lemlih-apiculture.git
cd dar-lemlih-apiculture

# 2. Start all services with Docker Compose
make dev
# OR directly with docker-compose:
docker-compose -f infra/docker/docker-compose.yml up -d

# 3. Wait for services to be healthy (about 30 seconds)
sleep 30

# 4. Reset passwords for default users
curl -X POST http://localhost:8080/api/admin/reset-passwords

# 5. Access the applications
```

**Service URLs:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui.html
- phpMyAdmin: http://localhost:8090 (user: dar, password: lemlih)
- MailHog: http://localhost:8025

**Default Credentials:**
- Admin: admin@darlemlih.ma / Admin!234
- Customer: customer@darlemlih.ma / Customer!234

### Option B: Cloud Deployment (Production)

#### Backend Deployment (Render/Railway)

1. **Prepare for deployment:**
```bash
cd apps/api

# Create a production profile
cat > src/main/resources/application-prod.yml <<EOF
spring:
  datasource:
    url: \${DATABASE_URL}
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: validate
  flyway:
    enabled: true
    baseline-on-migrate: true

jwt:
  secret: \${JWT_SECRET}
  
app:
  cors:
    allowed-origins: 
      - \${FRONTEND_URL}
      - https://your-domain.com
EOF
```

2. **Deploy to Render:**
   - Create a new Web Service on Render
   - Connect your GitHub repository
   - Build Command: `cd apps/api && ./mvnw clean package`
   - Start Command: `java -jar apps/api/target/apiculture-api-1.0.0.jar --spring.profiles.active=prod`
   - Environment Variables:
     ```
     DATABASE_URL=mysql://user:pass@host:3306/database
     JWT_SECRET=your-super-secret-key-min-256-bits
     FRONTEND_URL=https://your-frontend.vercel.app
     SPRING_PROFILES_ACTIVE=prod
     ```

3. **Database Setup (PlanetScale/Railway MySQL):**
   - Create a MySQL 8.0 database
   - Run migrations manually or let Flyway handle them
   - Ensure connection uses SSL

#### Frontend Deployment (Vercel/Netlify)

1. **Prepare for deployment:**
```bash
cd apps/web

# Update environment variables
cat > .env.production <<EOF
VITE_API_URL=https://your-backend.render.com
VITE_APP_DEFAULT_LANG=fr
VITE_APP_SUPPORTED_LANGS=fr,en,ar
EOF
```

2. **Deploy to Vercel:**
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

3. **Deploy to Netlify (Alternative):**
```bash
# Build the app
npm run build

# Create netlify.toml
cat > netlify.toml <<EOF
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
EOF

# Deploy with Netlify CLI
netlify deploy --prod
```

## Production Configuration

### Environment Variables

#### Backend (.env.production)
```bash
# Database
DATABASE_URL=mysql://user:password@host:3306/database?useSSL=true
DB_USER=production_user
DB_PASSWORD=secure_password

# JWT
JWT_SECRET=your-production-secret-min-256-bits
JWT_ACCESS_TTL_MIN=15
JWT_REFRESH_TTL_DAYS=7

# Payment
PAYMENT_PROVIDER=stripe
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Email
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-api-key

# Application
APP_BASE_URL=https://api.darlemlih.ma
WEB_BASE_URL=https://darlemlih.ma
CORS_ALLOWED_ORIGINS=https://darlemlih.ma,https://www.darlemlih.ma
```

#### Frontend (.env.production)
```bash
VITE_API_URL=https://api.darlemlih.ma
VITE_APP_DEFAULT_LANG=fr
VITE_APP_SUPPORTED_LANGS=fr,en,ar
VITE_PAYMENT_PROVIDER=stripe
VITE_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
```

### Docker Compose Production

For production Docker deployment, use the following configuration:

```yaml
# docker-compose.prod.yml
version: '3.9'

services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - internal
    restart: unless-stopped

  api:
    image: darlemlih/api:latest
    environment:
      SPRING_PROFILES_ACTIVE: prod
      DATABASE_URL: ${DATABASE_URL}
      JWT_SECRET: ${JWT_SECRET}
      # ... other env vars
    depends_on:
      - db
    networks:
      - internal
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`api.darlemlih.ma`)"
      - "traefik.http.routers.api.tls.certresolver=letsencrypt"
    restart: unless-stopped

  web:
    image: darlemlih/web:latest
    networks:
      - web
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.web.rule=Host(`darlemlih.ma`)"
      - "traefik.http.routers.web.tls.certresolver=letsencrypt"
    restart: unless-stopped

  traefik:
    image: traefik:v3.0
    command:
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@darlemlih.ma"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - letsencrypt:/letsencrypt
    networks:
      - web
    restart: unless-stopped

networks:
  internal:
    driver: bridge
  web:
    external: true

volumes:
  db_data:
  letsencrypt:
```

## CI/CD Pipeline Fix

To fix the GitHub Actions pipeline:

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  backend:
    name: Backend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
      - name: Grant execute permission for mvnw
        run: chmod +x apps/api/mvnw
      - name: Run tests
        working-directory: apps/api
        run: ./mvnw clean test
        
  frontend:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        working-directory: apps/web
        run: npm ci
      - name: Run tests
        working-directory: apps/web
        run: npm test -- --passWithNoTests
      - name: Build
        working-directory: apps/web
        run: npm run build
```

## Monitoring & Maintenance

### Health Checks
- Backend: `curl http://localhost:8080/actuator/health`
- Database: `docker exec darlemlih-db mysqladmin ping -h localhost`

### Logs
```bash
# View all logs
make logs

# View specific service logs
docker-compose logs -f api
docker-compose logs -f web
docker-compose logs -f db
```

### Backup Database
```bash
# Create backup
docker exec darlemlih-db mysqldump -uroot -prootpassword darlemlih > backup-$(date +%Y%m%d).sql

# Restore backup
docker exec -i darlemlih-db mysql -uroot -prootpassword darlemlih < backup-20250903.sql
```

## Troubleshooting

### Issue: Authentication not working
**Current Status**: Login endpoint returning 500 error
**Temporary Solution**: Use the reset-passwords endpoint to ensure passwords are correctly hashed:
```bash
curl -X POST http://localhost:8080/api/admin/reset-passwords
```

### Issue: Frontend can't connect to backend
- Check CORS configuration in backend
- Verify VITE_API_URL in frontend .env
- Check network connectivity between containers

### Issue: Database connection errors
- Verify MySQL is running and healthy
- Check connection string and credentials
- Ensure Flyway migrations have run successfully

## Next Steps

1. **Fix Authentication Issue**: Debug the 500 error on login endpoint
2. **Add SSL/TLS**: Configure HTTPS for production
3. **Setup Monitoring**: Add Prometheus/Grafana or New Relic
4. **Configure CDN**: Setup Cloudflare for static assets
5. **Add Rate Limiting**: Protect API endpoints
6. **Setup Backups**: Automated database backups
7. **Load Testing**: Verify application performance

## Support

For issues or questions:
- Check logs: `make logs`
- Reset environment: `make clean && make dev`
- Documentation: See README.md and WARP.md
