.PHONY: help dev prod build up down restart logs clean seed test

# Colors for output
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Show this help message
	@echo '${GREEN}Dar Lemlih Apiculture - E-Commerce Platform${NC}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${NC} ${GREEN}<command>${NC}'
	@echo ''
	@echo 'Commands:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${YELLOW}%-15s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

dev: ## Start development environment with Docker Compose
	@echo '${GREEN}Starting development environment...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml up -d
	@echo '${GREEN}Development environment started!${NC}'
	@echo ''
	@echo 'Services available at:'
	@echo '  - Frontend:   ${YELLOW}http://localhost:5173${NC}'
	@echo '  - Backend API: ${YELLOW}http://localhost:8080${NC}'
	@echo '  - Swagger UI:  ${YELLOW}http://localhost:8080/swagger-ui.html${NC}'
	@echo '  - phpMyAdmin:  ${YELLOW}http://localhost:8090${NC}'
	@echo '  - MailHog:     ${YELLOW}http://localhost:8025${NC}'

prod: ## Start production environment with Docker Compose
	@echo '${GREEN}Starting production environment...${NC}'
	docker-compose -f infra/docker/docker-compose.yml up -d
	@echo '${GREEN}Production environment started!${NC}'
	@echo ''
	@echo 'Services available at:'
	@echo '  - Frontend:   ${YELLOW}http://localhost:5173${NC}'
	@echo '  - Backend API: ${YELLOW}http://localhost:8080${NC}'

build: ## Build Docker images
	@echo '${GREEN}Building Docker images...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml build

up: ## Start all services
	@echo '${GREEN}Starting services...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml up -d

down: ## Stop all services
	@echo '${YELLOW}Stopping services...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml down

restart: ## Restart all services
	@echo '${YELLOW}Restarting services...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml restart

logs: ## View logs from all services
	docker-compose -f infra/docker/docker-compose.dev.yml logs -f

logs-api: ## View API logs
	docker-compose -f infra/docker/docker-compose.dev.yml logs -f api

logs-web: ## View web logs
	docker-compose -f infra/docker/docker-compose.dev.yml logs -f web-dev

logs-db: ## View database logs
	docker-compose -f infra/docker/docker-compose.dev.yml logs -f db

clean: ## Clean up Docker containers, networks, and volumes
	@echo '${RED}Cleaning up Docker resources...${NC}'
	docker-compose -f infra/docker/docker-compose.dev.yml down -v
	@echo '${GREEN}Cleanup complete!${NC}'

seed: ## Seed the database with demo data
	@echo '${GREEN}Seeding database...${NC}'
	@echo 'Note: Make sure the API is running first (make dev)'
	curl -X POST http://localhost:8080/api/admin/seed
	@echo '${GREEN}Database seeded!${NC}'

test: ## Run tests
	@echo '${GREEN}Running backend tests...${NC}'
	cd apps/api && ./mvnw test
	@echo '${GREEN}Running frontend tests...${NC}'
	cd apps/web && npm test

test-api: ## Run API tests only
	@echo '${GREEN}Running API tests...${NC}'
	cd apps/api && ./mvnw test

test-web: ## Run web tests only
	@echo '${GREEN}Running web tests...${NC}'
	cd apps/web && npm test

install: ## Install dependencies for local development
	@echo '${GREEN}Installing backend dependencies...${NC}'
	cd apps/api && ./mvnw clean install
	@echo '${GREEN}Installing frontend dependencies...${NC}'
	cd apps/web && npm install

dev-api: ## Run API in development mode (local)
	cd apps/api && ./mvnw spring-boot:run

dev-web: ## Run web in development mode (local)
	cd apps/web && npm run dev

format: ## Format code
	@echo '${GREEN}Formatting Java code...${NC}'
	cd apps/api && ./mvnw spotless:apply
	@echo '${GREEN}Formatting TypeScript/React code...${NC}'
	cd apps/web && npm run format

lint: ## Lint code
	@echo '${GREEN}Linting TypeScript/React code...${NC}'
	cd apps/web && npm run lint
