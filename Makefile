# Nexus AI Agent Framework Makefile
# Provides convenient commands for development and deployment

.PHONY: help install test build deploy clean docker-build docker-run docker-stop lint format security-check

# Default target
help:
	@echo "Nexus AI Agent Framework - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  install        Install all dependencies"
	@echo "  test           Run all tests"
	@echo "  lint           Run linting checks"
	@echo "  format         Format code"
	@echo "  security-check Run security scans"
	@echo ""
	@echo "Building:"
	@echo "  build          Build all components"
	@echo "  docker-build   Build Docker images"
	@echo "  docker-run     Run with Docker Compose"
	@echo "  docker-stop    Stop Docker containers"
	@echo ""
	@echo "Deployment:"
	@echo "  deploy-local   Deploy locally"
	@echo "  deploy-staging Deploy to staging"
	@echo "  deploy-prod    Deploy to production"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean          Clean build artifacts"
	@echo "  logs           Show application logs"
	@echo "  monitor        Monitor system health"

# =============================================================================
# DEVELOPMENT COMMANDS
# =============================================================================

install:
	@echo "Installing dependencies..."
	# Python dependencies
	pip install -r ai/requirements.txt
	pip install -r api/requirements.txt
	pip install -e .
	# Node.js dependencies
	cd ui && npm install
	# Rust dependencies
	cd core && cargo build
	@echo "✅ Dependencies installed successfully"

test:
	@echo "Running tests..."
	# Python tests
	cd ai && python -m pytest tests/ -v --cov=ai --cov-report=html
	cd api && python -m pytest tests/ -v --cov=api --cov-report=html
	# Rust tests
	cd core && cargo test
	# TypeScript tests
	cd ui && npm test
	@echo "✅ All tests completed"

lint:
	@echo "Running linting checks..."
	# Python linting
	flake8 ai/ api/ --max-line-length=100 --ignore=E203,W503
	mypy ai/ api/ --ignore-missing-imports
	# Rust linting
	cd core && cargo clippy -- -D warnings
	# TypeScript linting
	cd ui && npm run lint
	@echo "✅ Linting completed"

format:
	@echo "Formatting code..."
	# Python formatting
	black ai/ api/ --line-length=100
	isort ai/ api/
	# Rust formatting
	cd core && cargo fmt
	# TypeScript formatting
	cd ui && npm run format
	@echo "✅ Code formatting completed"

security-check:
	@echo "Running security scans..."
	# Python security
	bandit -r ai/ api/ -f json -o bandit-report.json || true
	safety check --json --output safety-report.json || true
	# Node.js security
	cd ui && npm audit --audit-level=moderate || true
	# Rust security
	cd core && cargo audit --json > cargo-audit-report.json || true
	@echo "✅ Security scans completed"

# =============================================================================
# BUILDING COMMANDS
# =============================================================================

build:
	@echo "Building all components..."
	# Build Rust core
	cd core && cargo build --release
	# Build Python packages
	pip install -e .
	# Build UI
	cd ui && npm run build
	@echo "✅ Build completed"

docker-build:
	@echo "Building Docker images..."
	docker-compose build
	@echo "✅ Docker images built"

docker-run:
	@echo "Starting Docker containers..."
	docker-compose up -d
	@echo "✅ Containers started"

docker-stop:
	@echo "Stopping Docker containers..."
	docker-compose down
	@echo "✅ Containers stopped"

# =============================================================================
# DEPLOYMENT COMMANDS
# =============================================================================

deploy-local:
	@echo "Deploying locally..."
	./scripts/deploy.ps1 -Environment local
	@echo "✅ Local deployment completed"

deploy-staging:
	@echo "Deploying to staging..."
	./scripts/deploy.ps1 -Environment staging
	@echo "✅ Staging deployment completed"

deploy-prod:
	@echo "Deploying to production..."
	./scripts/deploy.ps1 -Environment production
	@echo "✅ Production deployment completed"

# =============================================================================
# MAINTENANCE COMMANDS
# =============================================================================

clean:
	@echo "Cleaning build artifacts..."
	# Python
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	rm -rf build/ dist/ *.egg-info/
	# Rust
	cd core && cargo clean
	# Node.js
	cd ui && rm -rf node_modules/ build/ dist/
	# Docker
	docker system prune -f
	@echo "✅ Cleanup completed"

logs:
	@echo "Showing application logs..."
	docker-compose logs -f

monitor:
	@echo "Monitoring system health..."
	./scripts/monitor.ps1 -Mode health

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

setup-dev:
	@echo "Setting up development environment..."
	cp env.example .env
	@echo "Please edit .env with your configuration"
	@echo "✅ Development environment setup completed"

setup-db:
	@echo "Setting up database..."
	docker-compose up -d postgres redis
	@echo "Waiting for database to be ready..."
	sleep 10
	@echo "✅ Database setup completed"

backup:
	@echo "Creating backup..."
	./scripts/backup.ps1
	@echo "✅ Backup completed"

restore:
	@echo "Restoring from backup..."
	./scripts/restore.ps1
	@echo "✅ Restore completed"

# =============================================================================
# DOCUMENTATION COMMANDS
# =============================================================================

docs-build:
	@echo "Building documentation..."
	cd docs && mkdocs build
	@echo "✅ Documentation built"

docs-serve:
	@echo "Serving documentation..."
	cd docs && mkdocs serve

# =============================================================================
# RELEASE COMMANDS
# =============================================================================

release-patch:
	@echo "Creating patch release..."
	./scripts/release.ps1 -Type patch

release-minor:
	@echo "Creating minor release..."
	./scripts/release.ps1 -Type minor

release-major:
	@echo "Creating major release..."
	./scripts/release.ps1 -Type major

# =============================================================================
# CI/CD COMMANDS
# =============================================================================

ci-test:
	@echo "Running CI tests..."
	make install
	make test
	make lint
	make security-check
	@echo "✅ CI tests completed"

ci-build:
	@echo "Running CI build..."
	make build
	make docker-build
	@echo "✅ CI build completed"

# =============================================================================
# MONITORING COMMANDS
# =============================================================================

metrics:
	@echo "Collecting metrics..."
	./scripts/metrics.ps1

alerts:
	@echo "Checking alerts..."
	./scripts/alerts.ps1

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

dev-shell:
	@echo "Starting development shell..."
	docker-compose exec api bash

dev-logs:
	@echo "Showing development logs..."
	docker-compose logs -f api

dev-restart:
	@echo "Restarting development services..."
	docker-compose restart api ui

# =============================================================================
# HELPERS
# =============================================================================

check-deps:
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is required but not installed. Aborting." >&2; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required but not installed. Aborting." >&2; exit 1; }
	@command -v node >/dev/null 2>&1 || { echo "Node.js is required but not installed. Aborting." >&2; exit 1; }
	@command -v cargo >/dev/null 2>&1 || { echo "Rust is required but not installed. Aborting." >&2; exit 1; }
	@echo "✅ All dependencies are installed"

version:
	@echo "Nexus AI Agent Framework v0.1.0"

status:
	@echo "Checking system status..."
	docker-compose ps
	@echo "System resources:"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 